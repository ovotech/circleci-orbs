curl -L -O https://github.com/mikefarah/yq/releases/download/<<parameters.yq_version>>/yq_linux_amd64
sudo mv yq_linux_amd64 /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
yq --version