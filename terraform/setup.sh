# 'path' is a required parameter, save it as module_path
readonly module_path="<< parameters.path >>"
export path=$module_path

if [[ ! -d "$module_path" ]]; then
  echo "Path does not exist: \"$module_path\""
  exit 1
fi

# Select the correct terraform version - this will persist for the rest of the job
if hash tfswitch 2>/dev/null; then
  (cd "$module_path" && echo "" | tfswitch | grep -e Switched -e Reading | sed 's/^.*Switched/Switched/')
fi

# Check that the terraform version isn't greater than 0.14
if terraform version -help | grep -e "-json" >/dev/null; then
    tf_version=$(terraform version -json | jq -r .terraform_version)
    if  [ $(echo -n ${tf_version} | sed 's/^\([0-9]\).*/\1/') -ge 1 ] || [ $(echo -n ${tf_version} | sed 's/^[0-9]\.\([0-9][0-9]\)\.[0-9]*/\1/') -ge 15 ] ; then
        echo "The terraform orb does not support terraform 0.15+. Please use the terraform-v2 orb."
        echo "https://circleci.com/developer/orbs/orb/ovotech/terraform-v2"
        exit 1
    fi
fi

if [ -n "$TF_REGISTRY_TOKEN" ]; then
    echo "credentials \"$TF_REGISTRY_HOST\" { token = \"$TF_REGISTRY_TOKEN\" }" >>$HOME/.terraformrc
fi

# Set TF environment variables
# These are already set in the dockerfile, but set again just in case the orb is used with a different executor
export TF_INPUT=false
export TF_PLUGIN_CACHE_DIR=/usr/local/share/terraform/plugin-cache
export TF_IN_AUTOMATION=yep

# Configure cloud credentials
GCLOUD_SERVICE_KEY="${GCLOUD_SERVICE_KEY:-$GOOGLE_SERVICE_ACCOUNT}"

if [[ -n "$GCLOUD_SERVICE_KEY" ]]; then
  GCLOUD_AUTH_KEY=$GCLOUD_SERVICE_KEY
elif [[ -n "$GCLOUD_OIDC_KEY" ]]; then
  GCLOUD_AUTH_KEY=$GCLOUD_OIDC_KEY
fi

if [[ -n "$GCLOUD_AUTH_KEY" ]]; then

    if echo "$GCLOUD_AUTH_KEY" | grep "{" >/dev/null; then
        echo "$GCLOUD_AUTH_KEY" >/tmp/google_creds
    else
        echo "$GCLOUD_AUTH_KEY" \
            | base64 --decode --ignore-garbage \
                >/tmp/google_creds
    fi

    export GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_creds
    if [[ -n "$GCLOUD_SERVICE_KEY" ]]; then
      gcloud auth activate-service-account --key-file /tmp/google_creds
    elif [[ -n "$GCLOUD_OIDC_KEY" ]]; then
      gcloud auth login --brief --cred-file /tmp/google_creds
    fi
fi

if [[ -n "$GOOGLE_PROJECT_ID" ]]; then
    gcloud --quiet config set project "$GOOGLE_PROJECT_ID"
fi

if [[ -n "$GOOGLE_COMPUTE_ZONE" ]]; then
    gcloud --quiet config set compute/zone "$GOOGLE_COMPUTE_ZONE"
fi

# Put Aiven's provider in place if requested
if [[ -n "$AIVEN_PROVIDER" ]]; then
    ln -fs /root/aiven/* /root/.terraform.d/plugins/
fi

if [[ -n "$HELM" ]]; then
    rm /usr/local/bin/helm
    ln -s /usr/local/bin/$HELM /usr/local/bin/helm
fi

# Detect tfmask
TFMASK=tfmask
if ! hash $TFMASK 2>/dev/null; then
    TFMASK=cat
fi

# Detect compact_plan
COMPACT_PLAN=compact_plan
if ! hash $COMPACT_PLAN 2>/dev/null; then
    COMPACT_PLAN=cat
fi
