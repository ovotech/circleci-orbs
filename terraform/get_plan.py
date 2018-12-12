#!/usr/bin/env python3

import os
import re
import sys

import requests

HOST = 'https://api.github.com'

github_username = os.environ['GITHUB_USERNAME']
github_token = os.environ['GITHUB_TOKEN']

session = requests.Session()
session.auth = (github_username, github_token)


def prs(owner, repo):
    url = f'{HOST}/repos/{owner}/{repo}/pulls'

    while True:
        response = session.get(url, params={'state': 'all'})
        response.raise_for_status()

        for pr in response.json():
            yield pr

        if 'next' in response.links:
            url = response.links['next']['url']
        else:
            return


def find_pr(owner, repo, commit):
    for pr in prs(owner, repo):
        if pr['merge_commit_sha'] == commit:
            return pr['number']

    raise Exception(f'No PR found in {owner}/{repo} for commit {commit}')


def find_plan(owner: str, repo: str, pr: int, module_path: str, workspace: str, env: str) -> str:
    response = session.get(f'{HOST}/repos/{owner}/{repo}/pulls/{pr}')
    response.raise_for_status()

    pr = response.json()
    issue_url = pr['_links']['issue']['href'] + '/comments'

    response = session.get(issue_url)
    response.raise_for_status()

    for comment in response.json():
        if comment['user']['login'] == github_username:

            label = 'Terraform plan for (.*?) in the (.*?) workspace'
            if env:
                label = f'Terraform plan for __{env}__'

            match = re.match(rf'{label}\n```(.*)```', comment['body'], re.DOTALL)

            if match:
                comment_module = match.group(1)
                comment_workspace = match.group(2)
                plan = match.group(3)

                if comment_module == module_path and comment_workspace == workspace:
                    return plan.strip()


def get(owner: str, repo: str, commit: str, module_path: str, workspace: str, env: str) -> str:
    pr = find_pr(owner, repo, commit)
    return find_plan(owner, repo, pr, module_path, workspace, env)


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print(f'Usage:\n\t{sys.argv[0]} <module_path> [<workspace>] < plan.txt')
        exit(-1)

    module_path = sys.argv[1]
    workspace = sys.argv[2] if len(sys.argv) >= 3 else 'default'

    owner = os.environ['CIRCLE_PROJECT_USERNAME']
    repo = os.environ['CIRCLE_PROJECT_REPONAME']
    commit = os.environ['CIRCLE_SHA1']
    env = os.environ.get('TF_ENV_LABEL', '')

    print(get(owner, repo, commit, module_path, workspace, env))
