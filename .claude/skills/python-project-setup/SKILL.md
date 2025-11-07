---
description: "Setup Python projects with uv for fast dependency management. Use when user mentions 'setup Python project', 'initialize Python', 'configure uv', or working with new Python repositories."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob"]
---

# Python Project Setup with uv

Systematically setup and configure Python projects using uv (ultra-fast Python package installer and resolver).

## When to Use This Skill

Activate when user:
- Mentions "setup Python project", "initialize Python"
- Says "configure uv" or "use uv for Python"
- Working with new Python repository or project
- Asks "how do I set up this Python project"
- Mentions "Python dependencies" or "virtual environment"

## Why uv?

**uv is 10-100x faster than pip** with built-in:
- Python version management
- Dependency resolution
- Virtual environment creation
- Lock files for reproducibility
- Drop-in pip replacement

## Core Workflow

### 1. Analyze Existing Project Structure

**Check for existing configurations:**
```bash
# Look for Python configuration files
ls pyproject.toml setup.py setup.cfg requirements.txt 2>/dev/null

# Check for existing virtual environment
ls .venv venv env 2>/dev/null

# Identify testing framework
grep -l "pytest\|unittest" pyproject.toml setup.py requirements*.txt 2>/dev/null
```

**Identify project type:**
- Existing project with dependencies
- New project from scratch
- Existing project migrating to uv

### 2. Install uv

**Check if uv is installed:**
```bash
if ! command -v uv &> /dev/null; then
    # Install via Homebrew (macOS)
    brew install uv

    # Or install via curl
    # curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Verify installation
uv --version
```

### 3. Setup Python Environment

**For New Projects:**
```bash
# Initialize new project with uv
uv init

# This creates:
# - pyproject.toml (project config)
# - .python-version (pinned Python version)
# - src/ directory (source code)
# - README.md
```

**For Existing Projects:**
```bash
# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # Unix/MacOS

# Set/pin Python version
uv python pin 3.11  # or detect from existing config
```

### 4. Install Dependencies

**From requirements.txt:**
```bash
uv pip install -r requirements.txt
uv pip install -r requirements-dev.txt  # if exists
```

**From pyproject.toml:**
```bash
# Install project in editable mode
uv pip install -e .

# Install with optional dependencies
uv pip install -e ".[dev,test]"
```

**Add development tools:**
```bash
uv add --dev black ruff mypy pytest pytest-cov pre-commit
```

### 5. Configure Development Tools

**Create/Update pyproject.toml:**
```toml
[project]
name = "project-name"
version = "0.1.0"
description = "Project description"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "black>=24.0.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
    "pre-commit>=3.6.0",
]
test = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
]

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W", "UP"]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-ra -q --cov=src --cov-report=term-missing"
```

### 6. Setup Pre-commit Hooks (Optional)

**Create .pre-commit-config.yaml:**
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.1.1
    hooks:
      - id: black

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.15
    hooks:
      - id: ruff
        args: [--fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
```

**Install hooks:**
```bash
pre-commit install
pre-commit run --all-files  # test
```

### 7. Create Project Documentation

**Update/Create CLAUDE.md for the project:**
```markdown
# Python Project with uv

## Quick Start
\`\`\`bash
# Install uv
brew install uv

# Setup environment
uv venv
source .venv/bin/activate

# Install dependencies
uv pip install -e ".[dev,test]"

# Run tests
pytest

# Format and lint
black .
ruff check .
\`\`\`

## Development Commands
- Run app: `python src/main.py` or `uv run python src/main.py`
- Run tests: `pytest` or `uv run pytest`
- Format: `black . && ruff check --fix .`
- Lint: `ruff check . && mypy .`
- Coverage: `pytest --cov=src --cov-report=html`

## Dependency Management
- Add dependency: `uv add package-name`
- Add dev dependency: `uv add --dev package-name`
- Update all: `uv lock --upgrade`
- Sync environment: `uv sync`
\`\`\`
```

### 8. Setup IDE Configuration

**Create .vscode/settings.json (for VS Code):**
```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.linting.enabled": true,
  "python.linting.ruffEnabled": true,
  "python.linting.mypyEnabled": true,
  "python.formatting.provider": "black",
  "python.testing.pytestEnabled": true,
  "editor.formatOnSave": true,
  "[python]": {
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  }
}
```

### 9. Validate Setup

**Run health checks:**
```bash
# Check Python version
python --version

# Check uv installation
uv --version

# List installed packages
uv pip list

# Run tests
pytest

# Run linting
ruff check .
mypy .

# Try formatting
black --check .
```

## Common uv Commands Reference

### Environment Management
```bash
uv venv                    # Create virtual environment
uv venv --python 3.11      # Create with specific Python
uv python install 3.11     # Install Python version
uv python pin 3.11         # Pin project to Python version
```

### Package Management
```bash
uv add package-name        # Add dependency
uv add --dev package-name  # Add dev dependency
uv pip install -r requirements.txt
uv pip install -e .        # Install project in editable mode
uv lock --upgrade          # Update all dependencies
uv sync                    # Sync environment with lock file
```

### Running Commands
```bash
uv run python script.py    # Run with uv-managed Python
uv run pytest              # Run pytest
uv run black .             # Run black formatter
```

## Workflow Steps Summary

1. **Analyze**: Check existing Python project structure
2. **Install**: Ensure uv is installed (`brew install uv`)
3. **Environment**: Create venv with `uv venv`, pin Python version
4. **Dependencies**: Install from requirements.txt or pyproject.toml
5. **Tools**: Add dev tools (black, ruff, mypy, pytest)
6. **Configure**: Setup pyproject.toml with tool configs
7. **Hooks**: Optional pre-commit hook setup
8. **Document**: Create/update CLAUDE.md with commands
9. **IDE**: Configure VS Code settings
10. **Validate**: Run tests, linting, formatting checks

## Important Guidelines

### What to Do
- Pin Python version explicitly
- Use pyproject.toml over setup.py
- Include dev dependencies separately
- Setup pre-commit hooks for consistency
- Document all commands in CLAUDE.md
- Test the setup before considering it done

### What NOT to Do
- Don't mix pip and uv (use uv consistently)
- Don't commit .venv directory to git
- Don't skip linting/formatting setup
- Don't forget to pin dependencies
- Don't use outdated tools (use ruff over flake8)

### Project Structure Best Practices
```
project/
├── .venv/                  # Virtual environment (gitignored)
├── src/                    # Source code
│   └── project/
│       ├── __init__.py
│       └── main.py
├── tests/                  # Test files
│   └── test_main.py
├── pyproject.toml          # Project config and dependencies
├── uv.lock                 # Locked dependencies (commit this)
├── .python-version         # Pinned Python version
├── .pre-commit-config.yaml # Pre-commit hooks
├── CLAUDE.md               # Project documentation
└── README.md               # User-facing docs
```

## Success Criteria

A successful Python project setup includes:
1. uv installed and working
2. Virtual environment created and activated
3. All dependencies installed
4. Development tools configured (black, ruff, mypy, pytest)
5. pyproject.toml with proper tool configurations
6. Pre-commit hooks installed (optional but recommended)
7. CLAUDE.md documenting commands
8. IDE configured (VS Code settings)
9. All tests passing
10. Linting and formatting passing

## Notes

- This skill focuses on modern Python development with uv
- uv is 10-100x faster than pip and handles Python version management
- Always use pyproject.toml for new projects (PEP 621 standard)
- ruff is the modern replacement for flake8/isort/pylint combined
- Keep the setup reproducible with lock files
