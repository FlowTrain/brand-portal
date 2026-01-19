# Contributing to FlowTrain Projects

Thank you for your interest in contributing! We appreciate all forms of contribution—code, documentation, bug reports, feature ideas, and more.

## 🎯 Code of Conduct

We're committed to providing a welcoming and inclusive environment. Please review and uphold our values:

- **Respectful** — Treat everyone with respect
- **Collaborative** — Work together in good faith
- **Inclusive** — Welcome diverse perspectives

## 🐛 Reporting Issues

1. **Check existing issues** first—your problem may already be reported
2. **Use the issue template** — Provide:
   - Clear title and description
   - Steps to reproduce
   - Expected vs. actual behavior
   - Environment (OS, version, etc.)
   - Screenshots if applicable

## ✨ Proposing Features

1. **Open a discussion** or issue describing:
   - Problem being solved
   - Proposed solution
   - Alternative approaches considered
   - Any potential impact on existing functionality

2. **Wait for feedback** from maintainers before starting major work

## 💻 Making Changes

### Branch Strategy

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or for a bug fix
git checkout -b fix/issue-number-description
```

### Commit Guidelines

- **Atomic commits** — One logical change per commit
- **Clear messages** — Use present tense (\"Add feature\" not \"Added feature\")
- **Reference issues** — Link related issues (\"Fixes #123\")

```bash
git commit -m \"feat: add new feature (fixes #123)\"
```

### Code Style

- Follow the existing code style in the project
- Use linters and formatters (run `make lint`)
- Document complex logic with comments
- Keep functions small and focused

### Testing

- Add tests for new features
- Ensure all tests pass locally: `make test`
- Update documentation if behavior changes

## 📤 Submitting a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a PR** on GitHub with:
   - Clear title and description
   - Reference to related issues (\"Fixes #123\")
   - Screenshots or demos if applicable
   - Checklist:
     - [ ] Tests pass locally
     - [ ] Code follows project style
     - [ ] Documentation updated

3. **Respond to feedback** — Maintainers may request changes

4. **Merge** — Once approved, we'll merge your PR

## 🔄 Review Process

All PRs go through:
1. **Automated checks** (CI/CD, linting, tests)
2. **Code review** by maintainers
3. **Feedback & iteration**
4. **Merge** once approved

## 📚 Development Setup

```bash
# Clone and navigate
git clone https://github.com/FlowTrain/project-name.git
cd project-name

# Install development dependencies
make install-dev

# Start development server (if applicable)
make dev

# Run tests
make test

# Run linter
make lint
```

## 🆘 Need Help?

- **Questions?** Start a [Discussion](https://github.com/FlowTrain/project-name/discussions)
- **Found a bug?** [Open an Issue](https://github.com/FlowTrain/project-name/issues)
- **Have a suggestion?** [Start a Discussion](https://github.com/FlowTrain/project-name/discussions)

## ✅ Contributor Checklist

Before submitting your PR, verify:

- [ ] Branch created from latest `main`
- [ ] Code follows project style
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No unrelated changes included
- [ ] PR description is detailed

## 🙏 Thank You!

Your contributions make FlowTrain better for everyone. We truly appreciate your effort and time!

---

**Questions about contributing?** Ask in [Discussions](https://github.com/FlowTrain/project-name/discussions).
