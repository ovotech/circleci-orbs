cat >/tmp/sync_request.py <<"EOF"
include sync_request.py
EOF

python3 /tmp/sync_request.py  --application=<<parameters.application>>  --argocd-url <<parameters.argocd_url>>
