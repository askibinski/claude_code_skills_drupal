# Drupal Entity Architecture Skill

This skill helps make informed architectural decisions about Drupal entity types.

## Content Entities vs Configuration Entities

### Use Content Entities When:
- Data is created by users (editors, site visitors)
- Data needs to be fieldable (add fields via UI)
- Data requires revisions (version history, editorial workflow)
- Data needs translation (multilingual content)
- Data volume is potentially unlimited
- Data is stored in database tables

**Examples:** Nodes, users, comments, taxonomy terms, custom content types, orders, products

### Use Configuration Entities When:
- Data defines site structure/behavior (not content)
- Data is created by developers/admins
- Data should be exported to YAML for deployment
- Data should sync across environments
- Data volume is limited and predictable

**Examples:** Content types, views, image styles, menus, vocabularies, field configurations

### Decision Checklist

| Question | Content Entity | Config Entity |
|----------|---------------|---------------|
| Created by end users? | Yes | No |
| Needs UI-added fields? | Yes | Rarely |
| Needs revisions? | Often | No |
| Needs translation? | Often | Sometimes |
| Exported to code? | No | Yes |
| Deployed across environments? | No | Yes |

## Bundle Decisions

Bundles are subtypes of an entity type. Not all entities need bundles.

### Use Bundles When:
- Entity instances need different field configurations
- Different subtypes have different behaviors
- You need distinct form displays per subtype
- You want administrative separation of content types

**Examples with bundles:**
- Node → Content types (article, page, event)
- Taxonomy term → Vocabularies (tags, categories)
- Paragraph → Paragraph types

### Use Single-Bundle Entity When:
- All instances have the same fields
- Uniform behavior across all instances
- Simpler implementation is preferred

**Examples without bundles:**
- User (single bundle: user)
- File (single bundle: file)
- Simple custom entities

### Bundle Implementation

Bundles are typically implemented as config entities:

```
Entity Type          Bundle Config Entity
-----------          --------------------
node                 node_type
taxonomy_term        taxonomy_vocabulary
paragraph            paragraphs_type
media                media_type
```

When creating a bundled content entity, you also create a corresponding config entity for the bundle.

## Revisions

Revisions store historical versions of entity data.

### Enable Revisions When:
- Editorial workflows require content moderation
- Audit trail of changes is needed
- Users may need to revert to previous versions
- Content requires approval before publishing

### Revision Implementation Options:

**`ContentEntityBase`** - No revision support
```php
class MyEntity extends ContentEntityBase {}
```

**`ContentEntityBase` with `RevisionableInterface`** - Manual revision support
```php
class MyEntity extends ContentEntityBase implements RevisionableInterface {
  use RevisionableContentEntityTrait;
}
```

**`EditorialContentEntityBase`** - Full editorial support (revisions + publishing status)
```php
class MyEntity extends EditorialContentEntityBase {}
```

### Important Considerations:
- Revisions significantly increase database storage
- Enable only when the use case requires version history
- `EditorialContentEntityBase` includes Content Moderation integration

## Translation

Translation enables multilingual content.

### Enable Translation When:
- Site serves multiple languages
- Content needs language-specific versions
- Different markets require localized content

### Translation Implementation:

```php
#[ContentEntityType(
  id: "my_entity",
  translatable: TRUE,
  data_table: "my_entity_field_data",
  // ...
)]
```

### Important Considerations:
- Translation adds complexity to queries and data handling
- Consider translation needs early - retrofitting is complex
- Translatable entities require a `data_table` for field storage

## Combined: Revisionable + Translatable

For full multilingual editorial workflows:

```php
#[ContentEntityType(
  id: "my_entity",
  translatable: TRUE,
  revisionable: TRUE,
  data_table: "my_entity_field_data",
  revision_table: "my_entity_revision",
  revision_data_table: "my_entity_field_revision",
  // ...
)]
class MyEntity extends EditorialContentEntityBase implements TranslatableInterface {
  use TranslatableRevisionableStorageTrait;
}
```

This creates 4 database tables:
- `my_entity` - Base entity data
- `my_entity_field_data` - Translatable field values
- `my_entity_revision` - Revision base data
- `my_entity_field_revision` - Revision field values per language

## Configuration Entities

### Recommended Approach:
Create configuration entities via the Drupal UI, then export using:
```bash
drush config:export
```

### Why UI + Export?
- Drupal validates schema automatically
- UUIDs are generated correctly
- Dependencies are tracked properly
- Less error-prone than manual YAML
- Consistent with standard Drupal workflow

### When to Generate Config Entities in Code:
- Contrib module development (needs to work on any site)
- Programmatic configuration (migrations, installers)
- Complex automation requirements

## Related Skills

- **Content Entity Creation** - Scaffold custom content entities
- **Entity Operations** - Loading, querying, CRUD patterns
