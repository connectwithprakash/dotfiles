# Implementation Workflow

## Purpose
Implement the fix following project conventions and best practices.

## Pre-Implementation Checklist

- [ ] Issue requirements fully understood
- [ ] Codebase context explored
- [ ] Implementation plan created with TodoWrite
- [ ] Branch created with descriptive name

## Implementation Steps

### 1. Create Feature Branch
```bash
git checkout -b fix/issue-{NUMBER}-{short-description}
```

### 2. Write Code
- Follow existing code patterns
- Use clear, descriptive names
- Add comments for complex logic
- Keep functions focused and small

### 3. Add Tests
- Write unit tests for new functionality
- Update existing tests if behavior changes
- Include edge case testing
- Aim for high test coverage

### 4. Update Documentation
- Update docstrings/JSDoc
- Add inline comments where needed
- Update README if applicable
- Note any breaking changes

## Code Quality Guidelines

### Style
- Follow project linting rules
- Match existing code style
- Use consistent naming conventions
- Keep line length reasonable

### Testing
- Test happy path
- Test error conditions
- Test edge cases
- Test with realistic data

### Security
- Validate all inputs
- Sanitize user data
- Check for injection vulnerabilities
- Handle secrets properly

### Performance
- Avoid unnecessary loops
- Use efficient data structures
- Consider memory usage
- Profile if performance-critical

## Validation Before Commit

- [ ] Code follows project conventions
- [ ] All tests pass locally
- [ ] Linting passes
- [ ] Build succeeds
- [ ] Manual testing completed
- [ ] No debug code left in
- [ ] No commented-out code (unless documented why)

## Output

- Working implementation
- Comprehensive tests
- Updated documentation
- Clean, readable code
