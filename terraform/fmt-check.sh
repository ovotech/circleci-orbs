if terraform fmt -help | grep -e "-recursive" >/dev/null; then

    # The default recursive behaviour of terraform fmt was changed in 0.12 - and the added 'recursive' flag
    # does not implement the old behavior, so we'll do it ourselves...

    EXIT_CODE=0

    for dir in $(find "$module_path" -type d);
    do
      # Not using chdir here as the terraform provider lock behaviour
      # doesn't affect terraform fmt and otherwise we would need to check
      # the terraform version is >= 0.14
      if ! terraform fmt -no-color -check -diff "$dir"; then
        EXIT_CODE=1
      fi
    done

    exit $EXIT_CODE

else
    terraform "$chdir" fmt -no-color -check -diff $config_path
fi
