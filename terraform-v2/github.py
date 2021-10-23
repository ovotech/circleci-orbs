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