# OceanKeySwift Backup Runbook

## Current Remote

- GitHub repository: `https://github.com/axrbarsic/OceanKeySwift`
- Visibility: private
- Default branch: `main`
- Local remote name: `origin`

## Checkpoint Rule

After each coherent app block:

1. Commit the verified local work.
2. Push `main` to `origin`.
3. For installed builds, add or update a build tag such as `build-128` and push
   the tag.
4. Keep a local bundle backup before risky remote/history work.

## Commands

```sh
git status --short --branch
git push origin main
git tag -a build-128 -m "Verified iPhone build 128" <commit>
git push origin build-128
mkdir -p /Users/alex/Developer/_git-bundles
git bundle create /Users/alex/Developer/_git-bundles/OceanKeySwift-main-$(date +%Y%m%d-%H%M%S).bundle --all
```

## Restore From GitHub

```sh
git clone https://github.com/axrbarsic/OceanKeySwift.git
cd OceanKeySwift
git checkout main
```

## Restore From Local Bundle

```sh
git clone /Users/alex/Developer/_git-bundles/<bundle-file>.bundle OceanKeySwift-restore
cd OceanKeySwift-restore
git checkout main
```

## GitHub Limitation

GitHub branch protection for this private repository currently requires GitHub
Pro or a public repository. Because this app should stay private, rely on
regular pushes, build tags, and local bundles until branch protection is
available.
