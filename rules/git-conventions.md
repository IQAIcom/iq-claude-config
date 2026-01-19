# Git Conventions

## Commit Messages

Use Conventional Commits format:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, no code change
- `refactor` - Code change that neither fixes nor adds
- `perf` - Performance improvement
- `test` - Adding tests
- `chore` - Maintenance tasks

### Examples
```bash
feat(auth): add social login with Google
fix(api): handle null response from external service
docs(readme): update installation instructions
refactor(user): extract validation logic
chore(deps): update dependencies
```

### Rules
- Use lowercase
- No period at the end
- Keep subject under 72 characters
- Use imperative mood ("add" not "added")

## Branch Naming

```
<type>/<short-description>
```

### Examples
```
feat/user-authentication
fix/login-redirect-loop
chore/update-dependencies
```

## Pull Requests

### Title
Same format as commits:
```
feat(auth): add social login with Google
```

### Description
- Explain what and why
- Include testing instructions
- Reference related issues
- Add screenshots for UI changes

## Workflow

1. Create feature branch from `main`
2. Make commits (small, atomic)
3. Push and create PR
4. Get review
5. Squash merge to `main`

## Don't Commit

- `.env` files
- `node_modules/`
- Build artifacts
- IDE settings (unless shared)
- `console.log` debugging
