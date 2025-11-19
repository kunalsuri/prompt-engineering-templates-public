# Python Best Practices Guide

Guidelines for writing high-quality, maintainable Python code using Copilot or any AI coding assistant.

**Target Python Version: 3.10+**

---

## 🎯 Instructions for AI Code Generation

When generating Python code, you MUST:
- Apply ALL guidelines from this document unless explicitly told otherwise
- Prioritize type safety, error handling, and maintainability
- Generate complete, runnable code with all necessary imports
- Include proper type hints and docstrings by default
- Use modern Python syntax (Python 3.10+)
- Ask for clarification if requirements conflict with best practices
- Consider performance and security implications
- Follow project-specific patterns when they exist

---

## 1️⃣ Code Style & Formatting

- **Follow PEP 8** style guidelines
- Use **descriptive names** for variables, functions, and classes
- Use **f-strings** for string formatting (not `.format()` or `%`)
- Use **pathlib.Path** instead of string paths
- Always include `if __name__ == "__main__":` guard for executable scripts
- Use list/dict comprehensions for simple transformations
- Use generator expressions for memory efficiency with large datasets

---

## 2️⃣ Type Hints & Documentation

- **Type hints** for all function parameters and return values (use modern syntax)
```python
# For Python 3.9, add at top of file:
from __future__ import annotations

def process_data(input: list[str], limit: int = 10) -> dict[str, int]:
    """Process input data and return counts."""
    pass

# Advanced type hints
from typing import Protocol, TypeVar, Generic, TypeAlias
from collections.abc import Sequence, Mapping

T = TypeVar('T')

# Type aliases for clarity
UserId: TypeAlias = int
ConfigDict: TypeAlias = dict[str, str | int | bool]

# Protocol for structural typing
class Drawable(Protocol):
    def draw(self) -> None: ...

# Generic types
class Container(Generic[T]):
    def __init__(self, item: T) -> None:
        self.item = item
```

- **Docstring format**: Use Google or NumPy style consistently
```python
def example(param1: str, param2: int) -> bool:
    """
    Brief description.

    Args:
        param1: Description of param1
        param2: Description of param2

    Returns:
        Description of return value

    Raises:
        ValueError: When param2 is negative
    """
    pass
```

- Use **dataclasses** for structured data instead of dictionaries
```python
from dataclasses import dataclass

@dataclass
class Config:
    name: str
    value: int
    enabled: bool = True
```

---

## 3️⃣ Project Structure

```
project_name/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   └── modules/
│       └── __init__.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_main.py
├── .env.example
├── .gitignore
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
└── README.md
```

