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
        m = re.match(_build_regex(tmpl), "\n".join(comment_body.splitlines()), re.DOTALL)
        if m is not None:
            return m

    return None


def comment_for_pr(comment_id, plan):
    """Returns a formatted string containing comment_id and plan"""
    return f'{comment_id}\n{current_template.format(plan=plan)}'
