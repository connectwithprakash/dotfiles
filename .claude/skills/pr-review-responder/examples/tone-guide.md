# Response Tone Guide

## Human Reviewers

### Good Examples

**For bugs found:**
```
Fixed in commit abc123. The parameter now correctly uses 'descriptions'
instead of 'query' to match the MCP schema.
```

**For enhancement suggestions:**
```
Agree - AWS Secrets Manager with environment-based routing is the way
to go. Created #5 to tackle this.
```

**For architecture feedback:**
```
Good point. Will revisit this once we see usage patterns in production.
Created #3 to track the refactoring.
```

**For questions:**
```
These are being used right now by the LangGraph agent during ReAct
execution. The manual wrappers give us flexibility for testing.
```

### Bad Examples (Don't Use)

**Too much praise:**
```
❌ Great catch! That's an excellent observation! Really appreciate you
finding this critical bug!
```

**Too verbose:**
```
❌ Thank you so much for this valuable feedback. I completely agree
that we should consider implementing AWS Secrets Manager for better
secret management. This is definitely something we should prioritize
going forward. I've created issue #5 to track this important work.
```

**Defensive:**
```
❌ Actually, this was intentional because we need the flexibility.
The current approach works fine for our use case.
```

## AI Reviewers (Copilot)

### Good Examples

**For bugs:**
```
Fixed in commit abc123.
```

**For multiple issues:**
```
All issues addressed:

Fixed:
- SearchProductsTool parameter mismatch (commit 245743a)
- Token usage edge case handling (commit 4ea95ee)
- Added exception handler comments (commit ca281ae)

Deferred:
- Test timeout configurability - will add during CI/CD setup (#9)
```

### Bad Examples (Don't Use)

**Too friendly:**
```
❌ Thanks for the thorough review! Great catches on all these issues.
```

**Too wordy:**
```
❌ Thank you for identifying these issues. I appreciate the detailed
feedback and have addressed each point as outlined below.
```

## Question Responses

### Good Examples

**Technical clarification:**
```
The MCP server provides core definitions, but manual wrappers let us
customize descriptions and add fallback logic for testing.
```

**Feature explanation:**
```
This is for the current agent - it uses these tools during ReAct
execution when it needs product/offer data.
```

### Bad Examples (Don't Use)

**Unnecessary acknowledgment:**
```
❌ Good question! Let me explain how this works...
```

**Over-explaining:**
```
❌ That's a great question. So basically what happens is that the
agent, when it's executing the ReAct pattern, needs to be able to
access these tools...
```

## Summary Comments (to Reviewers)

### Good Example

```
Thanks @steve-hollinger! Appreciate the thorough review and valuable
feedback on architecture improvements. I've addressed all the inline
comments and created issues for post-merge work:

**Fixed immediately**:
- Reasoning event now forwards to clients as distinct event type
  (rover-agent PR #47)

**Post-merge improvements**:
- Event handler refactoring (#3)
- Per-agent configuration with model profiles (#4)
- AWS Secrets Manager integration (#5)
- MCP naming improvements (#8)

Looking forward to tackling these in upcoming iterations.
```

### Bad Example

```
❌ Thank you SO much @steve-hollinger for taking the time to do such
an amazingly thorough review! Your feedback is absolutely invaluable
and really helps make this codebase better. Every single one of your
suggestions was spot-on and I'm so grateful for your expertise!
```

## Key Principles

1. **Concise**: 1-3 sentences, get to the point
2. **Professional**: Not overly casual, not overly formal
3. **Actionable**: Reference commits, issues, or concrete next steps
4. **Grateful but not gushing**: "Thanks" yes, "Thank you SO much" no
5. **Factual**: State what was done, not how great the suggestion was
