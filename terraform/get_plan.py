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
            return pr

    raise Exception(f'No PR found in {owner}/{repo} for commit {commit}')


def find_plan(owner: str, repo: str, pr: dict, label: str) -> str:

    response = session.get(pr['comments_url'])
    response.raise_for_status()

    for comment in response.json():
        if comment['user']['login'] == github_username:

            match = re.match(rf'{ re.escape(label) }\n```(.*)```', comment['body'], re.DOTALL)

            if match:
                plan = match.group(1)
                return plan.strip()

    raise Exception(f'No plan found in {owner}/{repo}#{pr["number"]} with label {label!r}')


def create_label(module_path, workspace, env, init_args, plan_args):
    if env:
        return f'Terraform plan for __{env}__'

    label = f'Terraform plan for {module_path} in the {workspace} workspace'

    if init_args:
        label += f'\nUsing init args: `{init_args}`'
    if plan_args:
        label += f'\nUsing plan args: `{plan_args}`'

    return label


def get(owner: str, repo: str, commit: str, label: str) -> str:
    pr = find_pr(owner, repo, commit)
    return find_plan(owner, repo, pr, label)


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print(f'Usage:\n\t{sys.argv[0]} <module_path> [<workspace>] [<init-args>]  [<plan-args]')
        exit(-1)

    module_path = sys.argv[1]
    workspace = sys.argv[2] if len(sys.argv) >= 3 else 'default'
    init_args = sys.argv[3] if len(sys.argv) >= 4 else ''
    plan_args = sys.argv[4] if len(sys.argv) >= 5 else ''

    owner = os.environ['CIRCLE_PROJECT_USERNAME']
    repo = os.environ['CIRCLE_PROJECT_REPONAME']
    commit = os.environ['CIRCLE_SHA1']
    env = os.environ.get('TF_ENV_LABEL', '')

    label = create_label(module_path, workspace, env, init_args, plan_args)

    print(get(owner, repo, commit, label))
