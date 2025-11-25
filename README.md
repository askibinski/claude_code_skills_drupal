# Drupal Skills for Claude Code

Claude Code skills for Drupal development. These skills provide structured guidance for common Drupal development patterns, following official Drupal coding standards and best practices.

## Installation

Clone this repository and configure Claude Code to use these skills:

```bash
git clone https://github.com/YOUR_USERNAME/drupal-skills.git
cd drupal-skills
```

The `.claude/settings.json` includes a hook that automatically evaluates which skills are relevant for your current task.

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
