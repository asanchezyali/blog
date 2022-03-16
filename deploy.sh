#!/bin/bash

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

msg="$1 - $(date)"

if [ -n "$*" ]; then
	msg="$*"
fi

echo "$msg"
echo "Committing changes to $(pwd)"
git add .
git commit -m "$msg"
git push origin main
