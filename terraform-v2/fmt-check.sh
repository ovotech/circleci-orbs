set -x

for dir in $(find "$module_path" -type d);
  do
    if ! terraform fmt -no-color -check -diff "$dir"; then
      EXIT_CODE=1
    fi
  done

  exit $EXIT_CODE

