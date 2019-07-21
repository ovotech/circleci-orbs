#!/usr/bin/env python3

import os
import requests

github_username = os.environ['GITHUB_USERNAME']
github_token = os.environ['GITHUB_TOKEN']
owner = os.environ['CIRCLE_PROJECT_USERNAME']
repo = os.environ['CIRCLE_PROJECT_REPONAME']
pr_number = os.environ.get('CIRCLE_PR_NUMBER')

github = requests.Session()
github.auth = (github_username, github_token)

response = github.get(f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}')
response.raise_for_status()
response = github.get(response.json()['url'])
response.raise_for_status()
issue_url = response.json()['_links']['issue']['href'] + '/comments'
response = github.get(issue_url)
response.raise_for_status()

for comment in response.json():
    if comment['user']['login'] == github_username:
        response = github.delete(comment['url'])
        response.raise_for_status()
