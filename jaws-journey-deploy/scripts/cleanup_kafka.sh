cat >/tmp/cleanup_kafka.py <<"EOF"
include cleanup_kafka.py
EOF

python3 /tmp/cleanup_kafka.py \
  --app_id_common "<< parameters.app-id-common >>" \
  --app_id_version "<< parameters.app-id-version >>" \
  --kube_namespace "<< parameters.kube-namespace >>" \
  --dry_run "<< parameters.preview-mode >>"