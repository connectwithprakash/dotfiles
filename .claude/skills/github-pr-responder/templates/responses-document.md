# PR Review Comment Responses - PR #{{PR_NUMBER}}

**PR**: {{PR_TITLE}}
**Author**: {{AUTHOR}}
**Date**: {{DATE}}

---

## {{REVIEWER_1_NAME}} Comments

{{#each reviewer_1_comments}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**{{reviewer}}**: "{{comment}}"

**Reaction**: {{reaction}}
**Reply**:
```
{{reply}}
```

**Status**: {{status}}
{{#if github_issue}}**GitHub Issue**: #{{github_issue}}{{/if}}

---
{{/each}}

## {{REVIEWER_2_NAME}} Comments

{{#each reviewer_2_comments}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**{{reviewer}}**: "{{comment}}"

**Reaction**: {{reaction}}
**Reply**:
```
{{reply}}
```

**Status**: {{status}}
{{#if github_issue}}**GitHub Issue**: #{{github_issue}}{{/if}}

---
{{/each}}

## Summary Response Strategy

**Overall tone**: {{tone_guideline}}

**Key points to emphasize**:
1. {{key_point_1}}
2. {{key_point_2}}
3. {{key_point_3}}

**Commits referenced**:
{{#each commits}}
- {{hash}}: {{message}}
{{/each}}

**Issues created**:
{{#each issues}}
- #{{number}}: {{title}}
{{/each}}

---

## Final Summary Comment to Reviewers

### To {{PRIMARY_REVIEWER}}

**Draft**:
```
{{summary_to_primary}}
```

**Posted**: {{summary_url_primary}}

---

### To {{SECONDARY_REVIEWER}}

**Draft**:
```
{{summary_to_secondary}}
```

**Posted**: {{summary_url_secondary}}

---

## Response Statistics

- Total comments: {{total_comments}}
- Reactions posted: {{reaction_count}}
- Replies posted: {{reply_count}}
- Issues created: {{issue_count}}
- Comments addressed: {{addressed_count}}
- Pending responses: {{pending_count}}
