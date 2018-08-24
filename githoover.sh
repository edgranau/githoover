#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

START_TIME=$(date +%s)

echo "Enter Source Org (eg: old-org): "
read -r SOURCE_ORG
echo "Enter Target Org (eg: new-org): "
read -r TARGET_ORG
echo "Enter TOKEN: "
read -r TOKEN
echo "Enter Repo Prefix (eg: oldorg): "
read -r PREFIX

mkdir "$SOURCE_ORG"
pushd "$SOURCE_ORG"

LAST_PAGE=$(curl -I -f -s "https://$TOKEN:@api.github.com/orgs/$SOURCE_ORG/repos?per_page=100" | grep ^Link | sed -E 's/.*page=([0-9]+)>; rel="last"/\1/g' | sed -E 's/[^a-zA-Z0-9]//g')
LAST_PAGE=$((LAST_PAGE||1))
for PAGE in $(seq $LAST_PAGE); do
    curl -f -s "https://$TOKEN:@api.github.com/orgs/$SOURCE_ORG/repos?per_page=100&page=$PAGE" | jq '.[].ssh_url' | sed -E 's/.*\/(.*)\.git/&,\1\/\.git/g' | sed -E $'s/,/\\\n/g' | sed -E 's/"//g' | xargs -n 2 git clone -q --mirror
done

SKIPPED=0
MIGRATED=0

for d in */ ; do
    echo "$d"
    pushd "$d"
    git config --bool core.bare false
    git checkout -q
    CURRENT_NAME="$(basename "$PWD")"
    NEW_NAME=""
    if [[ "$(ls -A .)" =~ ^.git$ ]]; then
        # ignore empty repo
        echo "=>SKIP"
        SKIPPED=$((SKIPPED + 1))
    else
        if [[ "$CURRENT_NAME" =~ ^$PREFIX.* ]]; then
            NEW_NAME=$CURRENT_NAME
        else
            # add prefix to repo name if not present
            NEW_NAME="$PREFIX-$CURRENT_NAME"
        fi
        echo "=>$NEW_NAME"
        # create new repo in target_org and use returned ssh_url to update remote in local copy of repo
        curl -f -s -H 'content-type: application/json' -d "{ \"name\": \"$NEW_NAME\", \"private\": true }" "https://$TOKEN:@api.github.com/orgs/$TARGET_ORG/repos" | jq ".ssh_url" | xargs -n 1 git remote set-url origin
        git push --mirror -u -q origin
        MIGRATED=$((MIGRATED + 1))
    fi
    popd
done
popd
END_TIME=$(date +%s)
echo "$SKIPPED empty repo(s) skipped, $MIGRATED repo(s) migrated successfuly in $((END_TIME - START_TIME)) seconds"
