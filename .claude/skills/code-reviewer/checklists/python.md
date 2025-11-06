# Python Code Review Checklist

## Type Safety

- [ ] Type hints present for function parameters and return values
- [ ] Type hints accurate (not just `Any` everywhere)
- [ ] Complex types properly defined (TypedDict, Protocol, Union, Optional)
- [ ] Generic types used appropriately
- [ ] No bare `except:` clauses (use `except Exception:`)

## Error Handling

- [ ] Specific exceptions caught (not bare `except:`)
- [ ] Exceptions properly propagated or logged
- [ ] Context managers used for resource management
- [ ] `finally` blocks for cleanup when needed
- [ ] Custom exceptions derive from appropriate base classes

## Pythonic Patterns

- [ ] List/dict/set comprehensions used appropriately
- [ ] Generator expressions for large sequences
- [ ] `with` statements for context management
- [ ] `@property` for computed attributes
- [ ] `@dataclass` or `@attrs` for data classes
- [ ] `enumerate()` instead of manual indexing
- [ ] `zip()` for parallel iteration
- [ ] `itertools` for complex iteration patterns

## Async/Await

- [ ] `async`/`await` syntax used correctly
- [ ] Not blocking event loop with sync I/O
- [ ] `asyncio.gather()` for parallel async operations
- [ ] Async context managers (`async with`) used
- [ ] No mixing of async and sync code incorrectly

## Code Quality

- [ ] Functions are focused and single-purpose
- [ ] Function length reasonable (< 50 lines ideally)
- [ ] Class size manageable
- [ ] No deep nesting (> 3 levels)
- [ ] Meaningful variable and function names
- [ ] Magic numbers replaced with constants
- [ ] Docstrings for public functions and classes

## Dependencies

- [ ] Imports organized (stdlib, third-party, local)
- [ ] No circular imports
- [ ] Dependencies pinned in requirements.txt or pyproject.toml
- [ ] No unused imports
- [ ] Relative imports used correctly

## Testing

- [ ] Tests exist for new functionality
- [ ] Tests use pytest conventions
- [ ] Fixtures used appropriately
- [ ] Mocking used for external dependencies
- [ ] Edge cases tested
- [ ] Both positive and negative test cases

## Performance

- [ ] No unnecessary list copies
- [ ] Database queries optimized (no N+1)
- [ ] Caching used where appropriate
- [ ] Large files processed in chunks
- [ ] No blocking operations in async code

## Security

- [ ] No SQL string concatenation (use parameterized queries)
- [ ] Input validation present
- [ ] No eval() or exec() usage
- [ ] Secrets not hardcoded
- [ ] File paths validated (no path traversal)
- [ ] Authentication/authorization checked

## LangChain/LangGraph Specific

- [ ] Agent prompts clear and well-structured
- [ ] Tool definitions have proper schemas
- [ ] State management using StateGraph
- [ ] Error handling for LLM failures
- [ ] Token usage tracked and optimized
- [ ] Streaming implemented where needed
- [ ] Checkpointing for multi-turn conversations

## Common Issues to Flag

**Security:**
- Using `pickle` (potential code execution)
- Using `eval()` or `exec()`
- SQL string concatenation
- Hardcoded credentials

**Performance:**
- Reading entire files into memory
- N+1 database queries
- Missing indexes
- Inefficient loops (O(n²) when O(n) possible)

**Correctness:**
- Mutable default arguments (`def func(items=[]):`)
- Late binding in closures
- Shallow vs deep copy confusion
- Float equality comparisons

**Style (defer to ruff/black):**
- Line length
- Import ordering
- Naming conventions
