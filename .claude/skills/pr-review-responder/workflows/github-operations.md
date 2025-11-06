# GitHub Operations Reference

Quick reference for common GitHub CLI operations used in PR review responses.

## Fetching Data

### Get PR Details
```bash
# Basic PR info
gh pr view {PR_NUMBER}

# JSON format with specific fields
gh pr view {PR_NUMBER} --json title,body,author,state,url,baseRefName,headRefName,commits

# Get changed files
gh pr diff {PR_NUMBER} --name-only
```

### Get Review Comments
```bash
# All inline comments
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments

# Filter by reviewer
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | jq '.[] | select(.user.login == "username")'

# Get specific comment
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}
```

### Get Overall Reviews
```bash
# All reviews (APPROVED, COMMENTED, etc.)
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews

# Filter by state and reviewer
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews | jq '.[] | select(.user.login == "username" and .state == "APPROVED")'
```

### Get Issues
```bash
# List all open issues
gh issue list --json number,title,body,state,labels

# Check if issue with title exists
gh issue list --json title,number | jq '.[] | select(.title | contains("keyword"))'
```

## Posting Responses

### Post Reaction to Inline Comment
```bash
# Allowed reactions: +1, -1, laugh, confused, heart, hooray, rocket, eyes
gh api -X POST repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions \
  -f content='heart'

# Check current reactions
gh api repos/{owner}/{repo}/pulls/comments/{comment_id} | jq '.reactions'
```

### Delete Reaction
```bash
# Need reaction ID (from reactions API response)
gh api -X DELETE repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions/{reaction_id}
```

### Post Reply to Inline Comment
```bash
# Reply to specific comment (threaded reply)
gh api -X POST repos/{owner}/{repo}/pulls/1/comments/{comment_id}/replies \
  -f body='Your reply text here'

# Note: Use PR number 1 style, not the PR_NUMBER variable
```

### Post General PR Comment
```bash
# Comment in main conversation (not inline)
gh pr comment {PR_NUMBER} --body 'Your comment text here'

# Multi-line comment
gh pr comment {PR_NUMBER} --body "Line 1
Line 2
Line 3"
```

### Create GitHub Issue
```bash
# Basic issue
gh issue create \
  --title "[Enhancement] Title here" \
  --body "Description here"

# With labels
gh issue create \
  --title "[Bug] Title here" \
  --body "Description here" \
  --label "bug" \
  --label "priority-high"

# Available label types (check repo first)
gh label list
```

### Update Issue
```bash
# Edit title
gh issue edit {ISSUE_NUMBER} --title "New title"

# Edit body
gh issue edit {ISSUE_NUMBER} --body "New description"

# Add labels
gh issue edit {ISSUE_NUMBER} --add-label "enhancement"

# Close issue
gh issue close {ISSUE_NUMBER}
```

## Error Handling

### Common Errors

**404 Not Found**
- Comment was deleted
- Wrong comment ID
- Wrong repository path

**422 Unprocessable Entity**
- Invalid reaction type
- Invalid JSON in body

**Label Not Found**
- Label doesn't exist in repo
- Use `gh label list` to check available labels

### Error Recovery

**Delete wrong comment:**
```bash
# For PR comments
gh api -X DELETE repos/{owner}/{repo}/pulls/comments/{comment_id}

# For issue comments
gh api -X DELETE repos/{owner}/{repo}/issues/comments/{comment_id}
```

**Delete wrong reaction:**
```bash
# Get reaction ID first
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions

# Delete by ID
gh api -X DELETE repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions/{reaction_id}
```

## Useful Queries

### Find Comment by Content
```bash
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | \
  jq '.[] | select(.body | contains("search term")) | {id: .id, body: .body}'
```

### Get All Comments by Reviewer
```bash
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | \
  jq '.[] | select(.user.login == "reviewer-name")'
```

### Check Commit Status
```bash
# Get recent commits
gh pr view {PR_NUMBER} --json commits

# Get specific commit details
gh api repos/{owner}/{repo}/commits/{commit_sha}
```

### Get Repository Info
```bash
# Current repo
gh repo view

# Specific repo
gh repo view {owner}/{repo}

# Get owner and repo name
gh repo view --json owner,name
```

## Best Practices

1. **Always check existing data before creating**
   - Check if issue exists before creating
   - Verify comment wasn't already replied to
   - Confirm reaction isn't already posted

2. **Use jq for filtering**
   - Filter by user, state, content
   - Extract specific fields
   - Format output for readability

3. **Handle errors gracefully**
   - Check API response status
   - Report errors to user
   - Don't retry failed operations without confirmation

4. **Validate inputs**
   - Ensure reaction is in allowed list
   - Verify PR number exists
   - Check comment IDs are valid

5. **Use heredocs for multi-line content**
   ```bash
   gh pr comment 1 --body "$(cat <<'EOF'
   Line 1
   Line 2
   Line 3
   EOF
   )"
   ```
