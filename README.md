# Drupal Skills for Claude Code

Claude Code skills for Drupal development. These skills provide structured guidance for common Drupal development patterns, following official Drupal coding standards and best practices.

## Installation

### Option 1: Project Skills (Recommended for Teams)

Copy the skill files to your Drupal project's `.claude/skills/` directory:

```bash
# From your Drupal project root
mkdir -p .claude/skills
cp -r /path/to/claude_code_skills_drupal/entity-api .claude/skills/
```

Skills in `.claude/skills/` are version-controlled and automatically available to all team members.

### Option 2: Global Skills (Personal Use)

Copy to your home directory for use across all projects:

```bash
mkdir -p ~/.claude/skills
cp -r /path/to/claude_code_skills_drupal/entity-api ~/.claude/skills/
```

### Optional: Hooks and Commands

To also use the forced-eval hook and slash commands, copy the `.claude/` configuration:

```bash
# Copy hooks and commands (merge with existing .claude/ if present)
cp -r /path/to/claude_code_skills_drupal/.claude/hooks your-project/.claude/
cp -r /path/to/claude_code_skills_drupal/.claude/commands your-project/.claude/
```

Add the hook to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "type": "command",
      "command": ".claude/hooks/skill-eval-hook.sh"
    }]
  }
}
```

## Available Skills

### Entity API

| Skill | Command | Description |
|-------|---------|-------------|
| [Entity Architecture](entity-api/entity-architecture.md) | `/drupal-entity-arch` | Architectural decisions: content vs config entities, bundles, revisions, translation |
| [Content Entity Creation](entity-api/content-entity-creation.md) | `/drupal-entity-create` | Scaffold custom content entities with handlers, forms, routing |
| [Entity Operations](entity-api/entity-operations.md) | `/drupal-entity-ops` | Loading, querying, CRUD operations, rendering entities |

## Usage

### Automatic Activation

The included hook evaluates available skills on each prompt. When you're working on Drupal entity-related tasks, relevant skills will be activated automatically.

### Manual Activation

Use slash commands to invoke skills directly:

```
/drupal-entity-create
```

Or reference the skill files directly in your prompts.

## Drupal Version

Skills target **Drupal 11** with notes for D10 compatibility where patterns differ.

## Reference

Based on official Drupal API documentation:
- [Entity API (D11)](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Entity%21entity.api.php/group/entity_api/11.x)

## Contributing

Contributions welcome. Please ensure:
- Code examples follow Drupal coding standards
- Examples are complete and copy-paste ready
- Cross-reference related skills where appropriate
