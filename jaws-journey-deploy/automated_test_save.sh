#!/bin/bash
set -eu
mkdir -p ~/test-results/junit/
find . -type f -regex ".*/build/test-results/.*xml" -exec cp {} ~/test-results/junit/ \;
