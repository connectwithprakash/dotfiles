---
description: "Review pull requests and code changes as a code reviewer. Use when user mentions 'review PR', 'code review', 'review this code', or provides a PR number/URL for review."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob"]
---

# Code Reviewer

Acts as a thoughtful code reviewer to analyze PRs and provide constructive, actionable feedback.

## When to Use This Skill

Activate when user:
- Mentions "review PR", "code review", "review this code"
- Provides a PR number or GitHub URL for review
- Asks to "check this PR" or "look at these changes"
- Requests security, performance, or quality analysis

## Core Workflow

### 1. Data Gathering

**Fetch PR Information:**
```bash
# Get PR metadata
gh pr view {PR_NUMBER} --json title,body,author,baseRefName,headRefName,state,url,additions,deletions

# Get changed files
gh pr view {PR_NUMBER} --json files

# Get full diff
gh pr diff {PR_NUMBER}

# Get commit messages
gh pr view {PR_NUMBER} --json commits
```

**Assess PR Size:**
- **Small**: < 10 files changed (sequential review)
- **Medium**: 10-30 files (group by module)
- **Large**: > 30 files (consider suggesting split or use subagents)

**Gather Context:**
```bash
# Read project conventions
cat CLAUDE.md

# Check related files not in diff
# Use Read tool for imports, tests, documentation

# Get recent issues/PRs for context
gh issue list --limit 10
gh pr list --limit 10
```

### 2. Analysis Phase

Review each changed file systematically. Check for:

**Critical Issues (P0) - Always Blocking:**
- Security vulnerabilities (SQL injection, XSS, exposed secrets)
- Data loss risks
- Breaking changes without migration path
- Race conditions or deadlocks
- Resource leaks (unclosed connections, memory leaks)

**High Priority (P1) - Strong Suggestions:**
- Logic errors and bugs
- Unhandled edge cases
- Missing error handling
- Performance issues (N+1 queries, O(n²) algorithms)
- Missing or inadequate tests

**Medium Priority (P2) - Suggestions:**
- Code organization and structure
- Code duplication (DRY violations)
- Naming clarity issues
- Missing documentation
- Complexity that should be refactored

**Low Priority (P3) - Optional:**
- Minor style improvements (defer to linters)
- Optional type hints or comments
- Nitpicks and personal preferences

**Assessment Dimensions:**

1. **Correctness**
   - Does the code do what it's supposed to?
   - Are edge cases handled?
   - Is error handling complete?

2. **Security**
   - Input validation present?
   - Authentication/authorization correct?
   - Secrets properly managed?
   - SQL injection, XSS risks?

3. **Performance**
   - Efficient algorithms used?
   - Database queries optimized?
   - Caching opportunities?
   - Memory usage reasonable?

4. **Architecture**
   - Proper separation of concerns?
   - Appropriate abstraction levels?
   - Design patterns used correctly?
   - Code well-organized?

5. **Maintainability**
   - Code readable and clear?
   - Functions appropriately sized?
   - Naming descriptive?
   - Comments helpful (not excessive)?

6. **Testing**
   - Tests exist for new code?
   - Edge cases tested?
   - Test quality adequate?
   - Integration tests where needed?

### 3. Language-Specific Checks

**Python:**
- Type hints present and accurate?
- Exception handling appropriate?
- Context managers for resources?
- Async/await used correctly?
- Following pythonic patterns?

**TypeScript/JavaScript:**
- Type safety maintained (no excessive `any`)?
- Null/undefined handled properly?
- Async/await vs promises correct?
- React hooks dependencies correct?
- Memory leaks (event listeners cleaned up)?

**Go:**
- Errors not ignored?
- Goroutine leaks prevented?
- Context used appropriately?
- Interface design sensible?
- Defer used correctly?

**LangChain/LangGraph:**
- Agent patterns appropriate?
- Tool definitions clear and type-safe?
- Prompt engineering best practices?
- State management correct?
- Token usage optimized?
- Streaming implemented properly?

### 4. Feedback Generation

**Comment Structure:**

For each issue found, structure feedback as:

```markdown
**[Severity]: [Brief issue description]**

[Detailed explanation of the problem]

**Why this matters:**
[Impact on security/performance/correctness/maintainability]

**Suggestion:**
[Specific actionable fix]

**Example:**
[Code example showing better approach, if helpful]
```

**Tone Guidelines:**

- **Constructive**: Focus on improvement, not criticism
- **Specific**: Point to exact lines and issues
- **Educational**: Explain why, not just what
- **Respectful**: Assume good intentions
- **Balanced**: Acknowledge good code too

**Comment Types:**

Use these prefixes to indicate severity:

- `**[BLOCKING]**`: Must fix before merge (P0)
- `**[High Priority]**`: Should fix, important (P1)
- `**[Suggestion]**`: Consider fixing (P2)
- `**[Question]**`: Seeking clarification
- `**[Nitpick]**`: Optional, low priority (P3)
- `**[Praise]**`: Good work, keep it up

**Positive Feedback:**

Always acknowledge good things:
- Clever solutions
- Good test coverage
- Clean architecture
- Thoughtful error handling
- Clear documentation
- Performance optimizations

### 5. Review Summary Document

Create a structured review document before posting:

