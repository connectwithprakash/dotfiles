# PR #{{PR_NUMBER}} Review Tracking

## Overview

**PR**: {{PR_TITLE}}
**Author**: {{AUTHOR}}
**Status**: {{STATUS}}
**Reviewers**: {{REVIEWERS}}
**Created**: {{CREATED_DATE}}

---

## Critical Issues

{{#each critical_issues}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Reviewer**: {{reviewer}}
**Severity**: P0
**Status**: {{status}}

**Issue**: {{description}}

**Action**: {{action}}

{{#if commit}}**Commit**: {{commit}}{{/if}}
{{#if github_issue}}**GitHub Issue**: #{{github_issue}}{{/if}}

---
{{/each}}

## Code Quality

{{#each code_quality_issues}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Reviewer**: {{reviewer}}
**Severity**: P1
**Status**: {{status}}

**Issue**: {{description}}

**Action**: {{action}}

{{#if commit}}**Commit**: {{commit}}{{/if}}
{{#if github_issue}}**GitHub Issue**: #{{github_issue}}{{/if}}

---
{{/each}}

## Enhancements

{{#each enhancements}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Reviewer**: {{reviewer}}
**Severity**: P2
**Status**: {{status}}

**Suggestion**: {{description}}

**Action**: {{action}}

**GitHub Issue**: #{{github_issue}}

**Comment**: {{comment_url}}

---
{{/each}}

## Questions

{{#each questions}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Reviewer**: {{reviewer}}
**Severity**: P3
**Status**: {{status}}

**Question**: {{question}}

**Response**: {{response}}

**Comment**: {{comment_url}}

---
{{/each}}

## Positive Feedback

{{#each positive_feedback}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Reviewer**: {{reviewer}}

**Feedback**: {{feedback}}

**Reaction**: {{reaction}}

---
{{/each}}

## Action Items Summary

### Completed
{{#each completed_items}}
- [x] {{description}} - {{action}}
{{/each}}

### Post-merge improvements
{{#each post_merge_items}}
- [ ] {{description}} (#{{issue_number}})
{{/each}}

---

## Review Status

| Category | Count | Status |
|----------|-------|--------|
| Critical Issues | {{critical_count}} | {{critical_status}} |
| Code Quality | {{quality_count}} | {{quality_status}} |
| Enhancements | {{enhancement_count}} | {{enhancement_status}} |
| Questions | {{question_count}} | {{question_status}} |
| Positive Feedback | {{feedback_count}} | Acknowledged |

**Overall Status**: {{overall_status}}

**Final Replies Posted**:
{{#each final_replies}}
- {{description}}: {{url}}
{{/each}}

**Commits Made**:
{{#each commits}}
{{@index}}. {{hash}} - {{message}}
{{/each}}

**GitHub Issues Created** ({{issue_count}} total):
{{#each issues}}
- #{{number}}: {{title}}
{{/each}}

---

## Notes

{{#each notes}}
- {{note}}
{{/each}}
