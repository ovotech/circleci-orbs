cat >/tmp/sync_and_wait.py <<"EOF"
include sync_and_wait.py
EOF

python3 /tmp/sync_and_wait.py  --wait-for=<<parameters.wait_for>>  --target=<<parameters.target>>  --application=<<parameters.application>>  --argocd-url <<parameters.argocd_url>>
