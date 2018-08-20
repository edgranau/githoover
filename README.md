# GitHoover

> Bash script to help you copy/migrate all the repos (inc branches/tags) from one GH org to another

## Description

This script will attempt to:

- create a new directory with `SOURCE_ORG` name and `cd` into it
- clone all the repos (including branches/tags) from `SOURCE_ORG`
- for each _non empty_ repo:
  - update the name of the repo if it doesn't start with `PREFIX`
  - create an empty repo in `TARGET_ORG` with the updated name
  - update the local repo's `remote origin` to point to new repo in `TARGET_ORG`
  - push all branches/tags from local repo to new remote

## Assumptions

- Your github account is a member of both `SOURCE_ORG` and `TARGET_ORG`
- Migrated repos' names will be `PREFIX-ORIGINAL_NAME`

## Dependencies

This script uses [jq](https://stedolan.github.io/jq/download/) under the hood to parse response json payloads

You need to have access to both repositories and create an access token for your account. This token needs to have repo (Full control of private repositories) scope. see [github documentation here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

## Usage

```shell
bash githoover.sh
```

## Note

If your repos have pull requests made to them, you will see errors like this:

```txt
 ! [remote rejected] refs/pull/1/head -> refs/pull/1/head (deny updating a hidden ref)
```

See [this](https://stackoverflow.com/questions/34265266/remote-rejected-errors-after-mirroring-a-git-repository) for more information.
