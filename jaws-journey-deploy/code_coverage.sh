cat >/tmp/get_coverage.py <<"EOF"
include get_coverage.py
EOF

python3 get_coverage.py ./reports/jacoco
