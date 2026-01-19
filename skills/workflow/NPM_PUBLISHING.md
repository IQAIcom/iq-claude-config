# NPM Publishing

## Package Setup

### package.json

```json
{
  "name": "@your-org/package-name",
  "version": "1.0.0",
  "description": "Package description",
  "main": "dist/index.js",
  "module": "dist/index.mjs",
  "types": "dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  },
  "files": [
    "dist"
  ],
  "scripts": {
    "build": "tsup src/index.ts --format cjs,esm --dts",
    "prepublishOnly": "npm run build"
  },
  "keywords": ["keyword1", "keyword2"],
  "author": "Your Name",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/your-org/package-name"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "declaration": true,
    "declarationMap": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

## Build Tool (tsup)

```bash
npm install tsup -D
```

```typescript
// tsup.config.ts
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['cjs', 'esm'],
  dts: true,
  splitting: false,
  sourcemap: true,
  clean: true,
});
```

## Publishing

### First-time Setup

```bash
# Login to npm
npm login

# For scoped packages, ensure org exists
npm org ls your-org
```

### Versioning

```bash
# Patch (1.0.0 -> 1.0.1) - bug fixes
npm version patch

# Minor (1.0.0 -> 1.1.0) - new features, backward compatible
npm version minor

# Major (1.0.0 -> 2.0.0) - breaking changes
npm version major

# Prerelease
npm version prerelease --preid=beta  # 1.0.0 -> 1.0.1-beta.0
```

### Publish

```bash
# Build and publish
npm run build
npm publish

# For scoped packages (first time)
npm publish --access public

# Publish beta/next
npm publish --tag beta
npm publish --tag next
```

## Changelog

### CHANGELOG.md Format

```markdown
# Changelog

## [1.1.0] - 2024-01-15

### Added
- New feature X

### Changed
- Updated feature Y

### Fixed
- Bug in feature Z

## [1.0.0] - 2024-01-01

### Added
- Initial release
```

## Pre-publish Checklist

- [ ] Tests pass (`npm test`)
- [ ] Types check (`npm run typecheck`)
- [ ] Build succeeds (`npm run build`)
- [ ] Version bumped (`npm version`)
- [ ] Changelog updated
- [ ] README accurate
- [ ] No sensitive data in package

## GitHub Actions (Automated Publishing)

```yaml
# .github/workflows/publish.yml
name: Publish

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci
      - run: npm run build
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Useful Commands

```bash
# View package info
npm info @your-org/package-name

# View versions
npm view @your-org/package-name versions

# Deprecate version
npm deprecate @your-org/package-name@1.0.0 "Use 2.0.0 instead"

# Unpublish (within 72 hours)
npm unpublish @your-org/package-name@1.0.0
```
