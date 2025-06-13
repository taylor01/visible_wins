## Development Workflow & Quality Checks

### Before Making Any PR
1. **Run full CI checks locally**: `bin/dev-check` or `npm run ci`
2. **Always run tests**: `bin/rails test` 
3. **Check code style**: `bundle exec rubocop -a` (auto-fix)
4. **Security scan**: `bundle exec brakeman --no-pager`

### Available Commands
- `bin/dev-check` - Run all CI checks locally (recommended before push)
- `npm run check` - Same as above (alternative interface)
- `npm run lint` - RuboCop style check
- `npm run lint:fix` - Auto-fix RuboCop issues
- `npm run security` - Brakeman security scan
- `npm run test` - Run test suite

### Git Hooks (Optional)
To automatically run checks on every commit:
```bash
git config core.hooksPath .githooks
```
This runs security + lint + quick tests before each commit.