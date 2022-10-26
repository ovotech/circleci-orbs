
USERNAME="<< parameters.username >>"
TOKEN="<< parameters.token >>"
URL="<< parameters.url >>"

docker login https://$URL -u $USERNAME -p $TOKEN
