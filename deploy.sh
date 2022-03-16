#!/bin/bash
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

hugo -D

msg="rebuilding site $(date)"

if [ -n "$*" ]; then
	msg="$*"
fi

echo "$msg"
echo "Committing changes to $(pwd)"

git add .
git commit -m "$msg"
git push origin main
