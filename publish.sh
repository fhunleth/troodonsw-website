#!/bin/sh

# This script assumes that a .s3cmd has been made with the access key

if [ ! -e index.html ]; then
	echo "Run from the directory with the root index.html"
	exit 1
fi

# Clean up untracked files
git status
git clean -ndx
echo "Ok to cleanup?"
read UNUSED
git clean -fdx

# Uncomment to do a dry run
#DRYRUN=--dry-run

s3cmd sync $DRYRUN -P -r -v --reduced-redundancy --delete-removed \
    --no-mime-magic --guess-mime-type \
    --exclude=".git/*" --exclude="publish.sh" \
    --exclude=".gitignore" --exclude="README.md" \
    ./ s3://www.troodon-software.com/

