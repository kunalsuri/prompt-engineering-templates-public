
# 📝 Copilot Instruction Guide for Designing Python Systems

This file provides **guidelines and best practices** for using Copilot (or any AI coding assistant) to generate high-quality, maintainable Python software.

---


## MVP-First Policy (must be followed before any code is executed)

This project uses a phased "start-small, scale-later" approach. Every new project **must** implement the following minimal baseline (Phase 0) before adding features.

### Phase 0 — Mandatory Minimal Baseline (MVP)

1. Create and activate an isolated virtual environment (`venv`/`conda`).
2. `requirements.txt` with pinned versions; install only from PyPI or official repos.
3. `utils/verify_env.py` that performs:
   - Python version check (>=3.9).
   - Safe `import` checks for each dependency (fail fast with remediation tips).
   - Basic hardware check (detect GPU via PyTorch).
   - Basic filesystem safety: refuse to run if running as root or if working directory is outside a project folder.
   - Webcam / device availability check (if relevant).
4. Deny any automated download+execution of arbitrary remote scripts or executables. All downloads must be verified (signed or checksum) and explicitly approved by a developer.
5. Minimal logging setup using Python `logging` and a `--test` mode that runs deterministic unit tests on sample inputs.
6. Basic unit test scaffold (one test per core function) and test runner command (`pytest` or `unittest`).
7. Guardrail: any code that performs file writes outside `results/`, system package installs, or shell commands must raise a flagged exception and require a human confirmation step (documented in README).
8. Simple static analysis: run `flake8`/`black` formatting and `mypy` type checks before merging.
9. Human-readable error messages and an automated summary report after `verify_env.py` runs, indicating pass/fail and remediation steps.

Only after Phase 0 is fully green (all checks pass, tests succeed, human review complete) may you progress to Phase 1. See Roadmap below for next phases.

---

## Phased Roadmap — Expand deliberately

**Phase 0 (MVP — required)**  

- Implement the Mandatory Minimal Baseline above. Focus on safety, reproducibility, and a single core feature that works reliably in `--test` mode.

**Phase 1 (Basic Features & UX)** — unlock only after Phase 0 green:

- Add flexible CLI flags, improved CLI help, and runtime configuration via a single `config.yaml`.
- Add sample GUI or live demo mode (webcam live) guarded by test-mode toggles.
- Add more unit tests (cover >70% of core logic) and a few integration tests.

**Phase 2 (Automation & CI)** — unlock only after Phase 1 green:

- Add automated CI pipeline that runs `verify_env.py`, linters, type checks, and tests on each PR.
- Add model caching with checksum verification and local model download scripts (no arbitrary remote execution).
- Performance benchmarks and automated profiling; warn if FPS < threshold.

**Phase 3 (Production Hardening)** — unlock only after Phase 2 green and explicit human signoff:

- Production-ready packaging, secure secrets handling, hardened logging/monitoring, and access controls.
- Threat modelling, dependency vulnerability scanning, and periodic security reviews.
- Signed releases and deployment automation (only via documented, auditable pipeline).

**Gating rules:**  

- Promotion to the next phase requires: all tests passing, static checks passing, `verify_env.py` green, and a documented human signoff comment in the PR.

---

## 1️⃣ General Best Practices

- **Readable Code**
  - Follow **PEP 8** style guidelines.
  - Use descriptive variable, function, and class names.
  - Add docstrings for all functions and classes.
  
- **Modular Design**
  - Split code into small, reusable functions.
  - Group related functions into modules.
  - Avoid monolithic scripts; keep `main.py` minimal.

- **Type Hints**
  - Use type annotations for function parameters and return values.
  - Helps with readability, debugging, and static analysis.

- **Error Handling**
  - Catch exceptions where needed.
  - Provide **human-readable error messages**.
  - Use `try-except` blocks but avoid overly broad catches.

- **Logging**
  - Use Python’s `logging` module instead of print statements for important messages.
  - Include log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL.

