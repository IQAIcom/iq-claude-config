# Workflow Skill

Development workflow, processes, and conventions.

## Related Files

- [GIT_CONVENTIONS.md](./GIT_CONVENTIONS.md) - Commit, branch, and PR conventions
- [NPM_PUBLISHING.md](./NPM_PUBLISHING.md) - Publishing packages to npm
- [PR_TEMPLATES.md](./PR_TEMPLATES.md) - Pull request templates
- [PROJECT_BOOTSTRAP.md](./PROJECT_BOOTSTRAP.md) - Starting new projects

## Quick Reference

### Git Workflow
```bash
git checkout -b feat/feature-name  # Create branch
git add .                           # Stage changes
git commit -m "feat: add feature"   # Commit
git push origin feat/feature-name   # Push
# Create PR via GitHub
```

### Commit Types
- `feat:` - New feature
- `fix:` - Bug fix  
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `chore:` - Maintenance

### PR Checklist
- [ ] Tests pass
- [ ] Types check
- [ ] Lint passes
- [ ] Documentation updated
- [ ] Self-reviewed
