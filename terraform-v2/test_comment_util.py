import comment_util
import pytest


@pytest.mark.parametrize("comment_id,comment_body,match_group_one,match_group_two",
                         [
                            #  pre addition of HCL syntax formatting
                             ("<comment_id>",
                              "<comment_id>\n```\n<plan>\n```<status>",
                              "<plan>",
                              "<status>"
                             ),
                            #  post addition of HCL syntax formatting
                             ("<comment_id>",
                              "<comment_id>\n```hcl\n<plan>\n```<status>",
                              "<plan>",
                              "<status>"
                             ),
                            #  post addition of collapsible formatting
                             ("<comment_id>",
                              "<comment_id>\n<details>\n<summary>View Terraform "
                              "Plan</summary>\n\n```terraform\nOutput is limited to 1000 lines and may be truncated. "
                              "See CircleCI for full details.\n<plan>\n```\n</details>\n<status>",
                              "<plan>",
                              "<status>"
                             ),
                          ])
def test_regex_comment_match(comment_id, comment_body,
                             match_group_one, match_group_two):
    match = comment_util.re_comment_match(comment_id, comment_body)
    assert match.group(1).strip() == match_group_one
    assert match.group(2).strip() == match_group_two


def test_comment_for_pr():
    comment_for_pr = comment_util.comment_for_pr("<comment_id>", "<plan>")
    assert comment_for_pr == ("<comment_id>\n<details>\n<summary>View Terraform "
                              "Plan</summary>\n\n```terraform\nOutput is limited to 1000 lines and may be truncated. "
                              "See CircleCI for full details.\n<plan>\n```\n</details>\n")


def test_comment_match_decodes_comment_for_pr():
    id = "<comment_id>"
    plan = "<plan>"
    comment_for_pr = comment_util.comment_for_pr(id, plan)
    match = comment_util.re_comment_match(id, comment_for_pr)
    assert match.group(1).strip() == plan
    assert match.group(2).strip() == ""
