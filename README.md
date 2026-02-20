<div align="center">

# 🚀 Prompt Engineering Templates

### *Near-Production-Ready AI-Powered Development Blueprints*

[![React](https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-000000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/features/copilot)

**A comprehensive collection of battle-tested prompt templates, GitHub Copilot instructions, and prompt engineering guides for building production-grade applications with AI-augmented development.**

[🎯 Quick Start](#-quick-start) • [📚 Documentation](#-repository-structure) • [🛠️ Templates](#-whats-included) • [🔒 Security](#-security--quality-tools) • [⭐ Star Us](#-call-to-action)

---

</div>

## 🎯 What is This?

This repository is your **complete toolkit for AI-augmented software development**. Whether you're building a React frontend, Python backend, or full-stack application, you'll find:

- **🤖 GitHub Copilot Instructions** - Pre-configured rulesets that make Copilot follow best practices automatically
- **📝 Reusable Prompt Templates** - Copy-paste prompts for common development tasks
- **📖 Prompt Engineering Guides** - Learn the principles, patterns, and techniques
- **🔧 Setup Scripts** - Get started quickly with automated project setup
- **🔒 Security-First Approach** - Integrated Codacy and Snyk best practices

> *Crafted with ❤️ in Paris by [kunalsuri](https://github.com/kunalsuri) — blending Human Intelligence with cutting-edge AI systems (Human-in-the-Loop).*

---

## 🎨 Key Features

<table>
<tr>
<td width="33%" valign="top">

### 🎯 **Multi-Stack Support**
- React + TypeScript
- Python 3.12+
- FastAPI + React Full-Stack
- Modular architecture patterns

</td>
<td width="33%" valign="top">

### 🤖 **AI-First Development**
- GitHub Copilot optimized
- Context-aware instructions
- Security scanning built-in
- Prompt engineering best practices

</td>
<td width="33%" valign="top">

### 📚 **Complete Learning Path**
- Prompt engineering 101
- Real-world examples
- Multi-agent workflows
- Custom GPT guides

</td>
</tr>
</table>

---

## 📚 Repository Structure

```
📦 prompt-engineering-templates-public
├── 🤖 .github/                          # Base GitHub Copilot instructions
├── 🐍 .github-python/                   # Python-specific instructions & prompts
│   ├── copilot-instructions.md          # Python dev standards (PEP 8, type hints)
│   ├── prompts/                         # Python project prompts
│   └── instructions/                    # Codacy rules for Python
├── ⚛️  .github-react-typescript/        # React + TypeScript instructions
│   ├── copilot-instructions.md          # React best practices (hooks, Tailwind)
│   ├── prompts/                         # React feature prompts
│   └── instructions/                    # Security & quality rules
├── 🔄 .github-react-python-fastapi/     # Full-stack (React + FastAPI)
│   ├── copilot-instructions.md          # Full-stack architecture guidelines
│   ├── prompts/                         # Full-stack app creation prompts
│   └── instructions/                    # Integrated security rules
├── 📖 prompt-engineering-101/           # Complete learning guide
│   ├── 01-introduction.md               # What is prompt engineering?
│   ├── 02-principles.md                 # Core principles
│   ├── 03-patterns.md                   # Common patterns (few-shot, CoT)
│   ├── 04-best-practices.md             # Production tips
│   ├── comparisons/                     # Framework comparisons
│   ├── prompt-examples/                 # Real-world examples
│   │   ├── agents/                      # Agent-specific prompts
│   │   ├── creative/                    # Creative use cases
│   │   └── general/                     # Brainstorming, translation
│   └── templates/                       # Reusable prompt templates
├── 🎯 generic-user-prompts/             # Ready-to-use prompt examples
│   ├── generic-examples-py.prompt.md    # Python examples
│   └── generic-examples-react.prompt.md # React examples
├── 🛠️ scripts-utils/                    # Project setup automation
│   ├── scripts-python/                  # Python project setup
│   ├── scripts-react-typescript/        # React project setup
│   └── scripts-react-python-fastapi/    # Full-stack setup
└── 📄 docs/                             # Additional documentation
```

---

## 🛠️ What's Included

### 🤖 GitHub Copilot Instructions

Pre-configured instruction files that automatically guide Copilot to:

- **Follow Best Practices** - PEP 8 for Python, React hooks patterns, TypeScript strict mode
- **Maintain Architecture** - Feature-driven modular structure
- **Enforce Security** - Input validation, no hardcoded secrets, sanitized outputs
- **Ensure Quality** - Type hints, error handling, accessibility standards

**Supported Stacks:**
- `✅ React + TypeScript` - Modern frontend with Tailwind CSS, Zustand, TanStack Query
- `✅ Python 3.12+` - Backend with type hints, dataclasses, async patterns
- `✅ FastAPI + React` - Full-stack with unified architecture

### 📝 Prompt Templates

**Development Tasks:**
- Creating full-stack SaaS applications
- Generating comprehensive test suites
- Building multi-agent workflows
- Code auditing and refactoring

**Specialized Prompts:**
- `agents/` - Research helpers, code auditors, planning agents
- `creative/` - Character building, plot generation
- `general/` - Brainstorming, summarization, translation

### 📖 Prompt Engineering Education

**Complete Learning Path:**
1. **Introduction** - Fundamentals of prompt engineering
2. **Principles** - Clarity, context, iterative refinement
3. **Patterns** - Few-shot learning, chain-of-thought, role-playing
4. **Best Practices** - Production-ready techniques
5. **Comparisons** - Framework analysis (ReAct, Chain-of-Thought)
6. **Real Examples** - ChatGPT, local LLMs, multi-agent systems

---

## 🚀 Quick Start

### Option 1: Use as Template Repository

```bash
# Clone this repository as a starting point
git clone https://github.com/kunalsuri/prompt-engineering-templates-public.git my-project
cd my-project

# Choose your stack and copy instructions to .github/
cp .github-react-typescript/* .github/     # For React projects
# OR
cp .github-python/* .github/                # For Python projects
# OR
cp .github-react-python-fastapi/* .github/  # For Full-Stack projects

# Start coding - Copilot will follow the instructions automatically!
```

### Option 2: Cherry-Pick Instructions

```bash
# Add to your existing project
cd your-existing-project

# Copy just the Copilot instructions you need
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/kunalsuri/prompt-engineering-templates-public/main/.github-react-typescript/copilot-instructions.md
```

### Option 3: Learn Prompt Engineering

```bash
# Explore the educational content
cd prompt-engineering-templates-public/prompt-engineering-101

# Read in order:
# 01-introduction.md → 02-principles.md → 03-patterns.md → 04-best-practices.md
```

---

## 💡 How It Works

### 1️⃣ **Automatic Best Practices**

When you have Copilot instruction files in your `.github/` folder, GitHub Copilot automatically:

```typescript
// ❌ Without instructions, Copilot might generate:
function getData() {
  const data: any = fetchAPI();
  return data;
}

// ✅ With instructions, Copilot generates:
interface ApiResponse {
  id: string;
  name: string;
}

async function getData(): Promise<ApiResponse> {
  try {
    const response = await fetchAPI();
    return response;
  } catch (error) {
    logger.error('Failed to fetch data', error);
    throw new ApiError('Data fetch failed');
  }
}
```

### 2️⃣ **Context-Aware Generation**

Copilot understands your project structure and generates code that fits:

- **Frontend** - Respects `src/features/` structure, uses Zustand for state
- **Backend** - Follows `app/api/` patterns, uses Pydantic validation
- **Full-Stack** - Maintains contract between frontend and backend

### 3️⃣ **Security by Default**

Built-in security scanning with:
- **Codacy** - Automatic code quality and security checks
- **Snyk** - Dependency vulnerability scanning
- **Instructions** - Prevents common security anti-patterns

---

## 🔒 Security & Quality Tools

### 🛡️ Integrated Security Scanning

This repository includes automated security checks:

**Codacy MCP Integration**
- ✅ Runs automatically after file edits
- ✅ Detects security vulnerabilities
- ✅ Enforces code quality standards
- ✅ Scans dependencies with Trivy

**Snyk Security at Inception**
- ✅ Scans newly generated code
- ✅ Checks for vulnerabilities in dependencies
- ✅ Provides fix suggestions
- ✅ Rescans after fixes

### 🔧 Recommended VS Code Extensions

<table>
<tr>
<td>

**[Codacy](https://marketplace.visualstudio.com/items?itemName=codacy-app.codacy)**
- Static code analysis
- Real-time security scanning
- Code quality metrics
- Git workflow integration

</td>
<td>

**[CodeQL](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql)**
- Semantic code analysis
- Advanced vulnerability detection
- Custom security queries
- Database-backed scanning

</td>
</tr>
</table>

---

## 🎓 Use Cases

### For Individual Developers
- **Learn prompt engineering** from basics to advanced patterns
- **Bootstrap new projects** with production-ready templates
- **Improve AI interactions** with proven prompting techniques

### For Teams
- **Standardize coding practices** across the organization
- **Onboard faster** with automated best practices
- **Maintain consistency** in AI-generated code

### For AI Enthusiasts
- **Explore multi-agent systems** with example workflows
- **Build custom GPTs** with provided templates
- **Experiment with local LLMs** using example prompts

---

## 📖 Documentation

### 🎯 Getting Started Guides

| Guide | Description | Link |
|-------|-------------|------|
| Prompt Engineering 101 | Complete beginner's guide | [📖 Read](./prompt-engineering-101/readme.md) |
| React + TypeScript Setup | Frontend development guide | [⚛️ Instructions](./.github-react-typescript/copilot-instructions.md) |
| Python Development | Backend best practices | [🐍 Instructions](./.github-python/copilot-instructions.md) |
| Full-Stack Guide | React + FastAPI integration | [🔄 Instructions](./.github-react-python-fastapi/copilot-instructions.md) |

### 📚 Advanced Topics

- **Multi-Agent Workflows** - [Examples](./prompt-engineering-101/prompt-examples/multi-agent-workflows.md)
- **Custom GPT Creation** - [Guide](./docs/custom-gpt/README.md)
- **Local LLM Integration** - [Examples](./prompt-engineering-101/prompt-examples/local-llm-examples.md)
- **Code Auditing Agents** - [Template](./prompt-engineering-101/prompt-examples/agents/code-audit.md)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **🐛 Report Issues** - Found a bug or have a suggestion? [Open an issue](https://github.com/kunalsuri/prompt-engineering-templates-public/issues)
2. **📝 Submit PRs** - Improve documentation, add examples, fix bugs
3. **⭐ Share Knowledge** - Add your own prompt templates or best practices
4. **💬 Spread the Word** - Share this repository with your team

**Before Contributing:**
- Review existing instructions for style consistency
- Test your prompts with GitHub Copilot
- Include examples and documentation
- Follow security best practices

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

**TL;DR:** You can use, modify, and distribute this project freely. Just keep the original license notice.

---

## ⚠️ Disclaimer

This project has been developed using AI-assisted development tools including:
- Visual Studio Code with GitHub Copilot Pro
- Windsurf, Cursor, and other AI coding assistants
- Human-in-the-Loop supervision and review

**Security Notice:**
- All code has been validated and scanned
- Malware scanning and static analysis applied (CodeQL)
- However, NO WARRANTY is provided
- Review AI-generated code before production use

**Use at your own discretion and risk.** This software is provided "as is" without any warranties.

---

## 🌟 Call to Action

**Find this useful? Here's how to support:**

<div align="center">

### ⭐ Star this repository to show your support!

[![Star History Chart](https://api.star-history.com/svg?repos=kunalsuri/prompt-engineering-templates-public&type=Date)](https://star-history.com/#kunalsuri/prompt-engineering-templates-public&Date)

**🔔 Watch for updates** • **🍴 Fork for your projects** • **💬 Share with your team**

</div>

---

## 📞 Connect

- **GitHub**: [@kunalsuri](https://github.com/kunalsuri)
- **Issues**: [Report bugs or request features](https://github.com/kunalsuri/prompt-engineering-templates-public/issues)
- **Discussions**: Share your experience and ask questions

---

<div align="center">

**Built with 💻 & 🤖 in Paris** | **Human Intelligence + AI Augmentation**

*Empowering developers to build better software, faster.*

</div>
