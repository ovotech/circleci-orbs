#!/bin/bash -eo pipefail
set -x

# 'path' is a required parameter, save it as module_path
readonly module_path="terraform"
export path=$module_path

if [[ ! -d "$module_path" ]]; then
  echo "Path does not exist: \"$module_path\""
  exit 1
fi

# Select the correct terraform version - this will persist for the rest of the job
if hash tfswitch 2>/dev/null; then
  (cd "$module_path" && echo "" | tfswitch | grep -e Switched -e Reading | sed 's/^.*Switched/Switched/')
fi

# Check the terraform version is >= 0.14
tf_version=$(terraform version -json | jq -r .terraform_version)
if [ $(echo $tf_version | cut -d '.' -f 1) -lt 1 ] && [ $(echo $tf_version | cut -d '.' -f 2) -lt 14 ]; then
    echo "Your version of terraform is too old. The terraform v2 orb only supports terraform >= 0.14"
    exit 1
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
set -x

# Initialize terraform
if [[ -n "terraform/backend/prod-config.tfvars" ]]; then
    for file in $(echo "terraform/backend/prod-config.tfvars" | tr ',' '\n'); do
        if [[ -f "$file" ]]; then
            # chdir needs files to be specified relative to the terraform
            # config file, so change this to be a relative path
            rel_path=$(realpath --relative-to ${module_path} ${file})
            INIT_ARGS="$INIT_ARGS -backend-config=${rel_path}"
        elif [[ -f "$module_path/$file" ]]; then
            INIT_ARGS="$INIT_ARGS -backend-config=$file"
        else
            echo "Backend config '$file' wasn't found" >&2
            exit 1
        fi
    done
fi

