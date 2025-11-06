---
description: "Fix GitHub issues end-to-end from exploration to PR creation. Use when user mentions 'fix issue', 'implement issue', 'work on issue', or provides an issue number."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "TodoWrite"]
---

# GitHub Issue Fixer

Systematically fix GitHub issues with a complete workflow from exploration to pull request creation.

## When to Use This Skill

Activate when user:
- Mentions "fix issue", "fix GitHub issue", "work on issue"
- Provides an issue number (e.g., "fix issue 456", "let's tackle #456")
- Says "implement the feature in issue X"
- Asks to "resolve issue" or "address issue"

## Core Workflow

### 1. Fetch Issue Details

**Get Full Issue Information:**
```bash
# View complete issue details
gh issue view {ISSUE_NUMBER} --json title,body,labels,assignees,milestone,url

# Check for linked PRs or issues
gh issue view {ISSUE_NUMBER} --json projectItems
```

**Parse Issue Content:**
- Extract problem description
- Identify acceptance criteria
- Note any linked PRs or related issues
- Check labels for priority/type
- Review comments for additional context

### 2. Explore the Codebase

**Search Strategy:**
```bash
# Find files mentioned in issue
# Use Grep to search for related patterns
# Read configuration files
# Check for similar implementations
```

**Context Gathering:**
- Identify relevant modules/components
- Read existing tests for patterns
- Check CLAUDE.md for project conventions
- Review related code for implementation patterns

**Use Task Tool for Complex Searches:**
- For open-ended exploration, use Task tool with subagent_type=Explore
- Set thoroughness level: "medium" for most cases
- Example: "Find all authentication-related code" → use Explore agent

### 3. Create Implementation Plan

**Use TodoWrite to Plan:**
```
1. Understand requirements from issue
2. Identify files to modify
3. Plan test coverage
4. Note dependencies or impacts
5. Define validation steps
```

**Plan Components:**
- Files that need modification
- New files to create (if any)
- Tests to add/update
- Documentation updates needed
- Potential breaking changes
- Dependencies to consider

### 4. Implement the Solution

**Branch Creation:**
```bash
# Create descriptive branch name
git checkout -b fix/issue-{ISSUE_NUMBER}-{short-description}

# Examples:
# fix/issue-123-add-input-validation
# fix/issue-456-resolve-memory-leak
```

**Implementation Guidelines:**
- Follow existing code patterns in the project
- Check CLAUDE.md for style guidelines
- Keep changes focused on the issue
- Write self-documenting code with clear variable names
- Add comments for complex logic

**Testing:**
- Add unit tests for new functionality
- Update existing tests if behavior changes
- Include edge case testing
- Follow project's testing conventions

### 5. Validate the Fix

**Run Quality Checks:**
```bash
# Find and run test command
# Common patterns:
npm test
pytest
make test
cargo test

# Run linting
npm run lint
make lint
ruff check .
cargo clippy

# Build if applicable
npm run build
make build
cargo build
```

**Manual Testing:**
- Test the specific issue scenario
- Verify acceptance criteria met
- Test edge cases
- Check for regressions

### 6. Create Pull Request

**Commit with Conventional Format:**
```bash
# Follow project commit convention
# Check recent commits for format: git log --oneline -5

# Example formats:
git commit -m "[Fix]: resolve memory leak in data processor

Fixes issue where connections were not properly closed after
processing, causing memory to accumulate over time.

Fixes #123"
```

**Push and Create PR:**
```bash
# Push branch to remote
git push -u origin fix/issue-{ISSUE_NUMBER}-{description}

# Create PR with gh CLI
gh pr create --title "[Fix]: {description}" --body "$(cat <<'EOF'
## Summary
Brief description of the fix

## Related Issues
Fixes #{ISSUE_NUMBER}

## Changes
- Change 1
- Change 2

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No regressions detected

## Additional Notes
Any relevant context or considerations
EOF
)"
```

**PR Best Practices:**
- Link PR to issue using "Fixes #123" in description
- Include clear summary of changes
- Note any breaking changes
- Mention testing performed
- Add screenshots for UI changes

### 7. Update Issue

**Comment on Issue:**
```bash
gh issue comment {ISSUE_NUMBER} --body "Implementation completed in PR #{PR_NUMBER}.

Changes:
- Summary of what was done
- Any noteworthy decisions

Tests added:
- Test coverage details

Ready for review."
```

## Workflow Steps Summary

1. **Fetch**: Get issue details with `gh issue view`
2. **Explore**: Search codebase for context (use Task tool for complex exploration)
3. **Plan**: Break down with TodoWrite
4. **Implement**: Create branch, write code, add tests
5. **Validate**: Run tests, linting, build
6. **PR**: Commit, push, create PR with `gh pr create`
7. **Update**: Comment on issue with implementation details

## Important Guidelines

### What to Do
- Check for related issues or duplicate PRs first
- Follow project's contribution guidelines (check CONTRIBUTING.md)
- Ensure all CI checks pass before marking ready
- Keep commits atomic and well-described
- Write tests that cover the fix
- Update documentation if needed

### What NOT to Do
- Don't start coding before understanding the issue fully
- Don't skip testing or validation steps
- Don't create PRs with failing tests
- Don't ignore project conventions
- Don't push directly to main/master branch
- Don't mention AI tools or code generation in commits

### Commit Message Format

Follow project conventions:
- Check recent commits: `git log --oneline -5`
- Common format: `[Type]: description`
- Types: Fix, Feat, Refactor, Test, Docs, Chore
- Focus on WHAT and WHY, not HOW
- Never mention Claude or AI tools

### Error Handling

If issues occur:
- **Tests fail**: Fix the code or update tests
- **Lint errors**: Address all linting issues
- **Build fails**: Resolve build errors before PR
- **Merge conflicts**: Rebase on latest base branch
- **CI failures**: Debug and fix before requesting review

## Success Criteria

A successful issue fix includes:
1. Issue fully understood and requirements clear
2. Implementation follows project patterns
3. Comprehensive test coverage added
4. All quality checks pass (tests, lint, build)
5. PR created and linked to issue
6. Clear documentation of changes
7. Issue commented with implementation details

## Notes

- This skill orchestrates the complete issue-to-PR workflow
- It works alongside code-reviewer and pr-review-responder skills
- Always maintain human oversight at key decision points
- Use TodoWrite to track progress through the workflow
- Keep the user informed at each major step
