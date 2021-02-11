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

export chdir=""
export config_path="${module_path}"
# -chdir was introduced in terraform 0.14 and is necessary in 0.14 to make sure the
# provider lock file in the terraform config directory is picked up. However, older
# versions of terraform need the terraform config directory to be specified at the
# end of the command
if terraform -help | grep -e "-chdir" >/dev/null && "<< parameters.chdir >>" == "true"; then
  chdir="-chdir=${module_path}"
  config_path=""
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

    if echo "$GCLOUD_SERVICE_KEY" | grep "{" >/dev/null; then
        echo "$GCLOUD_SERVICE_KEY" >/tmp/google_creds
    else
        echo "$GCLOUD_SERVICE_KEY" \
            | base64 --decode --ignore-garbage \
                >/tmp/google_creds
    fi

    export GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_creds
    gcloud auth activate-service-account --key-file /tmp/google_creds
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
