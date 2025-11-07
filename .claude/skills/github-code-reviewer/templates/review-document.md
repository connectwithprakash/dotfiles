# Code Review: PR #{{PR_NUMBER}} - {{TITLE}}

**Reviewer**: {{REVIEWER_NAME}}
**Date**: {{DATE}}
**PR Author**: @{{AUTHOR}}
**Branch**: {{HEAD_BRANCH}} → {{BASE_BRANCH}}
**Files Changed**: {{FILES_COUNT}} (+{{ADDITIONS}} -{{DELETIONS}})

---

## Summary

{{SUMMARY_2_3_SENTENCES}}

---

## Overall Assessment

- **Readiness**: {{READY_TO_MERGE | CHANGES_REQUESTED | NEEDS_DISCUSSION}}
- **Files Reviewed**: {{REVIEWED_COUNT}} / {{TOTAL_COUNT}}
- **Issues Found**:
  - Critical (P0): {{CRITICAL_COUNT}}
  - High Priority (P1): {{HIGH_COUNT}}
  - Suggestions (P2): {{MEDIUM_COUNT}}
  - Nitpicks (P3): {{LOW_COUNT}}
- **Test Coverage**: {{ADEQUATE | NEEDS_IMPROVEMENT | MISSING}}
- **Documentation**: {{UPDATED | NEEDS_UPDATE | N_A}}

---

## Critical Issues (Must Fix Before Merge)

{{#if has_critical_issues}}
{{#each critical_issues}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Severity**: P0 - Blocking

{{description}}

**Why this matters:**
{{impact}}

**Suggestion:**
{{suggestion}}

{{#if example_code}}
**Example:**
```{{language}}
{{example_code}}
```
{{/if}}

---
{{/each}}
{{else}}
No critical issues found.
{{/if}}

---

## High Priority Issues (Should Fix)

{{#if has_high_issues}}
{{#each high_priority_issues}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Severity**: P1

{{description}}

**Why this matters:**
{{impact}}

**Suggestion:**
{{suggestion}}

{{#if example_code}}
**Example:**
```{{language}}
{{example_code}}
```
{{/if}}

---
{{/each}}
{{else}}
No high priority issues found.
{{/if}}

---

## Suggestions (Consider Fixing)

{{#if has_suggestions}}
{{#each suggestions}}
### {{@index}}. {{title}}
**File**: `{{file}}:{{line}}`
**Severity**: P2

{{description}}

**Suggestion:**
{{suggestion}}

---
{{/each}}
{{else}}
No medium priority suggestions.
{{/if}}

---

## Questions & Clarifications

{{#if has_questions}}
{{#each questions}}
### {{@index}}. {{question_title}}
**File**: `{{file}}:{{line}}`

{{question_text}}

{{#if context}}
**Context:** {{context}}
{{/if}}

---
{{/each}}
{{else}}
No questions at this time.
{{/if}}

---

## Nitpicks (Optional)

{{#if has_nitpicks}}
These are minor style/preference items that aren't blocking:

{{#each nitpicks}}
- **{{file}}:{{line}}**: {{description}}
{{/each}}
{{else}}
No nitpicks.
{{/if}}

---

## Positive Feedback

{{#if has_positive_feedback}}
Things done well in this PR:

{{#each positive_items}}
- **{{title}}**: {{description}}
{{/each}}
{{else}}
{{#if no_issues}}
This PR looks great overall! Clean code, good test coverage, and well-documented.
{{/if}}
{{/if}}

---

## Testing Notes

{{#if tests_reviewed}}
**Tests Reviewed:**
- Unit tests: {{unit_test_status}}
- Integration tests: {{integration_test_status}}
- Edge cases covered: {{edge_case_coverage}}

{{#if test_suggestions}}
**Suggestions:**
{{#each test_suggestions}}
- {{suggestion}}
{{/each}}
{{/if}}
{{else}}
**Note**: No tests found for new functionality. Please add tests covering:
{{#each missing_test_cases}}
- {{test_case}}
{{/each}}
{{/if}}

---

## Security Review

{{#if security_reviewed}}
**Security Considerations:**
{{#each security_items}}
- {{item}}
{{/each}}
{{else}}
No security concerns identified in this review.
{{/if}}

---

## Performance Considerations

{{#if performance_reviewed}}
**Performance Notes:**
{{#each performance_items}}
- {{item}}
{{/each}}
{{else}}
No performance concerns identified.
{{/if}}

---

## Documentation

{{#if documentation_updated}}
Documentation appears up-to-date and covers the changes appropriately.
{{else}}
{{#if documentation_needed}}
**Needs Documentation:**
{{#each doc_items}}
- {{item}}
{{/each}}
{{/if}}
{{/if}}

---

## Recommendations

{{#if has_recommendations}}
**Overall Suggestions:**
{{#each recommendations}}
{{@index}}. {{recommendation}}
{{/each}}
{{/if}}

---

## Review Checklist

- [{{#if correctness_checked}}x{{else}} {{/if}}] Code correctness verified
- [{{#if security_checked}}x{{else}} {{/if}}] Security reviewed
- [{{#if performance_checked}}x{{else}} {{/if}}] Performance considered
- [{{#if tests_checked}}x{{else}} {{/if}}] Tests adequate
- [{{#if docs_checked}}x{{else}} {{/if}}] Documentation updated
- [{{#if breaking_checked}}x{{else}} {{/if}}] Breaking changes noted
- [{{#if errors_checked}}x{{else}} {{/if}}] Error handling complete
- [{{#if conventions_checked}}x{{else}} {{/if}}] Project conventions followed

---

## Next Steps

{{#if ready_to_merge}}
This PR looks good to merge once CI passes.
{{else if changes_requested}}
Please address the critical and high-priority issues noted above, then request re-review.
{{else if needs_discussion}}
Let's discuss the architectural questions before proceeding. Would be happy to chat synchronously or async in comments.
{{/if}}

---

## Additional Context

{{#if additional_notes}}
{{additional_notes}}
{{/if}}

---

**Review State**: {{COMMENT | REQUEST_CHANGES | APPROVE}}
