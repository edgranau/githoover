# GitHoover

> Bash script to help you copy/migrate all the repos (inc branches/tags) from one GH org to another

## Description

This script will attempt to:

- create a new directory with `SOURCE_ORG` name and `cd` into it
- clone all the repos (including branches/tags) from `SOURCE_ORG`
- for each _non empty_ repo:
  - update the name of the repo if it doesn't start with `PREFIX`
  - create an empty repo in `TARGET_ORG` with the updated name and grants `TEAM_NAME` access to it
  - update the local repo's `remote origin` to point to new repo in `TARGET_ORG`
  - push all branches/tags from local repo to new remote

## Assumptions

- Your github account is a member of both `SOURCE_ORG` and `TARGET_ORG`
- Migrated repos' names will be `PREFIX-ORIGINAL_NAME`
- `TEAM_NAME` exists in `TARGET_ORG`

## Dependencies

This script uses [jq](https://stedolan.github.io/jq/download/) under the hood to parse response json payloads

You need to have access to both repositories and create an access token for your account. This token needs to have :

- `repo`: Grants read/write access to code, commit statuses, invitations, collaborators, adding team memberships, and deployment statuses for public and private repositories and organizations
- `read:org`: Read-only access to organization, teams, and membership

See [github documentation here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

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

## References

- [caniszczyk/clone-all-twitter-github-repos.sh](https://gist.github.com/caniszczyk/3856584)
- [GitHub REST API (Orgs)](https://developer.github.com/v3/orgs/)
- [Traversing with Pagination](https://developer.github.com/v3/guides/traversing-with-pagination/)
- [Understanding scopes for OAuth Apps](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)
- [ShellCheck](https://www.shellcheck.net/)
