cat >/tmp/cleanup_kafka.py <<"EOF"
include cleanup_kafka.py
EOF

python3 /tmp/cleanup_kafka.py -a "$1" -v "$2" -k "$3" -d "$4"