- **src/**: All source code in a package
- **tests/**: Mirror source structure with unit/, integration/, e2e/ subdirectories
- **Keep main.py minimal**: orchestration only (<100 lines), no business logic
- **Separate dependencies**: production (`requirements.txt`) vs development (`requirements-dev.txt`)
- **Version control**: Include CHANGELOG.md for tracking changes
- **CI/CD**: Add .github/workflows/ for automated testing and deployment

---

## 4️⃣ Error Handling & Validation

- Use **specific exception types**, avoid bare `except Exception:`
- Create **custom exception hierarchy** for application-specific errors
```python
class AppException(Exception):
    """Base exception for application."""
    pass

class ValidationError(AppException):
    """Raised when input validation fails."""
    pass

class ProcessingError(AppException):
    """Raised when processing fails."""
    pass

# Good error handling
try:
    result = risky_operation()
except FileNotFoundError as e:
    logger.error(f"File not found: {e}")
    raise
except ValueError as e:
    logger.warning(f"Invalid value: {e}")
    return default_value
```

- Use **context managers** (`with`) for resource management
```python
from pathlib import Path

with open(file_path) as f:
    data = f.read()

# For multiple resources
with open(input_file) as f_in, open(output_file, 'w') as f_out:
    f_out.write(f_in.read())
```

- **Validate inputs** early and explicitly (fail-fast principle)
```python
def process(value: int) -> int:
    if value < 0:
        raise ValidationError(f"Expected non-negative value, got {value}")
    if not isinstance(value, int):
        raise TypeError(f"Expected int, got {type(value).__name__}")
    return value * 2
```

---

## 5️⃣ Logging

- Use **logging module**, not `print()`
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

logger.debug("Debug message")
logger.info("Info message")
logger.warning("Warning message")
logger.error("Error message")
logger.critical("Critical message")
```

---

## 6️⃣ Configuration & Secrets

- Use **environment variables** for configuration
```python
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY environment variable not set")

# Use pydantic for settings validation
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    api_key: str
    debug: bool = False
    max_retries: int = 3
    
    class Config:
        env_file = ".env"

settings = Settings()
```

- **Never hardcode secrets** in code
- Provide `.env.example` with dummy values
- Add `.env` to `.gitignore`
- Consider using **keyring** or cloud secret managers for production

---

## 7️⃣ Dependency Management

- Use **virtual environments** always
```bash
python -m venv .venv
source .venv/bin/activate  # Unix/macOS
.venv\Scripts\activate     # Windows
```

- **Pin versions** in `requirements.txt` for reproducibility
```
requests==2.31.0
numpy==1.24.3
```

- Use **pyproject.toml** for modern packaging
```toml
[build-system]
requires = ["setuptools>=65.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "project_name"
version = "0.1.0"
dependencies = ["requests>=2.31.0"]

[project.optional-dependencies]
dev = ["pytest>=7.0", "black>=23.0", "mypy>=1.0"]
```

---

## 8️⃣ Code Quality Tools

Run these tools regularly (ideally via pre-commit hooks):

- **black**: Code formatting (opinionated)
```bash
black src/ tests/
```

- **isort**: Import sorting
```bash
isort src/ tests/
```

- **flake8**: Linting
```bash
flake8 src/ tests/ --max-line-length=88
```

- **mypy**: Type checking
```bash
mypy src/
```

- **pylint**: Additional linting
```bash
pylint src/
```

- **bandit**: Security analysis
```bash
bandit -r src/
```

- **ruff**: Fast all-in-one linter (alternative to flake8, isort, pylint)
```bash
ruff check src/ tests/
ruff format src/ tests/  # Also formats like black
```

**Pre-commit hooks** (.pre-commit-config.yaml):
```yaml
repos:
  - repo: https://github.com/psf/black
    rev: 24.0.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8
        args: [--max-line-length=88]
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
```

---

## 9️⃣ Testing

- Use **pytest** as testing framework
```python
import pytest

def test_example():
    assert function_to_test() == expected_value

def test_with_fixture(sample_data):
    result = process(sample_data)
    assert result is not None

@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_multiply(input, expected):
    assert multiply(input, 2) == expected
```

- **Fixtures** in `conftest.py` for reusable test data
```python
import pytest

@pytest.fixture
def sample_data():
    return {"key": "value"}
```

- **Mocking** for external dependencies
```python
from unittest.mock import Mock, patch

@patch('module.external_api_call')
def test_with_mock(mock_api):
    mock_api.return_value = {"status": "ok"}
    result = function_that_calls_api()
    assert result == expected
```

- Organize tests: **unit**, **integration**, **e2e**
```
tests/
├── unit/
├── integration/
└── e2e/
```

- Measure **coverage**
```bash
pytest --cov=src --cov-report=html
```

- Test configuration: `pytest.ini`
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --strict-markers
```

---

## 🔟 Performance & Profiling

### Performance Budgets
- API responses: <200ms (p95)
- Image processing: <1s per image
- Memory usage: <500MB for typical operations
- Startup time: <2s

- **Profile before optimizing** (measure, don't guess)
```python
import cProfile
import pstats
from functools import wraps
import time

# Simple timing decorator
def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        duration = time.perf_counter() - start
        print(f"{func.__name__} took {duration:.4f}s")
        return result
    return wrapper

# Full profiling
profiler = cProfile.Profile()
profiler.enable()
# Code to profile
profiler.disable()
stats = pstats.Stats(profiler)
stats.sort_stats('cumtime')
stats.print_stats(10)
```

- Use **generators** for large data processing (files >100MB, streams)
```python
from pathlib import Path
from typing import Iterator

def read_large_file(file_path: Path) -> Iterator[str]:
    """Memory-efficient file reading."""
    with open(file_path) as f:
        for line in f:
            yield line.strip()

# Chaining generators
def process_lines(file_path: Path) -> Iterator[dict]:
    for line in read_large_file(file_path):
        if line:  # Skip empty lines
            yield {"data": line.upper()}
```

- Consider **async/await** for I/O-bound operations
```python
import asyncio
import aiohttp

async def fetch_data(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url) as response:
        return await response.json()

async def main():
    async with aiohttp.ClientSession() as session:
        results = await asyncio.gather(
            fetch_data(session, url1),
            fetch_data(session, url2),
            fetch_data(session, url3),
        )
```

---

## 1️⃣1️⃣ Documentation

- **README.md** should include:
  - Project description
  - Installation instructions
  - Usage examples
  - Configuration options
  - Contributing guidelines
  - License

- **API documentation** with Sphinx or MkDocs
- **Type stubs** (`.pyi`) for untyped libraries if needed

---

## 1️⃣2️⃣ Python Idioms & Best Patterns

- **Context managers** for cleanup
```python
from contextlib import contextmanager

@contextmanager
def managed_resource():
    resource = acquire_resource()
    try:
        yield resource
    finally:
        release_resource(resource)
```

- **EAFP** (Easier to Ask for Forgiveness than Permission)
```python
# ✅ Good - Pythonic
try:
    value = my_dict[key]
except KeyError:
    value = default

# ❌ Less Pythonic
if key in my_dict:
    value = my_dict[key]
else:
    value = default

# ✅ Even better - use dict methods
value = my_dict.get(key, default)
```

- Use **enumerate** and **zip**
```python
for idx, item in enumerate(items, start=1):
    print(f"{idx}: {item}")

for x, y in zip(list1, list2, strict=True):  # Python 3.10+
    print(f"{x} - {y}")
```

- **Structural pattern matching** (Python 3.10+)
```python
def process_command(command: dict):
    match command:
        case {"action": "create", "item": item}:
            create_item(item)
        case {"action": "delete", "id": item_id}:
            delete_item(item_id)
        case _:
            raise ValueError(f"Unknown command: {command}")
```

---

## 1️⃣3️⃣ Security Best Practices

- **Input validation**: Sanitize all external inputs
```python
import re
from pathlib import Path

def safe_filename(filename: str) -> str:
    """Remove dangerous characters from filename."""
    return re.sub(r'[^\w\s.-]', '', filename)

def safe_path(base_dir: Path, user_path: str) -> Path:
    """Prevent path traversal attacks."""
    full_path = (base_dir / user_path).resolve()
    if not full_path.is_relative_to(base_dir):
        raise ValueError("Path traversal detected")
    return full_path
```

- **SQL injection**: Always use parameterized queries
```python
# ✅ Good
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))

# ❌ Dangerous
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

- **Dependency scanning**
```bash
pip install pip-audit safety
pip-audit  # Scan for known vulnerabilities
safety check  # Alternative scanner
```

- **Secrets management**
```python
# For development: python-dotenv
# For production: Use cloud secret managers (AWS Secrets Manager, Azure Key Vault)
import keyring

# Store secret
keyring.set_password("myapp", "api_key", secret_value)

# Retrieve secret
api_key = keyring.get_password("myapp", "api_key")
```

---

## 1️⃣4️⃣ Computer Vision Best Practices

- Use **OpenCV** or **Pillow** for image processing
```python
import cv2
import numpy as np
from PIL import Image
from pathlib import Path

def load_image_safe(image_path: Path) -> np.ndarray | None:
    """Load image with error handling."""
    try:
        img = cv2.imread(str(image_path))
        if img is None:
            logger.error(f"Failed to load image: {image_path}")
            return None
        return img
    except Exception as e:
        logger.error(f"Error loading {image_path}: {e}")
        return None

def normalize_image(img: np.ndarray) -> np.ndarray:
    """Normalize image to 0-1 range."""
    return img.astype(np.float32) / 255.0

def preprocess_for_model(
    img: np.ndarray,
    target_size: tuple[int, int] = (224, 224)
) -> np.ndarray:
    """Preprocess image for model input.
    
    Args:
        img: Input image (H, W, C) in BGR format
        target_size: Target dimensions (width, height)
        
    Returns:
        Preprocessed image ready for model
    """
    # Resize
    img = cv2.resize(img, target_size)
    # Convert BGR to RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    # Normalize
    img = normalize_image(img)
    return img
```

- **Handle image formats** explicitly
```python
from typing import Literal

ImageFormat = Literal["jpg", "png", "bmp", "tiff"]

def save_image(
    img: np.ndarray,
    path: Path,
    format: ImageFormat = "png"
) -> bool:
    """Save image in specified format."""
    try:
        cv2.imwrite(str(path), img)
        return True
    except Exception as e:
        logger.error(f"Failed to save image: {e}")
        return False
```

- **Lazy loading** for large datasets
```python
from torch.utils.data import Dataset
from typing import Callable

class LazyImageDataset(Dataset):
    """Load images on demand to save memory."""
    
    def __init__(
        self,
        image_paths: list[Path],
        transform: Callable | None = None
    ):
        self.image_paths = image_paths
        self.transform = transform
    
    def __len__(self) -> int:
        return len(self.image_paths)
    
    def __getitem__(self, idx: int) -> np.ndarray:
        img = load_image_safe(self.image_paths[idx])
        if img is None:
            raise ValueError(f"Failed to load image at index {idx}")
        if self.transform:
            img = self.transform(img)
        return img
```

---

## 1️⃣5️⃣ CI/CD Integration

- **GitHub Actions** workflow example (.github/workflows/test.yml):
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt -r requirements-dev.txt
      
      - name: Lint with ruff
        run: ruff check src/ tests/
      
      - name: Type check with mypy
        run: mypy src/
      
      - name: Test with pytest
        run: pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
```

- **Coverage thresholds** in pytest.ini or pyproject.toml:
```ini
[tool.pytest.ini_options]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=80"
```

---

## 1️⃣6️⃣ Common Anti-Patterns to Avoid

### ❌ Mutable Default Arguments
```python
# Bad
def add_item(item, items=[]):
    items.append(item)
    return items

# Good
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### ❌ Bare Except Clauses
```python
# Bad
try:
    risky_operation()
except:
    pass

# Good
try:
    risky_operation()
except (ValueError, KeyError) as e:
    logger.error(f"Operation failed: {e}")
    raise
```

### ❌ String Concatenation in Loops
```python
# Bad - O(n²) complexity
result = ""
for item in items:
    result += str(item)

# Good - O(n) complexity
result = "".join(str(item) for item in items)
```

### ❌ Using Global Variables
```python
# Bad
CACHE = {}

def get_data(key):
    global CACHE
    return CACHE.get(key)

# Good - dependency injection
class DataService:
    def __init__(self):
        self.cache: dict = {}
    
    def get_data(self, key):
        return self.cache.get(key)
```

### ❌ Ignoring Return Values
```python
# Bad
list.sort()  # Returns None, modifies in place

# Good - be explicit
my_list.sort()  # Modify in place
sorted_list = sorted(my_list)  # Create new sorted list
```

---

## 1️⃣7️⃣ Python Version Compatibility

- **Target**: Python 3.10+ (for modern features)
- **Support**: Test against multiple versions in CI
```python
import sys

if sys.version_info < (3, 10):
    raise RuntimeError("Python 3.10+ required")

# Use feature flags for version-specific code
PYTHON_310_PLUS = sys.version_info >= (3, 10)
```

- **Document breaking changes** in CHANGELOG.md
- Use **pyupgrade** to modernize code syntax
```bash
pyupgrade --py310-plus src/**/*.py
```

---

## 1️⃣8️⃣ Effective AI Prompting Patterns

### General Principles
- Be **specific and explicit** about requirements
- Provide **context** about the project and architecture
- Request **complete implementations** with all necessary components
- Specify **quality requirements** (type hints, tests, docs)

### Prompting Templates

#### For New Features
```
Create a {feature} that {does X} for {purpose}.

