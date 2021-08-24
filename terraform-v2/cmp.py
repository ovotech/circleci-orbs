#!/usr/bin/env python3

import difflib
import sys

with open(sys.argv[1], encoding='utf-8') as f:
    generated_plan = f.readlines()
with open(sys.argv[2], encoding='utf-8') as f:
    plan_from_pr = f.readlines()

diff = list(difflib.ndiff(generated_plan, plan_from_pr))
non_matching_lines = [line for line in diff if line[0] != ' ']
if non_matching_lines:
    print("Plan has changed!")
    print("".join(diff))
    exit(1)
else:
    exit(0)
