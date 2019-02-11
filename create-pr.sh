#!/bin/bash
echo "##################################################"
set -e
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Undefined GITHUB_TOKEN environment variable."
  exit 1
fi
ACTION="$(jq -r ".action" "$GITHUB_EVENT_PATH")";
echo "Github action id: ${ACTION}";
if [[ "$(jq -r ".created" "$GITHUB_EVENT_PATH")" != true ]]; then
  echo "This is not a create push branch!"
  exit 2
fi

if [[ "$(jq -r ".head_commit" "$GITHUB_EVENT_PATH")" == "null" ]]; then
  echo "This push has not commits!"
  exit 3
fi

if [[ "$1" != "" && "$2" != "" ]];  then
    value="$(jq -r "$1" "$GITHUB_EVENT_PATH")"
    condition=$(echo $value | grep "$2" | wc -l )
    if [[ "$condition" == "0" ]]; then
      echo "Negative condition. Stopping program"
      exit 0;
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

URI=https://api.github.com
PULLS_URI="${URI}/repos/$REPO_FULLNAME/pulls"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

new_pr_resp=$(curl \
 --data "{\"title\":\"$COMMIT_MESSAGE\", \"head\": \"$GITHUB_REF\", \"base\": \"$DEFAULT_BRANCH\"}" \
 -X POST \
 -s \
 -H "${AUTH_HEADER}" -H "Accept: application/vnd.github.v3+json" \
 ${PULLS_URI})

echo "$response"
echo "##################################################"