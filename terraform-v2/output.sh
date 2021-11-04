set -x

if [ -n "<< parameters.output_path >>" ]; then
    mkdir -p "$(dirname "<< parameters.output_path >>")"
    echo "Writing output variables to << parameters.output_path >>"
    terraform -chdir=${module_path} output -json > "<< parameters.output_path >>"
fi
