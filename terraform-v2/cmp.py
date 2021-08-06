#!/usr/bin/env python3

import sys
import re

with open(sys.argv[1], encoding='utf-8') as f:
    first = f.read()
with open(sys.argv[2], encoding='utf-8') as f:
    second = f.read()

# Sanitize AWS computed RDS attribute. See commit message.
# Other attributes may need to be added in future.
# Ref: https://github.com/hashicorp/terraform/issues/28803
first = re.sub(r"(?m)^\s+~ latest_restorable_time\s+=.+$", "", first.strip())
second = re.sub(r"(?m)^\s+~ latest_restorable_time\s+=.+$", "", second.strip())

if first == second:
    exit(0)

exit(1)
