import csv, glob, sys, json, requests, re, os

LINE_MISSED = 7
LINE_COVERED = 8
BRANCH_MISSED = 5
BRANCH_COVERED = 6

github_username = os.environ['GITHUB_BOT_USERNAME']
github_token = os.environ['GITHUB_BOT_PACKAGE_MANAGER_TOKEN']
owner = os.environ['CIRCLE_PROJECT_USERNAME']
repo = os.environ['CIRCLE_PROJECT_REPONAME']
build_number = os.environ['CIRCLE_BUILD_NUM']
pr_number = "/0"
commit = os.environ['CIRCLE_SHA1']

class CoverageComment:
    def __init__(self, path, comment_header, github_repo_id):
        self._path = path
        self._github_repo_id = github_repo_id
        self._comment = f"{comment_header}\n| Project | Line Coverage | Branch Coverage |\n| ------- | -------------------- | -------------------- |\n"
        self.generate_report_csv()
        self.generate_report_json()

    @property
    def comment(self):
        return self._comment

    def generate_report_csv(self):
        reports = glob.glob(f"{self._path}/*.csv")

        for report in reports:
            with open(report) as csvfile:
                report_reader = csv.reader(csvfile, delimiter=',')
                instructions, instructions_covered = 0, 0
                branches, branches_covered = 0, 0

                next(report_reader, None)
                for row in report_reader:
                    instructions, instructions_covered = self.get_stats(instructions, instructions_covered,
                                                                        row, LINE_COVERED, LINE_MISSED)
                    branches, branches_covered = self.get_stats(branches, branches_covered, row, BRANCH_COVERED, BRANCH_MISSED)

                filename = self.get_filename(report, '.csv')
                url = self.create_url(f'{filename.replace(":", "%3A")}/html/index.html')
                self._comment += self.create_line(filename, url,
                                                  self.calc_percentage(instructions_covered, instructions),
                                                  self.calc_percentage(branches_covered, branches))

    def get_stats(self, total, covered, row, covered_idx, missed_idx):
        return (total + int(row[covered_idx]) + int(row[missed_idx])), (covered + int(row[covered_idx]))

    def generate_report_json(self):
        reports = glob.glob(f"{self._path}/*.json")

        for report in reports:
            with open(report) as jsonfile:
                total_stats = json.load(jsonfile)["totals"]
                filename = self.get_filename(report, '.json')
                url = self.create_url(f'{filename}/index.html')
                self._comment += self.create_line(filename, url,
                            round(self.calc_percentage(total_stats["covered_lines"], total_stats["num_statements"]), 2),
                            round(self.calc_percentage(total_stats["covered_branches"], total_stats["num_branches"]), 2))

    def create_line(self, filename, url, line_percentage, branch_percentage):
        return f'| [{filename}]({url}) | { line_percentage }% | { branch_percentage }%|\n'

    def get_filename(self, file, extension):
        return file.split("/")[-1].replace(extension, "")

    def calc_percentage(self, x, total):
        if(total > 0):
            return round((x / total) * 100, 2)
        else:
            return round(0 * 100, 2)

    def create_url(self, project):
        return f'https://{build_number}-{self._github_repo_id}-gh.circle-artifacts.com/0/{self._path}/{project}'


class GithubClient:
    def __init__(self, identifier):
        self._github = requests.Session()
        self._github.auth = (github_username, github_token)
        self._pr_url = self.find_pr()
        response = self._github.get(self._pr_url)
        response.raise_for_status()

        self._issue_url = response.json()['_links']['issue']['href'] + '/comments'
        self._github_repo_id = response.json()['head']['repo']['id']
        response = self._github.get(self._issue_url)
        response.raise_for_status()

        self._comment_url = None
        self.find_comment(identifier, response)

    @property
    def github_repo_id(self):
        return self._github_repo_id

    def find_pr(self):
        """
        Find the PR for this commit and return the API url
        """

        if pr_number:
            response = self._github.get(f'https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}')
            response.raise_for_status()
            return response.json()['url']

        for pr in self.prs():
            if pr['merge_commit_sha'] == commit:
                return pr['url']

        raise Exception(f'No PR found in {owner}/{repo} for commit {commit} (was it pushed directly to the target branch?)')

    def prs(self):
        url = f'https://api.github.com/repos/{owner}/{repo}/pulls'

        while True:
            response = self._github.get(url, params={'state': 'all'})
            response.raise_for_status()

            for pr in response.json():
                yield pr

            if 'next' in response.links:
                url = response.links['next']['url']
            else:
                return

    def find_comment(self, identifier, response):
        for comment in response.json():
            if comment['user']['login'] == github_username:

                match = re.match(rf'{re.escape(identifier)}\n(.*?)', comment['body'], re.DOTALL)
                if match:
                    self._comment_url = comment['url']
                    return

    def write_comment(self, comment):
        if self._comment_url is None:
            # Create a new comment
            response = self._github.post(self._issue_url, json={'body': comment})
        else:
            # Update existing comment
            response = self._github.patch(self._comment_url, json={'body': comment})

        response.raise_for_status()
        self._comment_url = response.json()['url']

if __name__ == '__main__':
    if (len(sys.argv)) < 2:
        print('Usage requires a path')
        quit()

    try:
        pr_number = os.environ['CIRCLE_PULL_REQUEST'].split('/')[-1]
    except KeyError as e:
        quit()

    path = sys.argv[1]
    comment_header = "## Code Coverage Report"
    github = GithubClient(comment_header)
    comment = CoverageComment(path, comment_header, github.github_repo_id)
    github.write_comment(comment.comment)
