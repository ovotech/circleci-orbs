import requests
import json
import time
import argparse
import os

#
# python3 wait_for_sync.py --wait-for=30 --application=default --target=3f9c8c3c02d8573901bd4c4e0c9ddfe7d7dcddf5 --argocd-url http://argocd.metering-shared-non-prod.ovotech.org.uk/
#
def is_cluster_insync(endpoint, token, application, target_revision):

    try:
        headers = { 'Authorization' : 'Bearer %s' % token }
        res = requests.get(endpoint + f'/api/v1/applications/{application}', headers=headers, timeout = 10, verify=True)
        if res.status_code != 200:
            print(f"ERROR: Non-200 response ({res.status_code}): {res.json()}.")
            return False
        
        data = res.json()
        cluster_revision = data['status']['operationState']['operation']['sync']['revision']
        cluster_phase = data['status']['operationState']['phase']
        cluster_sync_status = data['status']['sync']['status']

        if cluster_revision == target_revision and cluster_phase == "Succeeded":
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
    

if __name__ == '__main__':


    # Initiate the parser
    parser = argparse.ArgumentParser()

    # Add long and short argument
    parser.add_argument("--wait-for", help="Set maximum number of seconds to wait for cluster being sync", default=300)
    parser.add_argument("--application", help="Application to check")
    parser.add_argument("--target", help="Target Git hash cluster should be synced to")
    parser.add_argument("--argocd-url", help="API endpoint of ArgoCD")

    args = parser.parse_args()

    t_end = time.time() + int(args.wait_for)
    while time.time() <= t_end:
        print(f'Checking if {args.application} is in sync with {args.target}...')
                
        if is_cluster_insync(args.argocd_url, os.environ.get('ARGOCD_TOKEN'), args.application, args.target):
            exit(0)
        time.sleep(5)
    
    print(f'Waiting for cluster to be in sync timed out.')
    exit(1)