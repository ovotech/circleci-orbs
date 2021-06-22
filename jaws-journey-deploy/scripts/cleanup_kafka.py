from confluent_kafka.admin import AdminClient
from confluent_kafka.schema_registry import SchemaRegistryClient
import base64
import boto3
import subprocess
import os
import argparse
import sys

parser = argparse.ArgumentParser(
    description='Removes defunct Kafka state directories and internal topics after an application.id change'
)
parser.add_argument(
    '--app_id_common',
    '-a',
    help='the common part of your journey\'s application id (eg: internal_jaws_journey_tariff_configuration_streamx-v)',
    type=str,
    required=True
)
parser.add_argument(
    '--app_id_version',
    '-v',
    help='the current version of the application id (eg: 5)',
    type=str,
    required=True
)
parser.add_argument(
    '--kube_namespace',
    '-k',
    help='the journey\'s kube namespace (eg: jaws-tariff-configuration-journey)',
    type=str,
    required=True
)
parser.add_argument(
    '--dry_run',
    '-d',
    help='flag to specify whether the actions will just be previewed (not committed)',
    type=str,
    default='false'
)

parser.print_help()

args = parser.parse_args()
args.dry_run = args.dry_run != 'false'

ssm = boto3.client('ssm')


def get_parameter(parameterName):
    return ssm.get_parameter(Name=parameterName, WithDecryption=True)['Parameter']['Value']


def create_file(parameterName, fileName):
    fileContents = base64.b64decode(
        get_parameter(parameterName)
    ).decode('utf-8')

    writeFile = open(fileName, "w")
    writeFile.write(fileContents)
    writeFile.close()


print('\ncreating kafka credentials...')
create_file('/aiven/service_cert', 'service.cert')
create_file('/aiven/cacert', 'ca.cert')
create_file('/aiven/service_key', 'service.key')
print('kafka credentials created!\n')

print('connecting to kafka...')
admin_client = AdminClient({
    'bootstrap.servers': get_parameter('/aiven/cluster_uri'),
    'client.id': 'Kafka-Cleanup-Tool',
    'security.protocol': 'SSL',
    'ssl.ca.location': 'ca.cert',
    'ssl.certificate.location': 'service.cert',
    'ssl.key.location': 'service.key',
})
schema_client = SchemaRegistryClient({
    'basic.auth.user.info': f'{get_parameter("/aiven/service_username")}:{get_parameter("/aiven/service_password")}',
    'url': get_parameter('/aiven/schema_uri')
})
print('connected to kafka!\n')


def remove_certs():
    os.remove('service.cert')
    os.remove('service.key')
    os.remove('ca.cert')


application_id = f'{args.app_id_common}{args.app_id_version}'


def get_entities_to_delete(entities):
    return [entity for entity in entities
            if args.app_id_common in entity
            and application_id not in entity]


print('fetching schema registry subjects...')
all_subjects = schema_client.get_subjects()
print('schema registry subjects have been fetched!\n')

subjects_to_delete = get_entities_to_delete(all_subjects)


def close_if_nothing_to_delete(entities_to_delete, entity_name):
    if (len(entities_to_delete) == 0):
        print(f'there are no {entity_name} to delete')
        print('hooray! kafka state is already clean, no action required!')
        remove_certs()
        sys.exit()


close_if_nothing_to_delete(subjects_to_delete, 'subjects')

print('the subjects to be deleted are:')
print('\n'.join(subjects_to_delete))

if not args.dry_run:
    print('deleting subjects...')
    for subject in subjects_to_delete:
        schema_client.delete_subject(subject)
    print('subjects have been deleted!\n')

print("fetching kafka topics...")
all_topics = [topic for topic in admin_client.list_topics().topics]
print("topics have been fetched!\n")

topics_to_delete = get_entities_to_delete(all_topics)
close_if_nothing_to_delete(topics_to_delete, 'topics')

print('the topics to be deleted are:')
print('\n'.join(topics_to_delete))

if not args.dry_run:
    print('deleting topics...')
    admin_client.delete_topics(topics_to_delete)
    print('topics have been deleted!\n')

remove_certs()

subprocess.getoutput(
    'aws eks --region eu-west-1 update-kubeconfig --name jaws'
)

pod_table = subprocess.getoutput(
    f'kubectl get pods -n {args.kube_namespace}'
).splitlines()

if (len(pod_table) <= 1):
    print('no pods found for given kube namespace')
    sys.exit(0)


pods = [pod.split()[0] for pod in pod_table[1:]]

service_name = os.path.commonprefix(pods).strip('-')

directory_base = f'var/lib/{service_name}/state'

for pod in pods:
    print(f'removing kafka state directories from {pod}...')
    folders_to_delete = [f'{directory_base}/{folder}' for folder in
                         subprocess.getoutput(
                             f'kubectl exec -it {pod} -n {args.kube_namespace} -- ls {directory_base}'
                         ).split()
                         if application_id not in folder]
    print('the following folders are to be deleted:')
    print('\n'.join(folders_to_delete))
    if not args.dry_run:
        for folder in folders_to_delete:
            subprocess.getoutput(
                f'kubectl exec -it {pod} -n {args.kube_namespace} -- rm -rf {folder}'
            )
        print(f'kafka state directories removed for {pod}!\n')

print('everything is all nice and clean now!')
print('thanks and good bye')
