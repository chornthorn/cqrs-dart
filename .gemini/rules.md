# Agent Rules

- **No Backward Compatibility**: Never preserve deprecated APIs, legacy annotations, fallback aliases, or compatibility typedefs when refactoring or renaming symbols. Always delete the old symbols and make clean, direct changes.
- **Single Source of Truth**: Keep API surfaces minimal and modern without legacy compatibility shims.
