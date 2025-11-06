# TypeScript/JavaScript Code Review Checklist

## Type Safety

- [ ] Strict TypeScript mode enabled
- [ ] No `any` types (or explicitly justified)
- [ ] Union types used instead of `any`
- [ ] Proper null/undefined handling (`strictNullChecks`)
- [ ] Generic types defined where appropriate
- [ ] Return types explicitly declared
- [ ] Type guards for runtime checks
- [ ] Discriminated unions for complex types

## Async/Await

- [ ] `async`/`await` used correctly
- [ ] Promise chains avoided (use `async`/`await`)
- [ ] Errors in async functions handled with try/catch
- [ ] `Promise.all()` for parallel operations
- [ ] No forgotten `await` keywords
- [ ] Async operations not blocking unnecessarily

## React Patterns (if applicable)

- [ ] Hooks used correctly (rules of hooks followed)
- [ ] `useEffect` dependencies correct
- [ ] No missing dependencies in hooks
- [ ] `useMemo` and `useCallback` used appropriately (not overused)
- [ ] Props properly typed with interfaces
- [ ] No prop drilling (consider Context or state management)
- [ ] Components reasonably sized
- [ ] Key props used correctly in lists

## Error Handling

- [ ] Try/catch blocks around risky operations
- [ ] Errors properly propagated or logged
- [ ] Network errors handled gracefully
- [ ] User-friendly error messages
- [ ] Error boundaries for React components
- [ ] Async errors caught

## Memory Management

- [ ] Event listeners cleaned up in cleanup functions
- [ ] Subscriptions unsubscribed
- [ ] Timers cleared
- [ ] React effects have cleanup functions
- [ ] No circular references
- [ ] Large objects released when done

## Code Quality

- [ ] Functions focused and single-purpose
- [ ] Function length reasonable (< 50 lines)
- [ ] Meaningful variable and function names
- [ ] No magic numbers or strings
- [ ] Proper use of const vs let (no var)
- [ ] Destructuring used where appropriate
- [ ] Optional chaining (`?.`) used correctly
- [ ] Nullish coalescing (`??`) preferred over `||`

## Performance

- [ ] Expensive computations memoized
- [ ] No unnecessary re-renders (React)
- [ ] Debouncing/throttling for frequent events
- [ ] Virtual scrolling for long lists
- [ ] Code splitting for large bundles
- [ ] Lazy loading for routes/components
- [ ] Images optimized and lazy loaded

## Security

- [ ] No `eval()` or `Function()` constructor
- [ ] User input sanitized (especially for innerHTML)
- [ ] XSS vulnerabilities addressed
- [ ] Authentication tokens stored securely
- [ ] Sensitive data not logged
- [ ] CORS configured correctly
- [ ] CSP headers considered

## Testing

- [ ] Tests exist for new functionality
- [ ] Tests use proper assertions
- [ ] Mocks used for external dependencies
- [ ] Edge cases covered
- [ ] Async tests handled correctly (await, done callback)
- [ ] Component tests for UI
- [ ] Integration tests for critical paths

## Dependencies

- [ ] Imports organized logically
- [ ] No circular dependencies
- [ ] Tree-shaking friendly imports
- [ ] Bundle size impact considered
- [ ] Dependencies up to date (security)
- [ ] No unused dependencies

## Common Issues to Flag

**Type Safety:**
- Using `any` without justification
- Missing null checks
- Type assertions without validation (`as Type`)
- Ignoring TypeScript errors with `@ts-ignore`

**React:**
- Missing `useEffect` dependencies
- Infinite render loops
- Not cleaning up effects
- Incorrect key prop usage
- Prop drilling multiple levels

**Performance:**
- Re-creating functions in render
- Unnecessary state updates
- Expensive operations without memoization
- Large bundle sizes

**Security:**
- `dangerouslySetInnerHTML` without sanitization
- Storing tokens in localStorage (consider httpOnly cookies)
- Exposing sensitive data in client code

**Memory Leaks:**
- Event listeners not cleaned up
- Timers not cleared
- Subscriptions not unsubscribed
- References kept after unmount

## Style (defer to ESLint/Prettier)

- Line length
- Indentation
- Semicolons
- Quote style
- Import ordering
