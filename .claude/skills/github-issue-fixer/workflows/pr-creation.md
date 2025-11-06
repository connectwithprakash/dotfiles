# PR Creation Workflow

## Purpose
Create a well-documented pull request linked to the issue.

## Pre-PR Checklist

- [ ] All tests pass
- [ ] Linting passes
- [ ] Build succeeds
- [ ] Code reviewed personally
- [ ] Commit messages follow convention
- [ ] Branch pushed to remote

## Commit Message Format

### Check Project Convention
```bash
# Look at recent commits
git log --oneline -10

# Common formats:
# [Type]: description
# type: description
# type(scope): description
```

### Write Good Commit Message
```
[Type]: Short summary (max 72 chars)

Longer explanation of what changed and why (not how).
Wrap at 72 characters per line.

Fixes #123
```

### Types
- **Fix**: Bug fixes
- **Feat**: New features
- **Refactor**: Code improvements without functionality change
- **Test**: Test additions or changes
- **Docs**: Documentation updates
- **Chore**: Maintenance tasks

## Create PR

### Using gh CLI
```bash
gh pr create \
  --title "[Fix]: Descriptive title" \
  --body "$(cat <<'EOF'
## Summary
Brief description of what this PR does

## Related Issues
Fixes #123
Relates to #456

## Changes
- Major change 1
- Major change 2
- Additional changes

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] No regressions detected

## Breaking Changes
[If any, describe here with migration steps]

## Screenshots
[If applicable, for UI changes]

## Additional Notes
[Any other relevant information]
EOF
)"
```

### PR Title Format
Follow project conventions:
- `[Fix]: Resolve memory leak in data processor`
- `[Feat]: Add user authentication`
- `fix: correct validation logic`

## Post-PR Actions

### Link to Issue
Ensure PR description includes:
- `Fixes #123` (closes issue when PR merges)
- `Closes #123` (alternative syntax)
- `Resolves #123` (alternative syntax)

### Add Labels
```bash
gh pr edit {PR_NUMBER} --add-label "bug,priority-high"
```

### Request Reviewers
```bash
gh pr edit {PR_NUMBER} --add-reviewer @username
```

### Add to Project
```bash
gh pr edit {PR_NUMBER} --add-project "Sprint Board"
```

### Monitor CI
```bash
gh pr checks {PR_NUMBER} --watch
```

## Update Issue

```bash
gh issue comment {ISSUE_NUMBER} --body "Implementation completed in PR #{PR_NUMBER}.

## Changes Made
- Summary of implementation
- Key decisions made
- Any trade-offs considered

## Testing Added
- Description of test coverage
- Manual testing performed

Ready for review!"
```

## PR Best Practices

### Do
- Write clear, descriptive title
- Explain WHAT and WHY in description
- Link to related issues
- Include testing notes
- Add screenshots for UI changes
- Request specific reviewers if needed
- Respond to feedback promptly

### Don't
- Create PRs with failing tests
- Skip the description
- Forget to link issues
- Push directly to main/master
- Include unrelated changes
- Mention AI tools in commit/PR
- Use vague titles like "Fix bug"

## Success Criteria

- [ ] PR created successfully
- [ ] Linked to issue with "Fixes #"
- [ ] Clear title and description
- [ ] All CI checks passing
- [ ] Reviewers requested
- [ ] Labels applied
- [ ] Issue commented with PR link
