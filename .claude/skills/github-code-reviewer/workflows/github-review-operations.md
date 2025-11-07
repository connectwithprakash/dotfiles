# GitHub Code Review Operations Reference

## Fetching PR for Review

### Get PR Details
```bash
# Complete PR information
gh pr view {PR_NUMBER} --json \
  number,title,body,author,state,url,\
  baseRefName,headRefName,\
  additions,deletions,changedFiles,\
  commits,reviewDecision,reviews

# Get list of changed files
gh pr view {PR_NUMBER} --json files | jq '.files[] | {path: .path, additions: .additions, deletions: .deletions}'

# Get full diff
gh pr diff {PR_NUMBER}

# Get diff for specific file
gh pr diff {PR_NUMBER} -- path/to/file.py
```

### Get Commit Information
```bash
# List commits in PR
gh pr view {PR_NUMBER} --json commits | jq '.commits[] | {sha: .oid, message: .messageHeadline}'

# Get specific commit details
gh api repos/{owner}/{repo}/commits/{commit_sha}
```

### Check Existing Reviews
```bash
# Get all reviews on this PR
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews

# Check your previous reviews
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews | jq '.[] | select(.user.login == "your-username")'
```

## Posting Review Comments

### Single Inline Comment
```bash
# Post comment on specific line
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='Your review comment here' \
  -f commit_id='{commit_sha}' \
  -f path='src/file.py' \
  -f line=42 \
  -f side='RIGHT'

# For multi-line comment (start_line to line)
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='Your review comment here' \
  -f commit_id='{commit_sha}' \
  -f path='src/file.py' \
  -f start_line=40 \
  -f line=45 \
  -f side='RIGHT'
```

### File-Level Comment
```bash
# Comment on entire file (no line number)
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='File-level review comment' \
  -f commit_id='{commit_sha}' \
  -f path='src/file.py'
```

### Suggested Change Format
```bash
# Use GitHub's suggested change format in comment
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='```suggestion
new_code_here()
```' \
  -f commit_id='{commit_sha}' \
  -f path='src/file.py' \
  -f line=42
```

## Creating Review with Summary

### Submit Complete Review
```bash
# Submit review with COMMENT state (no blocking)
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews \
  -f body='Overall review summary here...' \
  -f event='COMMENT'

# Request changes (blocking)
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews \
  -f body='Please address these issues before merging...' \
  -f event='REQUEST_CHANGES'

# Approve PR
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews \
  -f body='Looks good to merge!' \
  -f event='APPROVE'
```

### Review with Inline Comments
```bash
# Create pending review
REVIEW_ID=$(gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews \
  -f body='Review summary' \
  -f event='PENDING' | jq -r '.id')

# Add comments to pending review
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='Comment 1' \
  -f commit_id='{commit_sha}' \
  -f path='file1.py' \
  -f line=10 \
  -f in_reply_to={REVIEW_ID}

gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='Comment 2' \
  -f commit_id='{commit_sha}' \
  -f path='file2.py' \
  -f line=20 \
  -f in_reply_to={REVIEW_ID}

# Submit the review
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews/{REVIEW_ID}/events \
  -f event='REQUEST_CHANGES'
```

## Review States

### Available States

- **COMMENT**: General feedback without approval or requesting changes
- **APPROVE**: Approve the PR for merging
- **REQUEST_CHANGES**: Request changes before the PR can be merged (blocking)

### When to Use Each

**COMMENT**:
- Suggestions and nitpicks
- Questions for clarification
- Non-blocking feedback
- Early review during development

**REQUEST_CHANGES**:
- Security vulnerabilities found
- Critical bugs identified
- Breaking changes need discussion
- Major architectural concerns

**APPROVE**:
- All issues addressed
- Code meets quality standards
- Only when explicitly ready to merge
- Use sparingly in reviews

## Checking Review Status

### Get Review Decision
```bash
# Check if PR is approved/blocked
gh pr view {PR_NUMBER} --json reviewDecision
```

### List All Reviews
```bash
# Get all reviews with state
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews | \
  jq '.[] | {user: .user.login, state: .state, submitted_at: .submitted_at}'
```

## Updating Your Review

### Dismiss Your Review
```bash
# Dismiss your previous review (if circumstances changed)
gh api -X PUT repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews/{REVIEW_ID}/dismissals \
  -f message='Dismissing due to updated changes'
```

### Re-review After Changes
```bash
# Request re-review after author makes changes
gh pr review {PR_NUMBER} --request-reviewer @yourself
```

## Best Practices

### 1. Get Latest Commit SHA
```bash
# Always use the latest commit SHA for comments
LATEST_COMMIT=$(gh pr view {PR_NUMBER} --json commits | \
  jq -r '.commits[-1].oid')

echo "Reviewing commit: $LATEST_COMMIT"
```

### 2. Batch Comments into Single Review
Instead of posting individual comments immediately, collect all comments and submit as a single review. This:
- Reduces notification spam to PR author
- Provides holistic view of feedback
- Allows you to review your comments before posting

### 3. Use Markdown Formatting
```bash
# Use code blocks
gh api -X POST ... -f body='```python
def example():
    pass
```'

# Use headings and lists
gh api -X POST ... -f body='## Issue

- Point 1
- Point 2'
```

### 4. Link to Documentation
```bash
gh api -X POST ... -f body='See [PEP 8](https://peps.python.org/pep-0008/) for style guidelines'
```

### 5. Check for Existing Comments
```bash
# Avoid duplicating comments
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | \
  jq '.[] | select(.path == "src/file.py" and .line == 42)'
```

## Error Handling

### Common Errors

**422 Validation Failed**
- Line number out of range
- Commit SHA doesn't match PR
- File path not in diff

**404 Not Found**
- PR doesn't exist
- Review ID invalid
- Comment ID invalid

**403 Forbidden**
- No permission to review
- Repository is archived
- Review comments disabled

### Recovery

```bash
# Verify PR exists and is open
gh pr view {PR_NUMBER} --json state,number

# Verify file is in PR diff
gh pr diff {PR_NUMBER} --name-only | grep "path/to/file"

# Verify commit is in PR
gh pr view {PR_NUMBER} --json commits | jq '.commits[] | .oid'
```

## Workflow Example

### Complete Review Workflow
```bash
# 1. Fetch PR information
gh pr view 123 --json title,body,files,commits

# 2. Get diff and review code
gh pr diff 123 > review.diff

# 3. Generate review comments (in document)
# ... analyze code and create review document ...

# 4. Get user approval
# ... present review to user for approval ...

# 5. Post review (only after approval)
gh api -X POST repos/owner/repo/pulls/123/reviews \
  -f body='Review summary from document' \
  -f event='COMMENT'

# 6. Post inline comments
gh api -X POST repos/owner/repo/pulls/123/comments \
  -f body='Comment from document' \
  -f commit_id='abc123' \
  -f path='src/file.py' \
  -f line=42
```

## Notes

- Always use latest commit SHA when posting comments
- Batch comments into a single review when possible
- Use suggested changes format for simple fixes
- Markdown formatting makes comments clearer
- Check existing comments to avoid duplicates
- NEVER post without user approval
