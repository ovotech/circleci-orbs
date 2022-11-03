import requests
import json
import argparse
import os

#
# python3 sync_request.py --application=default --argocd-url https://argocd.metering-shared-non-prod.ovotech.org.uk/
#
def sync_request(endpoint, token, application):

    try:
        headers = { 'Authorization' : 'Bearer %s' % token }
        res = requests.post(endpoint.rstrip("/") + f'/api/v1/applications/{application}/sync', headers=headers, timeout = 10, verify=True)
        if res.status_code != 200:
            print(f"ERROR: Non-200 response ({res.status_code}): {res.json()}.")
            return False
        
        data = res.json()
        cluster_sync_status = data['status']['sync']['status']

        if os.environ.get('ARGOCD_ORB_DEBUG'):
            print_debug(data)
        
        if cluster_sync_status == "Synced":
            print(f'Sync request successful, application was in sync')
            return True
        else:
            print(f'Sync request successful, application was not synced')
            return False
    
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
    parser.add_argument("--application", help="Application to sync")
    parser.add_argument("--argocd-url", help="API endpoint of ArgoCD")

    args = parser.parse_args()
                
    if sync_request(args.argocd_url, os.environ.get('ARGOCD_TOKEN'), args.application):
        exit(0)
    
    exit(1)