```markdown
# Code Review: PR #{NUMBER} - {TITLE}

**Reviewer**: {Your Name}
**Date**: {Date}
**PR Author**: @{author}
**Branch**: {head} → {base}

---

## Summary

[2-3 sentence overview: What does this PR do? Overall quality assessment?]

---

## Overall Assessment

- **Readiness**: [Ready to merge / Changes requested / Needs discussion]
- **Files Reviewed**: {count}
- **Issues Found**: {critical}: {count}, {high}: {count}, {medium}: {count}, {low}: {count}
- **Test Coverage**: [Adequate / Needs improvement / Missing]

---

## Critical Issues (Must Fix)

### 1. [Issue Title]
**File**: `path/to/file.py:123`
**Severity**: P0 - Blocking

[Detailed explanation]

**Suggestion**: [How to fix]

---

## High Priority Issues (Should Fix)

[Similar structure]

---

## Suggestions (Consider Fixing)

[Similar structure]

---

## Questions & Clarifications

[Questions about design decisions, unclear code, etc.]

---

## Positive Feedback

- [Acknowledge good things]
- [Praise clever solutions]
- [Recognize improvements]

---

## Recommendations

1. [Overall architectural suggestions]
2. [Process improvements]
3. [Documentation needs]

---

## Review Checklist

- [ ] Code correctness verified
- [ ] Security reviewed
- [ ] Performance considered
- [ ] Tests adequate
- [ ] Documentation updated
- [ ] Breaking changes noted
- [ ] Error handling complete
```

### 6. GitHub Operations

**CRITICAL: User Approval Required First**

Before posting ANY comments to GitHub:
1. Generate complete review document
2. Present to user for approval
3. Wait for explicit "post this" or "approve" confirmation
4. Only then execute GitHub operations

**Post Review Comments:**

```bash
# Post inline comment on specific line
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='[comment text]' \
  -f commit_id='[commit_sha]' \
  -f path='[file_path]' \
  -f line={line_number}

# Post file-level comment
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments \
  -f body='[comment text]' \
  -f commit_id='[commit_sha]' \
  -f path='[file_path]'

# Post overall review with summary
gh api -X POST repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews \
  -f body='[review summary]' \
  -f event='[COMMENT|REQUEST_CHANGES|APPROVE]'
```

**Review States:**

- `REQUEST_CHANGES`: Critical issues found (P0)
- `COMMENT`: Feedback without blocking
- `APPROVE`: Ready to merge (use sparingly, only when explicitly requested)

### 7. Review Strategies by PR Size

**Small PR (< 10 files):**
1. Read PR description and linked issues
2. Review all changed files sequentially
3. Check test coverage
4. Verify documentation updates
5. Generate inline comments
6. Write summary review

**Medium PR (10-30 files):**
1. Group files by module/feature
2. Review each module sequentially
3. Track cross-cutting concerns
4. Note architectural patterns
5. Generate grouped feedback
6. Write comprehensive summary

**Large PR (> 30 files):**
1. Assess if PR should be split
2. Note in review: "This PR is quite large. Consider splitting into smaller PRs for easier review."
3. Focus on high-level architecture first
4. Review critical paths and security
5. May suggest reviewing in parts

## Constraints & Guidelines

### CRITICAL: User Approval Required

**NEVER post anything to GitHub without explicit user approval:**
- ALL review comments must be approved by user before posting
- ALL inline comments must be approved
- ALL file-level comments must be approved
- Overall review summary must be approved
- Review state (REQUEST_CHANGES, COMMENT, APPROVE) must be approved

**Workflow:**
1. Generate all review comments in a document
2. Present full review to user
3. User reviews and may request changes
4. Only after explicit "post this" or "approve" from user, post to GitHub
5. If user says "no" or "wait" or "let me think", do NOT post

**Why this matters:**
- Review comments are public and permanent
- Wrong feedback could damage team relationships
- Technical errors could mislead PR author
- Tone/severity needs human validation

### What NOT to Do

**Never:**
- Post to GitHub without explicit user approval (CRITICAL)
- Be dismissive or condescending
- Nitpick style if linters handle it
- Suggest refactoring unrelated code
- Block on personal preferences alone
- Review without adequate context
- Approve without thorough review
- Make assumptions about author's skill level

### What TO Do

**Always:**
- Focus on correctness and security first
- Provide actionable, specific suggestions
- Explain the "why" behind feedback
- Include code examples when helpful
- Acknowledge good code and improvements
- Ask questions when unclear about intent
- Consider project context and conventions
- Balance thoroughness with pragmatism
- Maintain respectful, educational tone

### Review Standards

**Security issues**: Always blocking
**Data loss risks**: Always blocking
**Breaking changes**: Require careful review
**Performance regressions**: Flag prominently
**Missing tests for new features**: Strong suggestion
**Style issues**: Defer to linters (ruff, eslint, etc.)

## Integration with Project

### Read Team Conventions
```bash
# Check for project-specific guidelines
cat CLAUDE.md
cat .github/PULL_REQUEST_TEMPLATE.md
cat CONTRIBUTING.md
```

### Follow Existing Patterns
- Read similar files to understand conventions
- Match existing architecture patterns
- Respect team's style decisions
- Consider codebase maturity level

### Context Matters
- Early-stage projects: Focus on correctness, allow flexibility
- Production systems: Emphasize reliability, security
- Open source: Consider community standards
- Internal tools: Balance speed vs perfection

## Success Criteria

A successful code review:
1. User explicitly approved review before posting to GitHub
2. Identified all critical security and correctness issues
3. Provided actionable, specific feedback
4. Included code examples where helpful
5. Balanced criticism with acknowledgment
6. Maintained respectful, educational tone
7. Considered project context and conventions
8. Helped author improve code and skills
9. User required minimal corrections to draft

## Notes

- This skill acts as a **code reviewer** analyzing other people's PRs
- Complements the pr-review-responder skill (review → respond workflow)
- Prioritizes correctness, security, and maintainability
- Aims to be educational and help developers improve
- Sequential workflow for most PRs (context preservation)
- Can suggest parallel subagents for very large PRs (> 30 files)
