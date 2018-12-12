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


def delete_plan(owner: str, repo: str, pr: int, label: str) -> None:
    response = session.get(f'{HOST}/repos/{owner}/{repo}/pulls/{pr}')
    response.raise_for_status()

    issue_url = response.json()['_links']['issue']['href'] + '/comments'
    response = session.get(issue_url)
    response.raise_for_status()

    for comment in response.json():
        if comment['user']['login'] == github_username:
            match = re.match(rf'{label}\n```.*```', comment['body'], re.DOTALL)

            if match:
                session.delete(comment['url'])
                return


def add_plan(owner: str, repo: str, pr: int, label: str, plan: str) -> None:

    comment = f'{label}\n```\n{plan}\n```'

    response = session.get(f'{HOST}/repos/{owner}/{repo}/pulls/{pr}')
    response.raise_for_status()

    issue_url = response.json()['_links']['issue']['href'] + '/comments'

    response = session.post(issue_url, json={'body': comment})
    response.raise_for_status()


def put(owner: str, repo: str, pr: int, module_path: str, workspace: str, env: str) -> None:

    label = f'Terraform plan for {module_path} in the {workspace} workspace'
    if env:
        label = f'Terraform plan for __{env}__'

    delete_plan(owner, repo, pr, label)
    add_plan(owner, repo, pr, label, sys.stdin.read().strip())


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print(f'Usage:\n\t{sys.argv[0]} <module_path> [<workspace>] < plan.txt')
        exit(-1)

    module_path = sys.argv[1]
    workspace = sys.argv[2] if len(sys.argv) >= 3 else 'default'

    owner = os.environ['CIRCLE_PROJECT_USERNAME']
    repo = os.environ['CIRCLE_PROJECT_REPONAME']
    pr = os.environ['CIRCLE_PR_NUMBER']
    env = os.environ.get('TF_ENV_LABEL', '')

    put(owner, repo, int(pr), module_path, workspace, env)
