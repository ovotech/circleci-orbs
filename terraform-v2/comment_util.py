import re


def re_comment_match(comment_id, comment_body):
    """Returns a Match object, or None if no match was found"""
    return re.match(rf'{re.escape(comment_id)}\n```(?:hcl)?(.*?)```(.*)',
                    comment_body, re.DOTALL)


def comment_for_pr(comment_id, plan):
    """Returns a formatted markdown string containing comment_id and plan"""
    return f'{comment_id}\n<details>\n<summary>View Terraform Plan</summary>\n\n```terraform\nOutput is limited to 1000 lines and may be truncated. See CircleCI for full details.\n{plan}```\n</details>'