---

## 2️⃣ Project Structure Recommendations

- Recommended folder layout:

project_name/
├── main.py
├── requirements.txt
├── README.md
├── utils/
│ └── helpers.py
├── modules/
│ └── example_module.py
├── tests/
│ └── test_example.py
└── results/ # optional output folder


- **main.py**: only orchestrates modules; minimal logic here.  
- **utils/**: helper functions for common tasks (logging, verification, environment setup).  
- **modules/**: core business logic or computational modules.  
- **tests/**: unit tests for functions and modules.  

---

## 3️⃣ Dependency & Environment Management

- Always use a **virtual environment**:

python -m venv .venv
source .venv/bin/activate # Unix
.venv\Scripts\activate # Windows

- Keep a **requirements.txt** file with exact versions for reproducibility.
- Optionally, include `pyproject.toml` or `poetry.lock` for more complex projects.

---

## 4️⃣ Code Quality & Safety

- Use **type checking tools**: `mypy`, `pyright`.
- Run **linting tools**: `flake8`, `black` (auto-formatting).
- Use **unit tests** to verify functionality.
- For AI or CV systems:
- Verify environment, device availability (CPU/GPU).
- Handle missing models or datasets gracefully.
- Check runtime performance (FPS, memory usage) if relevant.

---

## 5️⃣ Documentation & Comments

- Always provide **README.md** with:
- Project overview
- Installation & setup instructions
- Run instructions
- Example outputs
- Known issues & troubleshooting
- Use inline comments **sparingly**, only for non-obvious logic.

---

## 6️⃣ Testing & Verification

- Include a `--test` mode or a separate test script for quick verification.
- Unit tests should cover:
- Function return values
- Exceptions
- Edge cases
- For CV or AI systems, verify:
- Model loads correctly
- Sample input produces expected output
- Hardware (GPU/CPU) is detected correctly

---

## 7️⃣ AI-Specific Instructions

When designing AI or ML systems with Copilot:

- Always verify environment dependencies (torch, OpenCV, ultralytics, etc.)
- Include reproducibility steps (seeds, deterministic behavior if possible)
- Auto-detect GPU and fallback to CPU
- Provide clear instructions for downloading or caching models locally
- **Model Validation**:
  - Verify model integrity using checksums or signatures
  - Check model versions and compatibility
  - Validate input/output shapes, data types, and value ranges
- **Data Validation**:
  - Validate input data shapes, types, and ranges before inference
  - Handle missing or corrupted data gracefully
  - Implement data preprocessing pipelines with validation steps
- **Model Monitoring**:
  - Track inference latency and throughput
  - Monitor memory usage during inference
  - Detect model drift or accuracy degradation over time
- **Bias & Fairness**:
  - Evaluate models on diverse datasets
  - Test for biased predictions across different demographic groups
  - Document known limitations and biases
- **Adversarial Robustness**:
  - Test models with edge cases and boundary conditions
  - Consider adversarial examples and input perturbations
  - Implement input sanitization and validation
- **Model Versioning**:
  - Use tools like MLflow, DVC, or Weights & Biases
  - Track model versions, hyperparameters, and metrics
  - Maintain lineage from data to trained model

---

## 8️⃣ Security & Safety Guardrails

**Critical security practices to prevent vulnerabilities:**

- **Input Validation & Sanitization**:
  - Always validate and sanitize user inputs
  - Use allowlists instead of blocklists for input validation
  - Validate file paths to prevent directory traversal attacks
  - Check file types and sizes before processing
  
- **Dependency Security**:
  - Regularly scan dependencies for vulnerabilities using `pip-audit` or `safety`
  - Pin exact versions in `requirements.txt` for reproducibility
  - Use `dependabot` or similar tools for automated security updates
  - Avoid installing packages from untrusted sources

- **Unsafe Code Prevention**:
  - **NEVER use `eval()` or `exec()`** with untrusted input
  - Avoid `pickle` for untrusted data (use JSON, protobuf instead)
  - Use parameterized queries or ORMs to prevent SQL injection
  - Avoid `shell=True` in `subprocess` calls; use argument lists instead
  - Parse XML safely to prevent XXE (XML External Entity) attacks

- **Secrets Management**:
  - Never hardcode API keys, passwords, or tokens in code
  - Use environment variables or secret management tools (e.g., `python-decouple`, `dotenv`)
  - Add `.env` files to `.gitignore`
  - Rotate credentials regularly

- **File System Safety**:
  - Use `pathlib.Path` for safe path operations
  - Validate file paths against allowed directories
  - Set appropriate file permissions
  - Clean up temporary files properly

- **Network Security**:
  - Always use HTTPS for external API calls
  - Implement rate limiting for API endpoints
  - Validate SSL certificates
  - Set timeouts for network requests

- **Data Privacy**:
  - Handle Personally Identifiable Information (PII) according to regulations (GDPR, CCPA)
  - Implement data anonymization where appropriate
  - Securely delete sensitive data after processing
  - Document data retention policies

---

## 9️⃣ Comprehensive Testing Strategy

**Go beyond basic unit tests for robust systems:**

- **Test Types**:
  - **Unit Tests**: Test individual functions and methods in isolation
  - **Integration Tests**: Test interactions between modules and components
  - **End-to-End Tests**: Test complete workflows from start to finish
  - **Performance Tests**: Benchmark critical paths for speed and memory usage
  - **Regression Tests**: Ensure new changes don't break existing functionality

- **Test Coverage**:
  - Aim for **80%+ code coverage** (use `pytest-cov` or `coverage.py`)
  - Prioritize testing critical paths and error handling
  - Include edge cases, boundary conditions, and invalid inputs
  - Test both success and failure scenarios

- **Testing Tools & Frameworks**:
  - Use `pytest` as the primary testing framework
  - Use `pytest-mock` for mocking external dependencies
  - Use `hypothesis` for property-based testing (automatic edge case generation)
  - Use `faker` for generating test data
  - Use `responses` or `httpretty` for mocking HTTP requests

- **Test Fixtures & Mocking**:
  - Create reusable pytest fixtures for common test setups
  - Mock external APIs, databases, and file systems
  - Use dependency injection to make code more testable
  - Avoid testing external services directly in unit tests

- **CI/CD Integration**:
  - Set up GitHub Actions or similar CI/CD pipelines
  - Run tests automatically on every commit/PR
  - Fail builds if tests don't pass or coverage drops
  - Run linting and security scans in CI/CD
  - Example `.github/workflows/test.yml`:

    ```yaml
    name: Tests
    on: [push, pull_request]
    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3
          - uses: actions/setup-python@v4
            with:
              python-version: '3.11'
          - run: pip install -r requirements.txt
          - run: pytest --cov=. --cov-report=xml
          - run: pip-audit
    ```

- **AI/ML-Specific Testing**:
  - Test model loading and initialization
  - Verify predictions on known test cases
  - Test with various input shapes and types
  - Benchmark inference speed and memory usage
  - Test GPU/CPU fallback behavior
  - Validate model outputs are within expected ranges

---

## 🔟 Error Handling & Resource Management

**Robust error handling beyond basic try-except:**

- **Exception Hierarchies**:
  - Create custom exception classes for domain-specific errors
  - Inherit from appropriate built-in exceptions
  - Example:

    ```python
    class ModelError(Exception):
        """Base exception for model-related errors"""
        pass
    
    class ModelLoadError(ModelError):
        """Raised when model fails to load"""
        pass
    ```

- **Resource Cleanup**:
  - Always use context managers (`with` statements) for files, connections, locks
  - Implement `__enter__` and `__exit__` for custom resource classes
  - Use `contextlib.contextmanager` for simple context managers
  - Ensure resources are released even when exceptions occur

- **Graceful Degradation**:
  - Implement fallback behaviors when primary methods fail
  - Provide default values or alternative paths
  - Log degradation events for monitoring
  - Example: fallback to CPU when GPU is unavailable

- **Retry Logic**:
  - Implement exponential backoff for transient failures
  - Use libraries like `tenacity` or `backoff` for retry decorators
  - Set maximum retry limits to avoid infinite loops
  - Example:

    ```python
    from tenacity import retry, stop_after_attempt, wait_exponential
    
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def fetch_data():
        # API call that might fail
        pass
    ```

- **Error Messages**:
  - Provide actionable error messages with context
  - Include suggestions for resolution
  - Log full stack traces for debugging but show user-friendly messages
  - Never expose sensitive information in error messages

---

## 1️⃣1️⃣ Code Review & Quality Assurance

**Maintain high code quality through systematic reviews:**

- **Code Review Checklist**:
  - [ ] Security: No hardcoded secrets, input validation present
  - [ ] Error Handling: Exceptions handled appropriately, resources cleaned up
  - [ ] Testing: Adequate test coverage, edge cases covered
  - [ ] Performance: No obvious bottlenecks, efficient algorithms
  - [ ] Readability: Clear naming, appropriate comments, follows PEP 8
  - [ ] Documentation: Docstrings present, README updated
  - [ ] Type Safety: Type hints used consistently
  - [ ] Dependencies: No unnecessary dependencies, versions pinned

- **Pre-commit Hooks**:
  - Set up `.pre-commit-config.yaml` to run checks automatically
  - Example configuration:

    ```yaml
    repos:
      - repo: https://github.com/psf/black
        rev: 23.3.0
        hooks:
          - id: black
      - repo: https://github.com/pycqa/flake8
        rev: 6.0.0
        hooks:
          - id: flake8
      - repo: https://github.com/pre-commit/mirrors-mypy
        rev: v1.3.0
        hooks:
          - id: mypy
    ```

- **Static Analysis Tools**:
  - **Linting**: `flake8`, `pylint` for code quality
  - **Formatting**: `black`, `isort` for consistent style
  - **Type Checking**: `mypy`, `pyright` for type safety
  - **Security**: `bandit` for security issues
  - **Dead Code**: `vulture` for unused code detection
  - **Complexity**: `radon` for cyclomatic complexity
  - **Import Sorting**: `isort` for organized imports

- **Dependency Auditing**:
  - Run `pip-audit` regularly to check for vulnerabilities
  - Use `pip list --outdated` to find outdated packages
  - Review dependency licenses for compliance
  - Minimize dependency count to reduce attack surface

---

## 1️⃣2️⃣ Reproducibility & Experiment Tracking

**Ensure experiments and results can be reproduced:**

- **Environment Reproducibility**:
  - Use **Docker** for containerized environments
  - Example `Dockerfile`:

    ```dockerfile
    FROM python:3.11-slim
    WORKDIR /app
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    CMD ["python", "main.py"]
    ```

  - Use `docker-compose` for multi-container setups
  - Document system dependencies (CUDA version, OS, etc.)

- **Data Versioning**:
  - Use **DVC (Data Version Control)** for large datasets
  - Track data changes alongside code in git
  - Example:

    ```
    - Use **DVC (Data Version Control)** for large datasets
  - Track data changes alongside code in git
  - Example:

    ```bash
    dvc add data/dataset.csv && git add data/dataset.csv.dvc
    ```

  - Use `git-lfs` for medium-sized binary files

- **Experiment Tracking**:
  - Use **MLflow** or **Weights & Biases** to track experiments
  - Log hyperparameters, metrics, and artifacts
  - Example MLflow usage:

    ```python
    import mlflow
    
    mlflow.start_run()
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_artifact("model.pkl")
    mlflow.end_run()
    ```

- **Configuration Management**:
  - Use configuration files (YAML, JSON, TOML) instead of hardcoded values
  - Use libraries like `hydra`, `pydantic`, or `dynaconf`
  - Keep separate configs for dev, staging, and production
  - Example with `pydantic`:

    ```python
    from pydantic_settings import BaseSettings
    
    class Settings(BaseSettings):
        model_path: str
        batch_size: int = 32
        
        class Config:
            env_file = ".env"
    ```

- **Random Seeds**:
  - Set seeds for reproducibility in ML experiments
  - Example:

    ```python
    import random
    import numpy as np
    import torch
    
    def set_seed(seed=42):
        random.seed(seed)
        np.random.seed(seed)
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    ```

---

## 1️⃣3️⃣ Performance & Scalability

**Optimize for production workloads:**

- **Profiling**:
  - Use `cProfile` for function-level profiling
  - Use `line_profiler` for line-by-line analysis
  - Use `memory_profiler` for memory usage tracking
  - Example: `python -m cProfile -o output.prof script.py`

- **Concurrency & Parallelism**:
  - Use `asyncio` for I/O-bound tasks
  - Use `multiprocessing` for CPU-bound tasks
  - Use `threading` for I/O-bound tasks (with GIL limitations)
  - Use `concurrent.futures` for simpler parallel execution

- **Caching**:
  - Use `functools.lru_cache` for function result caching
  - Use Redis for distributed caching
  - Implement disk caching for expensive computations
  - Cache model predictions when appropriate

- **Batch Processing**:
  - Process data in batches to optimize memory usage
  - Use generators for large datasets
  - Implement streaming for real-time data
  - Use `torch.utils.data.DataLoader` for ML batching

---

## 1️⃣4️⃣ Monitoring & Observability

**Track system behavior in production:**

- **Structured Logging**:
  - Use JSON format for logs in production
  - Include correlation IDs for request tracing
  - Log at appropriate levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - Example:

    ```python
    import logging
    import json
    
    logger = logging.getLogger(__name__)
    logger.info(json.dumps({
        "event": "prediction_made",
        "model_version": "v1.2.3",
        "latency_ms": 45,
        "correlation_id": "abc-123"
    }))
    ```

- **Metrics & Monitoring**:
  - Track key metrics (requests/sec, error rate, latency percentiles)
  - Use Prometheus for metrics collection
  - Create dashboards with Grafana
  - Set up alerts for anomalies

- **Health Checks**:
  - Implement `/health` and `/ready` endpoints for services
  - Check dependencies (database, external APIs) in health checks
  - Return appropriate HTTP status codes

- **Distributed Tracing**:
  - Use OpenTelemetry for distributed tracing
  - Track requests across multiple services
  - Identify performance bottlenecks

---

## 8️⃣ Prompting Copilot Effectively

## 1️⃣5️⃣ Prompting Copilot Effectively

When giving Copilot instructions:

- Specify **project structure** clearly.
- Specify **what should be automated** (installation, environment checks, tests).
- Include **verification steps** for each major component.
- Ask for **readable, modular, well-documented code**.
- Request **self-contained scripts** that can run end-to-end with minimal manual intervention.
- **Request security checks**: Ask Copilot to include input validation, error handling, and resource cleanup.
- **Request comprehensive tests**: Specify test coverage requirements and edge cases to test.
- **Request monitoring**: Ask for logging, metrics, and health checks to be included.
- **Be explicit about safety**: Request that Copilot avoid unsafe patterns (eval, pickle, shell=True).

---

> ✅ Using this file as a reference ensures that Copilot-generated Python systems are:

> - **Secure and safe**: Protected against common vulnerabilities and malicious code
> - **Robust and maintainable**: Well-tested with comprehensive error handling
> - **Production-ready**: Monitored, scalable, and reproducible
> - **AI/ML-optimized**: With proper model validation, monitoring, and bias testing
> - **Modular and reusable**: Clear architecture and separation of concerns
> - **Well-documented**: Easy to understand for collaborators or students

