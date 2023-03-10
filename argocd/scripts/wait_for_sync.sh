cat >/tmp/wait_for_sync.py <<"EOF"
include wait_for_sync.py
EOF

if <<parameters.sync_request>> ; then
    python3 /tmp/wait_for_sync.py --wait-for=<<parameters.wait_for>> --application=<<parameters.application>> --target=<<parameters.target>> --argocd-url <<parameters.argocd_url>> --sync-request
else
    python3 /tmp/wait_for_sync.py --wait-for=<<parameters.wait_for>> --application=<<parameters.application>> --target=<<parameters.target>> --argocd-url <<parameters.argocd_url>> --no-sync-request
fi