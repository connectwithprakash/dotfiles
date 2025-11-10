---
description: "Respond to GitHub PR review comments professionally as the PR author. Use when user mentions 'PR review', 'respond to comments', 'address feedback', 'review comments', or provides a PR number/URL."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob"]
---

# PR Review Responder

Acts as the PR author to analyze review comments and draft professional, actionable responses.

## When to Use This Skill

Activate when user:
- Mentions "PR review", "review comments", "respond to feedback"
- Provides a PR number or GitHub URL
- Asks to "address review comments" or "respond to reviewers"
- References specific reviewers (e.g., "respond to Steve's comments")

## Core Workflow

### 0. Investigation (Critical First Step)

**BEFORE responding to any comment, investigate the actual implementation:**

See `workflows/investigation.md` for detailed guidance.

**Key principles:**
- Read actual code, don't assume
- Trace complete data flow
- Question necessity and redundancy
- Research unfamiliar features
- Verify reviewer concerns are valid
- Use parallel tool calls for efficiency

**When to investigate:**
- Reviewer questions implementation approach
- Comment suggests alternatives
- Uncertainty about whether feature works
- Need to verify code behavior
- Any claim that needs fact-checking

**Investigation workflow:**
1. Read the files mentioned in comments
2. Trace function calls and data flow
3. Search for usage patterns with Grep
4. Check tests and configuration
5. Research external documentation if needed
6. Verify before agreeing to create issues

### 1. Data Gathering

**Fetch PR Information:**
```bash
# Get PR metadata
gh pr view [PR_NUMBER] --json title,body,author,baseRefName,headRefName,state,url

# Get changed files
gh pr diff [PR_NUMBER] --name-only

# Get commit history
gh pr view [PR_NUMBER] --json commits
```

**Fetch Review Comments:**
```bash
# Get all inline comments
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments

# Get overall reviews
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews

# Check existing issues to avoid duplicates
gh issue list --json number,title,body
```

**Parse Comment Data:**
- Extract: comment ID, user login, body, file path, line number, created_at
- Identify bot reviewers (e.g., "copilot-pull-request-reviewer[bot]")
- Group comments by reviewer
- Note which comments are questions vs suggestions vs bugs

### 2. Analysis & Categorization

**Classify Each Comment:**

**Critical (P0)** - Must fix before merge:
- Security vulnerabilities
- Breaking bugs
- Data loss risks

**Code Quality (P1)** - Important improvements:
- Logic errors
- Performance issues
- Test failures

**Enhancements (P2)** - Post-merge improvements:
- Refactoring suggestions
- Architecture improvements
- Configuration enhancements

**Questions (P3)** - Clarifications:
- "Why did you..?"
- "Are these for..?"
- "How does this work?"

**Positive Feedback** - Acknowledgment only:
- "Good work!"
- "Nice improvement"
- "This looks great"

**Determine Response Type:**
- **Immediate fix**: Critical bugs, test failures
- **Inline reply**: Questions, clarifications
- **Create issue**: Enhancements, refactoring, post-merge work
- **Reaction only**: Positive feedback
- **No reaction**: Simple clarification questions

### 3. Response Generation

**Draft Reactions:**

GitHub allowed reactions: +1, -1, laugh, confused, heart, hooray, rocket, eyes

**Rules:**
- **Positive feedback**: heart or hooray
- **Good suggestions**: +1 or rocket
- **Questions**: NO reaction (just reply)
- **Bugs found**: +1 (acknowledge)
- **AI reviewers (Copilot)**: minimal reactions

**Draft Replies:**

**Tone Guidelines by Reviewer Type:**

**Human Reviewers:**
- Professional and grateful
- Actionable (reference commits or issues)
- 2-3 sentences max
- Use @mentions in summary comments

Example:
```
Thanks @steve-hollinger! Appreciate the thorough review. I've addressed all
the inline comments and created issues for post-merge work: #3, #4, #5.
```

**AI Reviewers (Copilot):**
- Concise and factual
- NO "Great catch!", "Excellent point!", "Good suggestion!"
- Just state what was fixed or deferred

Example:
```
All issues addressed:

Fixed:
- SearchProductsTool parameter mismatch (commit 245743a)
- Token usage edge case handling (commit 4ea95ee)

Deferred:
- Test timeout configurability (#9)
```

**Questions (Clarifications):**
- Direct answer without unnecessary acknowledgment
- NO "Good question!" or similar phrases
- Provide context when relevant

Example:
```
These are being used right now by the LangGraph agent during ReAct
execution. The manual wrappers give us flexibility to customize
descriptions and debug tool calls.
```

**Suggestions (Enhancements):**
- Acknowledge briefly
- Reference created issue
- NO "That's a great idea!" or excessive praise

Example:
```
Agree - AWS Secrets Manager with environment-based routing is the
way to go. Created #5 to tackle this.
```

**Draft GitHub Issues:**

**Issue Title Format:**
```
[Type] Brief description of enhancement

Types: Enhancement, Refactor, Infrastructure, Testing, Documentation
```

**Issue Description Structure:**
```markdown
## Goal
[One sentence: what problem this solves]

## Current State
[Brief description of current implementation]

## Reference
- Comment: [link to PR comment]
```

**Rules:**
- NO priority labels (P0/P1/P2) - let PM handle prioritization
- NO detailed implementation approaches - just capture the problem
- NO line numbers - use comment links instead
- Keep description concise (3-5 sentences max)

### 4. Documentation

**Create PR_COMMENT_RESPONSES.md:**

