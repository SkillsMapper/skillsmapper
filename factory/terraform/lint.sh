find . -type f -name "*.tf" -exec dirname {} \; | sort -u | xargs -I % tflint --chdir=%
