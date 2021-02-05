import re
import textwrap


def re_comment_match(comment_id, comment_body):
    """Returns a Match object, or None if no match was found"""
    return re.match(rf'{re.escape(comment_id)}\n```(?:hcl)?(.*?)```(.*)',
                    comment_body, re.DOTALL)


def comment_for_pr(comment_id, plan):
    """Returns a formatted string containing comment_id and plan"""
    return textwrap.dedent(f"""\
    {comment_id}
    <details open>
    <summary>Plan</summary>
    
    ```hcl
    {plan}
    ```
    </details>
    """)
