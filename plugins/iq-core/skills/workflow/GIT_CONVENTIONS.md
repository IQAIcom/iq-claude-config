# Git Conventions

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding tests |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |
| `revert` | Revert previous commit |

### Scope (optional)

Module or component affected:
- `auth`, `api`, `ui`, `db`, `config`, etc.

### Examples

```bash
feat(auth): add Google OAuth login
fix(api): handle null response from payment service
docs(readme): update installation instructions
refactor(user): extract validation into separate module
chore(deps): update dependencies
test(auth): add tests for password reset flow
perf(db): add index to improve query performance
```

### Rules

- Use lowercase
- No period at end
- Keep subject under 72 characters
- Use imperative mood ("add" not "added")
- Separate subject from body with blank line

### Body (optional)

```bash
fix(auth): prevent session fixation attack

The previous implementation reused session IDs after login,
which could allow session fixation attacks. Now we regenerate
the session ID after successful authentication.

Closes #123
```

## Branch Naming

```
<type>/<description>
```

### Examples

```
feat/user-authentication
fix/login-redirect-loop
docs/api-documentation
chore/update-dependencies
refactor/extract-validation
```

### Rules

- Use lowercase
- Use hyphens (not underscores)
- Keep it short but descriptive
- Include ticket number if applicable: `feat/AUTH-123-oauth-login`

## Workflow

### Feature Development

```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feat/my-feature

# 3. Make commits (small, atomic)
git add .
git commit -m "feat: add feature skeleton"
git commit -m "feat: implement core logic"
git commit -m "test: add unit tests"

# 4. Push and create PR
git push origin feat/my-feature
# Create PR on GitHub

# 5. After approval, squash merge to main
# (Done via GitHub PR interface)
```

### Hotfix

```bash
git checkout main
git pull origin main
git checkout -b fix/critical-bug
# Make fix
git commit -m "fix: resolve critical bug"
git push origin fix/critical-bug
# Create PR, get expedited review, merge
```

## PR Merge Strategy

**Squash and Merge** (default)
- All commits become one
- Clean main history
- PR title becomes commit message

```
feat(auth): add Google OAuth login (#123)
```

## Protected Branches

- `main` - Production code
  - Require PR reviews
  - Require status checks
  - No direct pushes

## Don't Commit

- `.env` files (Secrets)
- `node_modules/` (Dependencies)
- Build artifacts (`dist/`, `.next/`)
- IDE settings (unless shared)
- `console.log` debugging code

## .gitignore Essentials

```gitignore
# Dependencies
node_modules/

# Environment
.env
.env.local
.env*.local

# Build
.next/
dist/
build/

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Test
coverage/

# Prisma
prisma/*.db
```
