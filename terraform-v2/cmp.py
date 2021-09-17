#!/usr/bin/env python3

import difflib
import sys
import re

with open(sys.argv[1], encoding="utf-8") as f:
    generated_plan = f.read()
with open(sys.argv[2], encoding="utf-8") as f:
    plan_from_pr = f.read()

# Sanitize AWS computed RDS attribute. See commit message.
# Other attributes may need to be added in future.
# Ref: https://github.com/hashicorp/terraform/issues/28803
generated_plan = re.sub(
    r"(?m)^\s+~ latest_restorable_time\s+=.+$", "", generated_plan.strip()
)
plan_from_pr = re.sub(
    r"(?m)^\s+~ latest_restorable_time\s+=.+$", "", plan_from_pr.strip()
)

diff = list(
    difflib.ndiff(
        generated_plan.splitlines(keepends=True), plan_from_pr.splitlines(keepends=True)
    )
)
non_matching_lines = [line for line in diff if line[0] != " "]
if non_matching_lines:
    print("Plan has changed!")
    print("".join(diff))
    exit(1)
else:
    exit(0)