if [[ -n "encryption_key=$TERRAFORM_PROD_ENCRYPTION_KEY" ]]; then
    for config in $(echo "encryption_key=$TERRAFORM_PROD_ENCRYPTION_KEY" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$config"
    done
fi

export INIT_ARGS

# Set workspace from parameter, allowing it to be overridden by TF_WORKSPACE.
# If TF_WORKSPACE is set we don't want terraform init to use the value, in the case we are running new_workspace.sh this would cause an error
readonly workspace_parameter="default"
readonly workspace="${TF_WORKSPACE:-$workspace_parameter}"
export workspace
unset TF_WORKSPACE

rm -rf ${module_path}/.terraform
terraform -chdir=${module_path} init -input=false -no-color $INIT_ARGS
set -x

terraform -chdir=${module_path} workspace select -no-color "${workspace}"
set -x

if [[ "0" -ne 0 ]]; then
    PLAN_ARGS="$PLAN_ARGS -parallelism=0"
fi

if [[ -n "" ]]; then
    for var in $(echo "" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var $var"
    done
fi

if [[ -n "" ]]; then
    for target in $(echo "" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -target $target"
    done
fi

if [[ -n "terraform/env/prod.tfvars" ]]; then
    for file in $(echo "terraform/env/prod.tfvars" | tr ',' '\n'); do
        # TODO Testing: make sure that this works for files specified
        # from the top level and for files specified relative to the
        # terraform configuration
        if [[ -f "$file" ]]; then
            # chdir needs files to be specified relative to the terraform
            # config file, so change this to be a relative path
            rel_path=$(realpath --relative-to ${module_path} ${file})
            PLAN_ARGS="$PLAN_ARGS -var-file=$rel_path"
        elif [[ -f "$module_path/$file" ]]; then
            PLAN_ARGS="$PLAN_ARGS -var-file=$file"
        else
            echo "Var file '$file' wasn't found" >&2
            exit 1
        fi
    done
fi

export PLAN_ARGS
set -x

cat >/tmp/github.py <<"EOF"
#!/usr/bin/env python3

import os
import comment_util
import sys
from typing import Optional, Dict, Iterable

import requests

github_username = os.environ['GITHUB_USERNAME']
github_token = os.environ['GITHUB_TOKEN']
owner = os.environ['CIRCLE_PROJECT_USERNAME']
repo = os.environ['CIRCLE_PROJECT_REPONAME']
pr_number = os.environ.get('CIRCLE_PR_NUMBER')
commit = os.environ.get('CIRCLE_SHA1')

github = requests.Session()
github.auth = (github_username, github_token)


def find_pr() -> str:
    """
    Find the PR for this commit and return the API url
    """

    if pr_number:
        response = github.get(f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}')
        response.raise_for_status()
        return response.json()['url']

    def prs() -> Iterable[Dict]:
        url = f'https://api.github.com/repos/{owner}/{repo}/pulls'

        while True:
            response = github.get(url, params={'state': 'all'})
            response.raise_for_status()

            for pr in response.json():
                yield pr

            if 'next' in response.links:
                url = response.links['next']['url']
            else:
                return

    for pr in prs():
        if pr['merge_commit_sha'] == commit:
            return pr['url']

    raise Exception(f'No PR found in {owner}/{repo} for commit {commit} (was it pushed directly to the target branch?)')


class TerraformComment:
    """
    The GitHub comment for this specific terraform plan
    """

    def __init__(self, pr_url: str):
        self._plan = None
        self._status = None

        response = github.get(pr_url)
        response.raise_for_status()

        self._issue_url = response.json()['_links']['issue']['href'] + '/comments'
        response = github.get(self._issue_url)
        response.raise_for_status()

        self._comment_url = None
        for comment in response.json():
            if comment['user']['login'] == github_username:
                match = comment_util.re_comment_match(self._comment_identifier,
                                                      comment['body'])
                if match:
                    self._comment_url = comment['url']
                    self._plan = match.group(1).strip()
                    self._status = match.group(2).strip()
                    return

    @property
    def _comment_identifier(self):
        if self.label:
            return f'Terraform plan for __{self.label}__'

        label = f'Terraform plan in __{self.path}__'

        if self.workspace != 'default':
            label += f' in the __{self.workspace}__ workspace'

        if self.init_args:
            key_to_replace = "-backend-config=encryption_key="
            if key_to_replace in self.init_args:
                index = self.init_args.find(key_to_replace) + len(key_to_replace)
                encrypted_key = self.init_args[index:]
                masked_key = "*" * len(encrypted_key)
                self.init_args = self.init_args[:index] + masked_key

            label += f'\nUsing init args: `{self.init_args}`'
        if self.plan_args:
            label += f'\nUsing plan args: `{self.plan_args}`'

        return label

    @property
    def path(self) -> str:
        return os.environ.get('path')

    @property
    def build_url(self) -> str:
        return os.environ['CIRCLE_BUILD_URL']

    @property
    def build_num(self) -> str:
        return os.environ['CIRCLE_BUILD_NUM']

    @property
    def job_name(self) -> str:
        return os.environ['CIRCLE_JOB']

    @property
    def workspace(self) -> str:
        return os.environ.get('workspace')

    @property
    def label(self) -> str:
        return os.environ.get('label')

    @property
    def init_args(self) -> str:
        return os.environ.get('INIT_ARGS')

    @init_args.setter
    def init_args(self, value):
        self.init_args = value

    @property
    def plan_args(self) -> str:
        return os.environ.get('PLAN_ARGS')

    @property
    def plan(self) -> Optional[str]:
        return self._plan

    @plan.setter
    def plan(self, plan: str) -> None:
        self._plan = plan.strip()
        self._update_comment()

    @property
    def status(self) -> Optional[str]:
        return self._status

    @status.setter
    def status(self, status: str) -> None:
        self._status = status.strip()
        self._update_comment()

    def _update_comment(self):
        comment = comment_util.comment_for_pr(self._comment_identifier,
                                              self.plan)

        if self.status:
            comment += '\n' + self.status
        else:
            comment += (f'\nPlan generated in CircleCI Job '
                        f'[{self.job_name} {self.build_num}]'
                        f'({self.build_url})')

        if self._comment_url is None:
            # Create a new comment
            response = github.post(self._issue_url, json={'body': comment})
        else:
            # Update existing comment
            response = github.patch(self._comment_url, json={'body': comment})

        response.raise_for_status()
        self._comment_url = response.json()['url']


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'''Usage:
    {sys.argv[0]} plan <plan.txt
    {sys.argv[0]} status <status.txt
    {sys.argv[0]} get >plan.txt''')

    comment = TerraformComment(find_pr())

    if sys.argv[1] == 'plan':
        comment.plan = sys.stdin.read().strip()
    elif sys.argv[1] == 'status':
        if comment.plan:
            comment.status = sys.stdin.read().strip()
        print(comment.status)
    elif sys.argv[1] == 'get':
        print(comment.plan)

EOF

cat >/tmp/comment_util.py <<"EOF"
import re

current_template = (
    '<details>\n'
    '<summary>View Terraform Plan</summary>\n\n'
    '```terraform\n'
    'Output is limited to 1000 lines and may be truncated. See CircleCI for full details.\n'
    '{plan}\n'
    '```\n'
    '</details>\n'
)
previous_templates = [
    "```hcl\n{plan}\n```",
]


def re_comment_match(comment_id, comment_body):
    """Returns a Match object, or None if no match was found"""

    def _build_regex(template):
        regex = re.escape(template.replace('{plan}', '___plan___')) \
            .replace('___plan___', '(.*)')
        return f'{re.escape(comment_id)}\n{regex}(.*)'

    for tmpl in [current_template, *previous_templates]:
        m = re.match(_build_regex(tmpl), comment_body, re.DOTALL)
        if m is not None:
            return m

    return None


def comment_for_pr(comment_id, plan):
    """Returns a formatted string containing comment_id and plan"""
    return f'{comment_id}\n{current_template.format(plan=plan)}'

EOF

exec 3>&1

set +e

if [[ "false" == "true" ]]; then
  terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300 -out=plan.out $PLAN_ARGS
  readonly TF_EXIT=$?
  (cd ${module_path};
  terraform show -no-color plan.out \
      | $TFMASK \
      | $COMPACT_PLAN \
   ) > plan.txt
else
  terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300s -out=plan.out $PLAN_ARGS \
          | $TFMASK \
          | tee /dev/fd/3 \
          | $COMPACT_PLAN \
              >plan.txt

  readonly TF_EXIT=${PIPESTATUS[0]}
fi

set -e

if [[ $TF_EXIT -eq 1 ]]; then
    echo "Error running terraform"
    exit 1
fi

if [[ -n "$GITHUB_TOKEN" && "true" == "true" ]]; then
    export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
    export label=""

    if ! python3 /tmp/github.py plan <plan.txt; then
        echo "Error adding comment to PR"
    fi
fi
