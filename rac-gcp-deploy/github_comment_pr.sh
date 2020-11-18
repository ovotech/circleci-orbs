#!/bin/bash
set -eu

PR_COMMENT_TITLE="SNYK REPORT"

comment_pr () {
    local pr_body="$PR_COMMENT_TITLE"$'\n```PowerShell\n'"$snyk_report"$'\n```'
    jq --arg x "$pr_body" -n '{body: $x}' | curl --location --request POST "$1" \
    -u $GITHUB_USERNAME:$GITHUB_TOKEN \
    --header 'Content-Type: application/json' \
    --data-binary @-
}

pr_response=$(curl --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls?head=$CIRCLE_PROJECT_USERNAME:$CIRCLE_BRANCH&state=open" \
    -u $GITHUB_USERNAME:$GITHUB_TOKEN)

if [ $(echo $pr_response | jq length) -eq 0 ]; then
    echo "No PR found to update"
else
    pr_comment_url=$(echo $pr_response | jq -r ".[]._links.comments.href")
fi

snyk_report="$(snyk test || :)"

existing_pr_comment=$(curl --location --request GET "$pr_comment_url" \
    -u $GITHUB_USERNAME:$GITHUB_TOKEN | jq -r '.[] | select(.user.login == "'$GITHUB_USERNAME'") | select(.body | startswith("'"$PR_COMMENT_TITLE"'")) | .url')

if [ -z "$existing_pr_comment" ]; then
    echo "Adding new comment"
    comment_pr $pr_comment_url
else
    echo "Updating existing comment"
    comment_pr $existing_pr_comment
fi