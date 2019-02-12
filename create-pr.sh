#!/bin/bash
echo "##################################################"
set -e
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Undefined GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ "$(jq -r ".head_commit" "$GITHUB_EVENT_PATH")" == "null" ]]; then
  echo "This push has not commits!"
  exit 78
fi

if [[ "$1" != "" && "$2" != "" ]];  then
    data="$(jq -r "$1" "$GITHUB_EVENT_PATH")"
    regex="^$2$"
    echo "Condition:
    data  : $data
    regex : $regex
    "
    condition=$(echo $data | grep $regex | wc -l )
    if [[ "$condition" == "0" ]]; then
      echo "Negative condition. Stopping program"
      exit 78;
    else
      echo "Positive condition result. Continue"
    fi
fi

COMMIT_MESSAGE="$(jq -r ".head_commit.message" "$GITHUB_EVENT_PATH")"
REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
DEFAULT_BRANCH=$(jq -r ".repository.default_branch" "$GITHUB_EVENT_PATH")

echo "Creating new PR:
message : $COMMIT_MESSAGE
repo    : $REPO_FULLNAME
"

RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" \
 --data "{\"title\":\"$COMMIT_MESSAGE\", \"head\": \"$GITHUB_REF\", \"base\": \"$DEFAULT_BRANCH\"}" \
 -X POST \
 -H "Authorization: token $GITHUB_TOKEN" \
 -H "Accept: application/vnd.github.v3+json" \
 "https://api.github.com/repos/$REPO_FULLNAME/pulls")

echo "RESPONSE_CODE: $RESPONSE_CODE"
echo "##################################################"