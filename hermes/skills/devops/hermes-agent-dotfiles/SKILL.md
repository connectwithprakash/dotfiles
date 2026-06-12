---
name: hermes-agent-dotfiles
description: Safely manage Hermes Agent configuration and skills inside a dotfiles repository without leaking secrets or breaking the live profile.
category: devops
---

# Hermes Agent Dotfiles Management

Use when syncing Hermes-related files in `~/Developer/dotfiles/hermes/` with the live default profile under `~/.hermes/`.

## Safety principles

- Treat `~/.hermes/config.yaml` as live state. Back it up before changing it.
- Keep secrets in `~/.hermes/.env`, OAuth stores, or provider-specific auth files — not in git.
- Never commit API keys, bearer tokens, OAuth tokens, passwords, or private keys.
- Do not blindly symlink `~/.hermes/config.yaml` to the repo. Only link it after reviewing the repo config and intentionally choosing repo-as-source-of-truth.
- Skills are safer to manage from dotfiles than the full live config, but still review them like code because they affect future agent behavior.

## Recommended workflow

1. Work in the dotfiles repo:
   ```bash
   cd ~/Developer/dotfiles
   git fetch --prune
   git status --short --branch
   ```
2. Create a cleanup branch for nontrivial changes:
   ```bash
   git switch -c chore/sync-dotfiles-state
   ```
3. Bring in remote changes safely:
   ```bash
   git merge --ff-only origin/main
   ```
4. Before syncing Hermes config, migrate and validate the live config with official Hermes commands:
   ```bash
   cp ~/.hermes/config.yaml ~/.hermes/config.yaml.backup.$(date +%Y%m%d%H%M%S)
   hermes config migrate
   hermes config check
   hermes doctor
   ```
5. If committing `hermes/config.yaml`, scan for secrets before staging:
   ```bash
   git diff --check
   rg -n "(?i)(api[_-]?key|token|secret|password|bearer|authorization|private[_-]?key)" hermes/config.yaml
   ```
   Inspect hits manually. Placeholder/empty fields are okay; real credentials are not.
6. Prefer the safe installer behavior:
   ```bash
   ./hermes/install.sh
   ./hermes/test-safe.sh
   ```
   This should link managed skills and leave live config untouched.
7. Only if the repo config has been reviewed and should become source-of-truth:
   ```bash
   ./hermes/install.sh --link-config
   ```
   The installer must back up the existing live config first.
8. Verify before pushing:
   ```bash
   make test
   ./dotfiles status
   ./dotfiles health
   git status --short --branch
   ```

## Commit and push

After review and passing checks:

```bash
git add <reviewed files>
git commit -m "chore(dotfiles): sync local state and harden tests"
git switch main
git merge --ff-only <branch>
git push origin main
git fetch --prune
git status --short --branch
git rev-list --left-right --count @{u}...HEAD
```

A clean final state should show `0 0` divergence and `./dotfiles status` should report both repository clean and all dotfiles synced.

## Pitfalls

- `make test` must not swallow missing `shellcheck`; the Makefile should fail clearly if required lint tools are absent.
- `brew bundle check` can fail because installed packages are outdated, not just missing. Do not run broad upgrades unless that is intended.
- Homebrew 6+ may require tap trust for third-party taps; do not blanket-trust taps without user intent.
- Machine-specific PATH entries may belong in `~/.path` or `~/.extra` rather than portable shared files.
- If `hermes doctor` reports config version drift, use `hermes config migrate` rather than hand-editing unknown new schema fields.