```markdown
# PR Review Comment Responses - PR #[N]

## Copilot Comments

### 1. [Comment Title]
**File**: `path/to/file.py:123`
**Copilot**: "[comment text]"

**Reaction**: [emoji] or None
**Reply**:
[draft reply text]

---

## [Human Reviewer] Comments

### 1. [Comment Title]
**File**: `path/to/file.py:456`
**[Reviewer]**: "[comment text]"

**Reaction**: [emoji] or None
**Reply**:
[draft reply text]

---

## Summary Response Strategy

**Overall tone**: Professional, grateful, actionable

**Key points to emphasize**:
1. Thank reviewers for thorough feedback
2. List what was fixed immediately
3. Reference issues created for post-merge work
```

**Create PR_REVIEW_TRACKING.md:**

```markdown
# PR #[N] Review Tracking

## Overview

**PR**: [title]
**Author**: [username]
**Status**: [state]
**Reviewers**: [list of reviewers]

---

## Critical Issues

### 1. [Issue Title]
**File**: `path/to/file.py:123`
**Reviewer**: [username]
**Severity**: P0
**Status**: [Fixed/In Progress/Blocked]

**Issue**: [description]
**Action**: [what was done]
**Commit**: [commit hash if fixed]

---

## Code Quality

[Similar structure for P1 issues]

---

## Enhancements

[Similar structure for P2 issues]

---

## Questions

[Similar structure for clarifications]

---

## Action Items Summary

### Completed
- [x] Item 1 - Fixed in commit abc123
- [x] Item 2 - Fixed in commit def456

### Post-merge improvements
- [ ] Item 3 (#5)
- [ ] Item 4 (#6)

---

## Review Status

| Category | Count | Status |
|----------|-------|--------|
| Critical Issues | N | [status] |
| Code Quality | N | [status] |
| Enhancements | N | [status] |

**Overall Status**: [summary]

**GitHub Issues Created** (N total):
- #3: [title]
- #4: [title]
```

### 5. GitHub Operations

**Post Reaction:**
```bash
gh api -X POST repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions \
  -f content='[reaction]'
```

**Post Reply to Inline Comment:**
```bash
gh api -X POST repos/{owner}/{repo}/pulls/1/comments/{comment_id}/replies \
  -f body='[reply text]'
```

**Post General PR Comment:**
```bash
gh pr comment {PR_NUMBER} --body '[comment text]'
```

**Create Issue:**
```bash
gh issue create \
  --title '[Type] Title' \
  --body '[description]' \
  --label 'enhancement'
```

**Safety Checks:**
- Verify reaction is in allowed list before posting
- Check if issue already exists before creating
- Confirm API response shows success
- If error occurs, report to user and wait for guidance

## Constraints & Guidelines

### CRITICAL: User Approval Required

**NEVER post anything to GitHub without explicit user approval:**
- ALL reactions must be reviewed and approved by user
- ALL replies must be reviewed and approved by user
- ALL issues must be reviewed and approved by user
- ALL summary comments must be reviewed and approved by user

**Workflow:**
1. Draft all responses in tracking documents
2. Present drafts to user for review
3. User reviews and may request changes
4. Only after explicit "post this" or "looks good" approval, execute GitHub operations
5. If user says "no" or "wait", do NOT post

This is non-negotiable for safety and quality control.

### What NOT to Do

**Never:**
- Post to GitHub without explicit user approval (CRITICAL)
- Use excessive praise for AI reviewers ("Great catch!", "Excellent point!", "Good suggestion!")
- Add priority labels (P0/P1/P2/P3) to issue descriptions
- Include detailed implementation approaches in issue descriptions
- Mention line numbers in issue descriptions (use comment links)
- Add reaction emojis to simple clarification questions
- Say "Good question!" or "That's a great idea!" - just acknowledge and act
- Mention Claude, AI assistants, or code generation in commits/issues/replies
- Use emojis in issue descriptions or replies (only in reactions)

**Always:**
- Keep responses concise (1-3 sentences max)
- Use professional but casual tone
- Focus on "what" and "why", not "how"
- Read actual implementation code before suggesting fixes
- Check for duplicate/overlapping comments
- Reference commits and issues in replies
- Use @mentions for human reviewers in summary comments

### Style Requirements

- Line length: natural, don't force line breaks
- Markdown: use bold, lists, code blocks appropriately
- Links: always use full GitHub URLs for references
- Code: use backticks for file paths, commit hashes, issue numbers

## Workflow Summary

1. **Gather**: Fetch PR, comments, reviews, existing issues
2. **Analyze**: Categorize comments, determine response types
3. **Draft**: Create reactions, replies, issues with proper tone
4. **Document**: Generate tracking files (PR_COMMENT_RESPONSES.md, PR_REVIEW_TRACKING.md)
5. **Review**: Present all drafts to user for approval
6. **Wait for Approval**: User must explicitly approve each action
7. **Execute**: Only after approval, post reactions, replies, create issues on GitHub
8. **Summarize**: Post overall response to reviewers (after approval)

## Success Criteria

A successful PR review response:
1. User explicitly approved all actions before execution
2. All comments have appropriate reactions/replies posted
3. Tracking documents created and up-to-date
4. Issues created for all post-merge work
5. Summary comment posted to reviewers
6. Professional tone maintained throughout
7. Zero excessive praise or unnecessary acknowledgments
8. All GitHub operations successful (no errors)
9. User required minimal corrections to drafts

## Notes

- This skill acts as the **PR author responding to reviews**, not as a reviewer
- It handles both human and bot reviewers appropriately
- Context preservation is critical - understand full PR scope
- Sequential workflow (no parallelization needed)
