# Exploration Workflow

## Purpose
Understand the codebase context before implementing a fix.

## Steps

### 1. Initial Code Search
```bash
# Search for keywords from issue
grep -r "keyword" --include="*.py" --include="*.js" --include="*.ts"

# Find specific files mentioned
find . -name "filename.py"

# Search for similar patterns
rg "pattern" -t python -t javascript
```

### 2. Context Reading
- Read main files mentioned in issue
- Check related test files
- Review configuration files
- Look for similar implementations

### 3. Pattern Analysis
- Identify code style and conventions
- Note testing patterns used
- Understand error handling approach
- Check logging patterns

### 4. Dependency Check
- Identify affected modules
- Check for circular dependencies
- Note external dependencies
- Review API contracts

## Tools to Use

- **Grep**: Search for code patterns
- **Glob**: Find files by pattern
- **Read**: Read specific files for context
- **Task (Explore)**: For complex, open-ended searches

## Output

Document findings:
- Relevant files identified
- Code patterns observed
- Dependencies noted
- Testing approach understood
