#!/bin/sh
GIT_COMMITTER_DATE=$1
git commit --date="$1" -m "$2"
