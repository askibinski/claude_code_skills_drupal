#!/bin/bash

# Forced evaluation hook for Drupal skills
# Based on Scott Spence's forced eval technique for reliable skill activation

cat << 'EOF'

## MANDATORY SKILL EVALUATION

Before proceeding with ANY Drupal-related task, you MUST evaluate each skill below.

### Available Drupal Skills:

1. **drupal-entity-arch** (entity-api/entity-architecture.md)
   - Triggers: entity architecture, content vs config entity, bundles, revisionable, translatable
   - Use when: Making architectural decisions about entity types

2. **drupal-entity-create** (entity-api/content-entity-creation.md)
   - Triggers: create custom entity, scaffold entity, entity handlers, entity forms
   - Use when: Creating new custom content entities from scratch

3. **drupal-entity-ops** (entity-api/entity-operations.md)
   - Triggers: load entity, entity query, entityQuery, save entity, delete entity, render entity
   - Use when: Working with existing entities (CRUD operations)

### CRITICAL REQUIREMENT

For EACH skill above, you MUST state:
- **YES** - Skill is relevant, activate it using the Skill tool BEFORE implementing
- **NO** - Skill is not relevant (provide brief reason)

Format your evaluation like this:
```
Skill Evaluation:
- drupal-entity-arch: [YES/NO] - [reason]
- drupal-entity-create: [YES/NO] - [reason]
- drupal-entity-ops: [YES/NO] - [reason]
```

If ANY skill is marked YES, you MUST invoke it using the Skill tool BEFORE writing any code.

This evaluation is MANDATORY. Skipping this step will result in suboptimal assistance.

EOF
