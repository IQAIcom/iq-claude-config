# PR Templates

## Default Template

Create `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Summary

Brief description of what this PR does.

## Changes

- Change 1
- Change 2

## Type

- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] Chore

## Screenshots

(if UI changes, add before/after screenshots)

## Testing

- [ ] How to test this change
- [ ] Edge cases verified

## Checklist

- [ ] Self-reviewed
- [ ] Types are correct (no `any`)
- [ ] No `console.log` statements
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Migrations included (if DB changes)

## Related

- Closes #issue_number
- Related to #issue_number
```

## Feature Template

Create `.github/PULL_REQUEST_TEMPLATE/feature.md`:

```markdown
## Feature: [Name]

### What
Brief description of the feature.

### Why
Why is this feature needed?

### How
Technical approach taken.

## Changes

### Added
- New file/component/function

### Modified
- Existing file changes

## Demo

(Screenshots, GIFs, or video)

## Testing

### Manual Testing
1. Step 1
2. Step 2
3. Expected result

### Automated Tests
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] E2E tests added

## Checklist

- [ ] Follows coding standards
- [ ] Accessible (keyboard nav, screen readers)
- [ ] Responsive design verified
- [ ] Error states handled
- [ ] Loading states implemented
- [ ] Documentation updated

## Deployment Notes

Any special deployment considerations?

## Related

- Closes #issue_number
```

## Bug Fix Template

Create `.github/PULL_REQUEST_TEMPLATE/bugfix.md`:

```markdown
## Bug Fix: [Brief Description]

### Problem
What was the bug?

### Root Cause
Why did it happen?

### Solution
How does this PR fix it?

## Reproduction Steps (Before)

1. Step 1
2. Step 2
3. Bug occurs

## Verification Steps (After)

1. Step 1
2. Step 2
3. Works correctly

## Changes

- File 1: Description of change
- File 2: Description of change

## Testing

- [ ] Bug no longer reproducible
- [ ] No regression in related functionality
- [ ] Test added to prevent recurrence

## Checklist

- [ ] Root cause identified
- [ ] Minimal change (no scope creep)
- [ ] Related tests pass

## Related

- Fixes #issue_number
```

## Refactor Template

Create `.github/PULL_REQUEST_TEMPLATE/refactor.md`:

```markdown
## Refactor: [Area/Component]

### What
What is being refactored?

### Why
Why is this refactor needed?
- [ ] Improve readability
- [ ] Reduce complexity
- [ ] Better performance
- [ ] Remove duplication
- [ ] Prepare for future feature

### Approach
How was this refactored?

## Changes

### Before
Brief description of old approach.

### After
Brief description of new approach.

## Metrics (if applicable)

| Metric | Before | After |
|--------|--------|-------|
| Lines of code | X | Y |
| Complexity | X | Y |
| Bundle size | X | Y |

## Verification

- [ ] All existing tests pass
- [ ] No behavior changes
- [ ] Performance not degraded

## Checklist

- [ ] No functional changes
- [ ] Tests updated (if structure changed)
- [ ] No new dependencies added

## Related

- Related to #issue_number
```

## Using Multiple Templates

When you have multiple templates, GitHub shows a dropdown. Structure:

```
.github/
├── PULL_REQUEST_TEMPLATE/
│   ├── feature.md
│   ├── bugfix.md
│   └── refactor.md
└── PULL_REQUEST_TEMPLATE.md  # Default
```
