
argocd_url='https://argocd.metering-shared-sandbox.ovotech.org.uk'
application='smart-ingestion-service'

RESPONSE=$(curl -X POST -H "Authorization: Bearer ${ARGOCD_TOKEN}" ${argocd_url}/api/v1/applications/${application}/sync)
echo $RESPONSE
STATUS=$( $RESPONSE | jq -r '.status.sync.status' )
echo $STATUS
if [ $STATUS != 'Synced' ];
then
    echo 'Application is not in sync'
    exit 1
fi    
# curl -X POST -H "Authorization: Bearer ${ARGOCD_TOKEN}" ${argocd_url}/api/v1/applications/${application}/sync