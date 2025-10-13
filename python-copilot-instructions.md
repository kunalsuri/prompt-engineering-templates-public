# 🧠 **General + Python (LLM / AI / Evaluation) Ruleset**

## 🏁 Meta Rules

* Ensure strict adherence to current **industry best practices** for ML/LLM engineering, evaluation, and reproducibility.
* Follow **Feature-Driven Modular Architecture** — separate `data`, `models`, `prompts`, `eval`, `serving`, `scripts`, and `utils`.
* **Audit, refactor, and fix** existing issues before adding new features. Avoid speculative or hallucinated code.
* Prioritize **readability, simplicity, maintainability, and explicitness**.
* Prefer **small, single-responsibility modules and functions**.
* Rules apply **exclusively to Python projects** for LLM/AI/Evaluation.

---

## 🧩 Environment & Packaging

* Use `pyproject.toml` + **Poetry** or **pip-tools** for deterministic dependencies. Pin exact versions.
* Use isolated virtual environments (`venv`) and document setup in `README.md`.
* Provide a **Dockerfile** (GPU + CPU variants) for reproducible runtime.
* Use `nox` or `tox` for test matrices.
* Document non-deterministic GPU operations (`torch.use_deterministic_algorithms(True)` where feasible).

---

## 💅 Code Style & Static Checking

* Follow **PEP8** and 120-char line limit.
* Use **Black** (formatting), **isort** (imports), **ruff** (lint), and **mypy** (strict mode).
* Avoid `Any` unless justified with a comment.
* Use **type hints everywhere** (functions, dataclasses, returns).
* Prefer `TypedDict` / `dataclass` for structured data.
* Enforce static checks in CI via `pre-commit`.

---

## 🧱 Recommended Project Structure

```
/project
  /data          # loaders, processors, dataset metadata
  /models        # model definitions, wrappers (HF, OpenAI, custom)
  /prompts       # templates, templating utilities
  /eval          # evaluation harnesses, metrics, aggregators
  /serving       # API wrappers, FastAPI/Flask app, docker-compose
  /scripts       # one-off scripts, CLI entrypoints
  /tests         # unit & integration tests
  pyproject.toml
  README.md
  Dockerfile
```

---

## 🔁 Reproducibility & Experiment Tracking

* Seed RNGs (Python, NumPy, PyTorch, JAX, TensorFlow) and log seeds.
* Use experiment tracking (**WandB**, **MLflow**, or **Weights & Biases**) to log configs, metrics, and artifacts.
* Store configs via **Hydra** or **omegaconf** under `configs/`.
* Save model checkpoints and tokenizer artifacts with **checksums**.
* Log **dataset version**, **model version**, and **git commit hash** per run.

---

## 🧮 Data Handling & Governance

* Include explicit dataset provenance, license, collection date, and preprocessing details in `data/README.md`.
* Use streaming/batched loaders to prevent memory issues.
* Validate integrity (hashes, schema checks).
* Implement **PII redaction** and license compliance validation.
* Use stratified splits; commit split indices for reproducibility.

---

## 🧠 Models & Efficiency

* Abstract backends (Hugging Face, OpenAI, Anthropic, local LLMs) behind a unified interface (rate limit, retry).
* Use mixed precision (AMP), gradient checkpointing, and efficient tokenizers.
* Use `accelerate` or `torch.compile` for optimization.
* Implement **input truncation strategies** and document token-budget logic.

---

## 🗣️ Prompting & Prompt Management

* Keep prompt templates in `prompts/` using **Jinja2** with strict variable validation.
* Version all prompts and log **exact prompt text** per evaluation run.
* Maintain a prompt-engineering doc describing context, assumptions, and format.

---

## 📊 Evaluation & Metrics

Implement evaluation harnesses in `eval/` supporting:

* **Generic metrics:** Exact-Match (EM), Accuracy, F1
* **Text metrics:** BLEU, ROUGE, sacreBLEU, chrF
* **Semantic metrics:** BERTScore, MoverScore
* **System metrics:** Latency, Throughput, Token-Usage, Cost
* **Statistical tests:** Bootstrap CI, permutation tests
* Produce both **scalar metrics** and **confidence intervals**.
* Log **per-example outputs** for error analysis.
* Include **adversarial & robustness tests** and targeted red-team prompts.
* Use **JSON Schema** (`eval/schema.json`) to standardize evaluation output.

---

## 🧪 Testing & CI

* Use **pytest** for unit and integration tests.
* CI (GitHub Actions / GitLab CI) must run:

  * lint
  * mypy
  * unit tests
  * lightweight eval smoke test
* Add coverage: `pytest --cov` ≥80%.
* Enforce pre-commit hooks for formatting and checks.

---

## 📈 Observability & Monitoring

* For serving: expose metrics (**Prometheus**), structured logs, health checks, and tracing (**OpenTelemetry**).
* Monitor **latency, error rate, token usage**, and **distribution drift**.

---

## 🔒 Security & Safety

* Sanitize and validate all inputs pre-inference.
* Rate-limit and sandbox user-supplied code.
* Apply **safety filters** (toxic content, prompt injection).
* Keep **API keys/secrets** in secure stores (Vault, GitHub Secrets).
* Verify external dataset/model license compatibility.

---

## ⚙️ Performance & Cost Controls

* Use **batching**, **response caching**, and **cost accounting** for predictions.
* Add **fallbacks** for rate limits and graceful degradation.

---

## 📝 Documentation & Deliverables

* Maintain `README.md` with setup, reproducibility, and evaluation steps.
* Provide `CHANGELOG.md` and `CONTRIBUTING.md`.
* Include evaluation report template:

  * CSV/JSON per-example results
  * Aggregated metrics
  * Analysis summary

---

## 🤖 Output Expectations (for AI Agent / Copilot)

* Use **file-prefixed code blocks** for each file, e.g.:

```python
# src/eval/run_eval.py
# comments...
```

* Provide **complete, runnable scripts** and **CLI entrypoints** (`argparse` / `Typer`) with comments.
* Include:

  * `pyproject.toml` or `requirements.txt`
  * `Dockerfile` (CPU & GPU variants)
  * Unit tests for core logic
  * Integration smoke test for evaluation harness
* After code, include:

### ✅ Reproducibility Checklist

* Commands to create env, install deps, run tests, run eval, reproduce a single run (with seed).

### ✅ Integration Checklist

* Required environment variables, secrets, infra (GPU, S3, tracking account).

---

## 📦 Minimal Example Checklist

* `pyproject.toml` or `requirements.txt`
* `src/models/adapter.py`
* `src/prompts/templates/*.j2`
* `src/eval/run_eval.py`
* `tests/test_adapter.py`
* `Dockerfile`
* `README.md`
* 
