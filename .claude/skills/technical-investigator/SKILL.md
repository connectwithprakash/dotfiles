---
description: "Investigate technical questions about code architecture, design decisions, and implementation details. Use when user asks 'how does X work', 'why do we need Y', 'should we use approach A or B', or questions about existing code patterns."
allowed-tools: ["Read", "Grep", "Glob", "Bash", "WebSearch", "WebFetch", "TodoWrite"]
---

# Technical Investigator

Systematically investigate technical questions through code exploration, research, and analysis to provide well-reasoned recommendations.

## When to Use This Skill

Activate when user:
- Asks "how does X work in the codebase?"
- Questions "why do we need Y?" or "do we even need Y?"
- Seeks architectural guidance: "should we use approach A or B?"
- Wants to understand implementation details
- Asks about design patterns or best practices
- Needs comparison of different approaches with tradeoffs

## Core Workflow

### 1. Deep Code Investigation

**Understand Current Implementation:**
```bash
# Find where feature/pattern is used
# Use Grep to search for related patterns across codebase

# Read the implementation
# Use Read tool on relevant files

# Trace the flow
# Follow function calls, imports, and dependencies
```

**Investigation Strategy:**
- Read the actual implementation first (don't assume)
- Search for all usages of the pattern/feature
- Check configuration files for settings
- Look at test files for expected behavior
- Review related documentation (CLAUDE.md, README, docs/)

**Use Multiple Tools in Parallel:**
- Run Read + Grep simultaneously to gather context faster
- Check multiple related files at once
- Search for different variations of terms in parallel

### 2. Question the Assumptions

**Critical Thinking:**
- **Do we actually need this?** - Question whether feature is necessary
- **Is this redundant?** - Check if we're doing the same thing twice
- **Does this work as intended?** - Verify the implementation actually functions correctly
- **What's the actual benefit?** - Quantify the value (cost savings, performance, etc.)

**Look for Red Flags:**
- Unused parameters being passed around
- Features that seem to do nothing
- Redundant data flows (same data from two sources)
- Configuration that doesn't match documentation
- Parameters passed but never used in the receiving function

### 3. External Research

**When to Research:**
- New framework features you're unfamiliar with
- API parameters you haven't seen before
- Design patterns mentioned in code
- Best practices for specific technologies
- Performance characteristics of different approaches

**Research Strategy:**
```bash
# Search for official documentation
# Use WebSearch for framework/library docs

# Fetch technical articles
# Use WebFetch for detailed documentation pages

# Look for community discussions
# Search for GitHub issues, Stack Overflow, etc.
```

**What to Research:**
- Official framework/library documentation
- API reference for specific features
- Performance benchmarks and comparisons
- Known issues or limitations
- Best practices from maintainers
- Real-world usage examples

### 4. Analyze Tradeoffs

**Compare Approaches:**

For each option, document:

**Option A: [Name]**
- **How it works**: [Brief explanation]
- **Pros**:
  - ✅ Benefit 1 (with quantification if possible)
  - ✅ Benefit 2
- **Cons**:
  - ❌ Drawback 1
  - ❌ Drawback 2
- **When to use**: [Specific scenarios]

**Option B: [Name]**
- [Same structure]

**Current Approach: [Name]**
- [Same structure]
- **Why it exists**: [Original rationale]
- **Is it working?**: [Analysis of actual behavior]

**Evaluation Criteria:**
- Performance (latency, throughput, resource usage)
- Cost (API calls, storage, compute)
- Complexity (code maintainability, learning curve)
- Reliability (error handling, edge cases)
- Flexibility (future requirements, extensibility)
- Data ownership (control, privacy, vendor lock-in)

### 5. Make Clear Recommendations

**Recommendation Format:**

```markdown
## My Recommendation

**[Option Name] (Recommended)** because:

1. **[Primary reason]** - [Detailed explanation with data/evidence]
2. **[Secondary reason]** - [Explanation]
3. **[Third reason]** - [Explanation]

**Implementation approach:**
[High-level steps if you proceed with this option]

**Exception**: If [specific scenario], then consider [alternative option]
```

**Justify with Evidence:**
- Link to official documentation
- Reference performance benchmarks
- Cite code examples from the codebase
- Quantify benefits where possible (80% cache hit rate, 2x cost savings)
- Note any risks or limitations

### 6. Verify Through Code Analysis

**Before Making Recommendations:**

Check if the current implementation actually works:
```python
# Does this parameter actually get used?
# Trace through the code flow

# Is this configuration actually applied?
# Check if it reaches the underlying API

# Does this data actually flow correctly?
# Verify the complete path from source to destination
```

**Validation Questions:**
- Is the parameter name correct for the API?
- Does the config format match what the library expects?
- Is the value actually passed through all layers?
- Are there any transformations that might break it?

### 7. Document the Investigation

**Create Investigation Report:**

```markdown
# Investigation: [Question]

## Context
[What prompted this investigation]

## Current Implementation
[How it works now - with code references]

File references: `path/to/file.py:123`

## Research Findings
[What external research revealed]
- [Finding 1 with source]
- [Finding 2 with source]

## Analysis
[Deep dive into the problem/question]

### Issues Found
[Problems with current approach]

### Options Considered
[Comparison of alternatives]

## Recommendation
[Clear recommendation with justification]

## Implementation Notes
[If proceeding with changes]
```

## Investigation Patterns

### Pattern 1: "How does X work?"

1. Search for X in codebase (Grep)
2. Read the main implementation files
3. Trace data flow and function calls
4. Check tests to understand expected behavior
5. Document the flow with file:line references

### Pattern 2: "Do we even need X?"

1. Find where X is used (search for usage)
2. Trace the data flow - does X actually do anything?
3. Check if X is redundant with Y (doing the same thing)
4. Research what X was meant to provide
5. Recommend keep/remove with clear justification

### Pattern 3: "Should we use A or B?"

1. Research both approaches (official docs, best practices)
2. Check if either is already partially implemented
3. Compare with criteria (performance, cost, complexity)
4. Make recommendation with clear pros/cons
5. Note any exceptions or edge cases

### Pattern 4: "Why isn't X working?"

1. Read the actual implementation (don't assume)
2. Check if parameters are correctly named/formatted
3. Verify the config actually reaches the destination
4. Search for similar issues in GitHub/docs
5. Identify the root cause with evidence

## Important Guidelines

### What TO Do

**Always:**
- Read actual code before making assumptions
- Question whether features are actually needed
- Research official documentation for unfamiliar features
- Provide tradeoffs for different approaches
- Quantify benefits when possible (cost, performance)
- Use file:line references when discussing code
- Verify implementation actually works as intended
- Run multiple searches/reads in parallel for efficiency
- Check if data/parameters actually flow through all layers
- Document sources for research findings

### What NOT to Do

**Never:**
- Make recommendations without reading the actual code
- Assume a feature works just because it exists
- Suggest changes without understanding current implementation
- Ignore redundancy (doing the same thing twice)
- Recommend approaches without researching tradeoffs
- Skip verification of whether code actually works
- Provide vague "it depends" answers without analysis
- Research without checking current codebase first

### Critical Thinking Checklist

Before recommending anything:
- [ ] Have I read the actual implementation code?
- [ ] Have I traced the complete data/control flow?
- [ ] Have I checked if this feature is actually used?
- [ ] Have I verified parameters reach their destination?
- [ ] Have I researched official documentation?
- [ ] Have I identified any redundancy?
- [ ] Have I quantified the benefits/costs?
- [ ] Have I provided clear file:line references?
- [ ] Have I considered edge cases and limitations?
- [ ] Have I made a clear recommendation?

## Research Best Practices

### Framework/Library Features

When encountering unfamiliar features:
1. Search official documentation first
2. Check version compatibility
3. Look for migration guides if old patterns exist
4. Find code examples in official repos
5. Check for known issues or limitations

### API Parameters

When investigating API parameters:
1. Verify parameter name in official API docs
2. Check supported values and formats
3. Look for examples in documentation
4. Search for community discussions of the feature
5. Verify the SDK/library supports the parameter

### Performance & Scalability

When comparing approaches:
1. Look for official benchmarks
2. Search for real-world usage examples
3. Consider cache hit rates and optimization
4. Check cost implications (API calls, storage)
5. Note any limitations at scale

## Success Criteria

A successful investigation:
1. Read and understood actual implementation code
2. Traced complete data/control flow
3. Questioned assumptions about necessity
4. Researched external sources (docs, articles)
5. Identified any redundancy or issues
6. Compared approaches with clear tradeoffs
7. Made clear recommendation with evidence
8. Provided implementation guidance if applicable
9. Documented with file:line references
10. User understands the reasoning and can make informed decision

## Example Workflow

**User asks: "Why do we need previous_response_id?"**

1. **Investigate current usage:**
   - Grep for `previous_response_id` in codebase
   - Read main.py to see how it's used
   - Read agent.py to see how it's passed
   - Trace the flow from retrieval to usage

2. **Question the necessity:**
   - Is it actually being used correctly?
   - Are we also sending full conversation history?
   - Is this redundant?

3. **Research the feature:**
   - WebSearch for "OpenAI previous_response_id"
   - Read official OpenAI Responses API docs
   - Understand what it actually does (server-side caching)

4. **Analyze tradeoffs:**
   - **Option A**: Use previous_response_id only
   - **Option B**: Use manual history only
   - **Current**: Both (redundant?)

5. **Make recommendation:**
   - Clear choice with pros/cons
   - Quantify benefits (80% cache vs 40%)
   - Note implementation would be simpler

6. **Verify before recommending removal:**
   - Check if parameter is actually passed correctly
   - Discover it may not even work as implemented
   - Recommend simplification

## Notes

- This skill focuses on investigation and analysis, not implementation
- Works well alongside github-issue-fixer for implementation phase
- Emphasizes critical thinking and questioning assumptions
- Balances code analysis with external research
- Aims to provide clear, actionable recommendations
- Values evidence over speculation