Requirements:
- Use {specific libraries/frameworks}
- Include type hints and Google-style docstrings
- Add input validation and error handling with custom exceptions
- Include logging at appropriate levels
- Write pytest unit tests with >80% coverage
- Handle edge cases: {list specific cases}
- Performance: {specify constraints}

Example usage: {provide code example}
```

#### For Refactoring
```
Refactor {code/module/function} to:
- Follow PEP 8 and add type hints
- Improve error handling with specific exceptions
- Add comprehensive docstrings (Google style)
- Optimize for {performance/readability/maintainability}
- Maintain backward compatibility
- Add tests for existing functionality
```

#### For Debugging
```
Debug {issue} in {file/function}.

Symptoms: {describe behavior}
Expected: {describe expected behavior}
Context: {relevant information}

Please:
1. Identify root cause
2. Propose fix with explanation
3. Add test to prevent regression
4. Check for similar issues elsewhere
```

#### For Testing
```
Write comprehensive pytest tests for {module/function}.

Include:
- Unit tests for all public functions
- Fixtures for common test data
- Parametrized tests for multiple scenarios
- Mocking for external dependencies
- Edge cases and error conditions
- Coverage should be >80%
```

#### For Computer Vision Tasks
```
Create an image processing pipeline that {purpose}.

Input: {image format, dimensions, channels}
Output: {expected format}

Requirements:
- Use OpenCV/Pillow for processing
- Handle missing/corrupted images gracefully
- Normalize inputs to {range}
- Support batch processing for efficiency
- Log processing statistics
- Include visualization function for debugging
```

### Code Quality Requests
Always explicitly request:
- "Include type hints for all parameters and return values"
- "Add Google-style docstrings with Args, Returns, Raises"
- "Implement proper error handling with custom exceptions"
- "Add logging at INFO level for operations, DEBUG for details"
- "Write pytest tests with fixtures and mocking"
- "Follow PEP 8 and use modern Python 3.10+ syntax"
- "Validate all inputs early"
- "Use pathlib.Path for file operations"
