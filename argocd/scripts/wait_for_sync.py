import requests
import json
import time
import argparse
import os

#
# python3 wait_for_sync.py --wait-for=30 --application=default --target=3f9c8c3c02d8573901bd4c4e0c9ddfe7d7dcddf5 --argocd-url https://argocd.metering-shared-non-prod.ovotech.org.uk/
#
def sync_request(endpoint, token, application):

    try:
        headers = { 'Authorization' : 'Bearer %s' % token }
        res = requests.post(endpoint.rstrip("/") + f'/api/v1/applications/{application}/sync', headers=headers, timeout = 10, verify=True)
        if res.status_code != 200:
            print(f"ERROR: Non-200 response ({res.status_code}): {res.json()}.")
            exit(1)
        
        data = res.json()
        cluster_sync_status = data['status']['sync']['status']

        if os.environ.get('ARGOCD_ORB_DEBUG'):
            print_debug(data)

        if cluster_sync_status == "Synced":
            print(f'Sync request successful, application was in sync')
            return True
        else:
            print(f'Sync request successful, application was not in sync')
            return True

    except ValueError as e:
        print(f'ERROR: Decoding JSON has failed: {e}')
        exit(1)
        
    except Exception as e:
        print(f'ERROR: Request failed: {e}')
        exit(1)


def is_cluster_insync(endpoint, token, application, target_revision):

    try:
        headers = { 'Authorization' : 'Bearer %s' % token }
        res = requests.get(endpoint.rstrip("/") + f'/api/v1/applications/{application}', headers=headers, timeout = 10, verify=True)
        if res.status_code != 200:
            print(f"ERROR: Non-200 response ({res.status_code}): {res.json()}.")
            return False
        
        data = res.json()
        cluster_revision = data['status']['operationState']['syncResult']['revision']
        cluster_phase = data['status']['operationState']['phase']
        cluster_sync_status = data['status']['sync']['status']
        app_health = data['status']['health']['status']

        if os.environ.get('ARGOCD_ORB_DEBUG'):
            print_debug(data)

        print(f'cluster revision: {cluster_revision}')

        if cluster_revision == target_revision and cluster_phase == "Succeeded" and app_health != "Progressing":
            if cluster_sync_status == "Synced":
                return True;
            
            # Find any out-of-sync resources that are not to be pruned
            out_of_sync = list(filter(lambda r: r['status'] != "Synced" and not r.get('requiresPruning', False), data['status']['resources']))
            if len(out_of_sync) > 0:
                print(f'Application is out of sync with {target_revision}')
                return False
            
            # Cluster is in sync, but requires pruning.
            return True
            
        else:
            print(f'Application is not yet synced to {target_revision} or has synced with a different target')
            return False;
    
    except ValueError as e:
        print(f'ERROR: Decoding JSON has failed: {e}')
        return False
        
    except Exception as e:
        print(f'ERROR: Request failed: {e}')
        return False
    

def print_debug(application):
    operation_state_rev = application['status']['operationState']['operation']['sync']['revision']
    operation_state_syncResult_rev = application['status']['operationState']['syncResult']['revision']
    operation_state_phase = application['status']['operationState']['phase']
    operation_state_message = application['status']['operationState']['message']
    operation_state_startedAt = application['status']['operationState']['startedAt']
    operation_state_finishedAt = application['status']['operationState']['finishedAt']
    app_sync_revision = application['status']['sync']['revision']
    app_health = application['status']['health']
    app_sync_status = application['status']['sync']['status']

    print(f'''
        operation_state_rev {operation_state_rev};
        operation_state_syncResult_rev {operation_state_syncResult_rev};
        operation_state_phase: {operation_state_phase};
        operation_state_message: {operation_state_message}
        operation_state_startedAt {operation_state_startedAt};
        operation_state_finishedAt {operation_state_finishedAt};
        app_sync_revision: {app_sync_revision};
        app_sync_status: {app_sync_status};
        app_health: {app_health['status']};
        ''')

if __name__ == '__main__':


    # Initiate the parser
    parser = argparse.ArgumentParser()

    # Add long and short argument
    parser.add_argument("--wait-for", help="Set maximum number of seconds to wait for cluster being sync", default=300)
    parser.add_argument("--application", help="Application to check")
    parser.add_argument("--target", help="Target Git hash cluster should be synced to")
    parser.add_argument("--argocd-url", help="API endpoint of ArgoCD")
    parser.add_argument("--sync-request", action=argparse.BooleanOptionalAction, help="API endpoint of ArgoCD")
    
    args = parser.parse_args()

    if args.sync_request == True:
        sync_request(args.argocd_url, os.environ.get('ARGOCD_TOKEN'), args.application);

    t_end = time.time() + int(args.wait_for)
    while time.time() <= t_end:
        print(f'Checking if {args.application} is in sync with {args.target}...')
                
        if is_cluster_insync(args.argocd_url, os.environ.get('ARGOCD_TOKEN'), args.application, args.target):
            exit(0)
        time.sleep(5)
    
    print(f'Waiting for cluster to be in sync timed out.')
    exit(1)
