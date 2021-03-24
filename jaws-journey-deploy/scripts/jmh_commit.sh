cat >/tmp/jmh_github_comment.py <<"EOF"
include jmh_github_comment.py
EOF

FOLDER="<< parameters.file_path >>"

python3 /tmp/jmh_github_comment.py $FOLDER
