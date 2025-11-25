# Drupal Content Entity Creation Skill

This skill provides complete patterns for scaffolding custom content entities in Drupal 11.

## Entity Class Structure

### Minimal Content Entity

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Entity;

use Drupal\Core\Entity\ContentEntityBase;
use Drupal\Core\Entity\EntityTypeInterface;
use Drupal\Core\Field\BaseFieldDefinition;
use Drupal\Core\Entity\Attribute\ContentEntityType;
use Drupal\my_module\MyEntityInterface;

#[ContentEntityType(
  id: "my_entity",
  label: new TranslatableMarkup("My Entity"),
  label_collection: new TranslatableMarkup("My Entities"),
  label_singular: new TranslatableMarkup("my entity"),
  label_plural: new TranslatableMarkup("my entities"),
  label_count: [
    "singular" => "@count my entity",
    "plural" => "@count my entities",
  ],
  handlers: [
    "list_builder" => "Drupal\my_module\MyEntityListBuilder",
    "form" => [
      "add" => "Drupal\my_module\Form\MyEntityForm",
      "edit" => "Drupal\my_module\Form\MyEntityForm",
      "delete" => "Drupal\Core\Entity\ContentEntityDeleteForm",
    ],
    "access" => "Drupal\my_module\MyEntityAccessControlHandler",
    "route_provider" => [
      "html" => "Drupal\Core\Entity\Routing\AdminHtmlRouteProvider",
    ],
  ],
  base_table: "my_entity",
  admin_permission: "administer my_entity",
  entity_keys: [
    "id" => "id",
    "uuid" => "uuid",
    "label" => "name",
  ],
  links: [
    "add-form" => "/admin/content/my-entity/add",
    "canonical" => "/admin/content/my-entity/{my_entity}",
    "edit-form" => "/admin/content/my-entity/{my_entity}/edit",
    "delete-form" => "/admin/content/my-entity/{my_entity}/delete",
    "collection" => "/admin/content/my-entity",
  ],
)]
class MyEntity extends ContentEntityBase implements MyEntityInterface {

  /**
   * {@inheritdoc}
   */
  public static function baseFieldDefinitions(EntityTypeInterface $entity_type): array {
    $fields = parent::baseFieldDefinitions($entity_type);

    $fields['name'] = BaseFieldDefinition::create('string')
      ->setLabel(new TranslatableMarkup('Name'))
      ->setRequired(TRUE)
      ->setSetting('max_length', 255)
      ->setDisplayOptions('form', [
        'type' => 'string_textfield',
        'weight' => 0,
      ])
      ->setDisplayOptions('view', [
        'label' => 'hidden',
        'type' => 'string',
        'weight' => 0,
      ])
      ->setDisplayConfigurable('form', TRUE)
      ->setDisplayConfigurable('view', TRUE);

    $fields['created'] = BaseFieldDefinition::create('created')
      ->setLabel(new TranslatableMarkup('Created'))
      ->setDescription(new TranslatableMarkup('The time when the entity was created.'));

    $fields['changed'] = BaseFieldDefinition::create('changed')
      ->setLabel(new TranslatableMarkup('Changed'))
      ->setDescription(new TranslatableMarkup('The time when the entity was last edited.'));

    return $fields;
  }

}
```

### Entity Interface

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module;

use Drupal\Core\Entity\ContentEntityInterface;

interface MyEntityInterface extends ContentEntityInterface {

}
```

## Revisionable Entity

Add revision support with tracking of revision metadata:

```php
#[ContentEntityType(
  id: "my_entity",
  label: new TranslatableMarkup("My Entity"),
  handlers: [
    // ... same handlers as above
    "storage" => "Drupal\Core\Entity\Sql\SqlContentEntityStorage",
  ],
  base_table: "my_entity",
  revision_table: "my_entity_revision",
  revisionable: TRUE,
  admin_permission: "administer my_entity",
  entity_keys: [
    "id" => "id",
    "uuid" => "uuid",
    "label" => "name",
    "revision" => "revision_id",
  ],
  revision_metadata_keys: [
    "revision_user" => "revision_user",
    "revision_created" => "revision_created",
    "revision_log_message" => "revision_log",
  ],
  links: [
    // ... same links as above
    "version-history" => "/admin/content/my-entity/{my_entity}/revisions",
    "revision" => "/admin/content/my-entity/{my_entity}/revisions/{my_entity_revision}/view",
  ],
)]
class MyEntity extends ContentEntityBase implements MyEntityInterface, RevisionableInterface {

  use RevisionableContentEntityTrait;

  public static function baseFieldDefinitions(EntityTypeInterface $entity_type): array {
    $fields = parent::baseFieldDefinitions($entity_type);

    // Add revision metadata fields
    $fields += static::revisionLogBaseFieldDefinitions($entity_type);

    // ... other fields

    return $fields;
  }

}
```

## Translatable Entity

```php
#[ContentEntityType(
  id: "my_entity",
  label: new TranslatableMarkup("My Entity"),
  handlers: [
    // ... handlers
    "translation" => "Drupal\content_translation\ContentTranslationHandler",
  ],
  base_table: "my_entity",
  data_table: "my_entity_field_data",
  translatable: TRUE,
  entity_keys: [
    "id" => "id",
    "uuid" => "uuid",
    "label" => "name",
    "langcode" => "langcode",
  ],
  links: [
    // ... standard links
    "drupal:content-translation-overview" => "/admin/content/my-entity/{my_entity}/translations",
  ],
)]
class MyEntity extends ContentEntityBase implements MyEntityInterface, TranslatableInterface {

  public static function baseFieldDefinitions(EntityTypeInterface $entity_type): array {
    $fields = parent::baseFieldDefinitions($entity_type);

    $fields['name'] = BaseFieldDefinition::create('string')
      ->setLabel(new TranslatableMarkup('Name'))
      ->setTranslatable(TRUE)  // Mark field as translatable
      ->setRequired(TRUE)
      // ... other settings

    return $fields;
  }

}
```

## Editorial Entity (Revisionable + Translatable + Publishing)

For full editorial workflow support using `EditorialContentEntityBase`:

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Entity;

use Drupal\Core\Entity\EditorialContentEntityBase;
use Drupal\Core\Entity\EntityTypeInterface;
use Drupal\Core\Field\BaseFieldDefinition;
use Drupal\Core\Entity\Attribute\ContentEntityType;
use Drupal\my_module\MyEntityInterface;

#[ContentEntityType(
  id: "my_entity",
  label: new TranslatableMarkup("My Entity"),
  label_collection: new TranslatableMarkup("My Entities"),
  handlers: [
    "list_builder" => "Drupal\my_module\MyEntityListBuilder",
    "form" => [
      "add" => "Drupal\my_module\Form\MyEntityForm",
      "edit" => "Drupal\my_module\Form\MyEntityForm",
      "delete" => "Drupal\Core\Entity\ContentEntityDeleteForm",
    ],
    "access" => "Drupal\my_module\MyEntityAccessControlHandler",
    "storage" => "Drupal\Core\Entity\Sql\SqlContentEntityStorage",
    "translation" => "Drupal\content_translation\ContentTranslationHandler",
    "route_provider" => [
      "html" => "Drupal\Core\Entity\Routing\AdminHtmlRouteProvider",
    ],
  ],
  base_table: "my_entity",
  data_table: "my_entity_field_data",
  revision_table: "my_entity_revision",
  revision_data_table: "my_entity_field_revision",
  translatable: TRUE,
  revisionable: TRUE,
  show_revision_ui: TRUE,
  admin_permission: "administer my_entity",
  entity_keys: [
    "id" => "id",
    "uuid" => "uuid",
    "label" => "name",
    "langcode" => "langcode",
    "revision" => "revision_id",
    "published" => "status",
  ],
  revision_metadata_keys: [
    "revision_user" => "revision_user",
    "revision_created" => "revision_created",
    "revision_log_message" => "revision_log",
  ],
  links: [
    "add-form" => "/admin/content/my-entity/add",
    "canonical" => "/admin/content/my-entity/{my_entity}",
    "edit-form" => "/admin/content/my-entity/{my_entity}/edit",
    "delete-form" => "/admin/content/my-entity/{my_entity}/delete",
    "collection" => "/admin/content/my-entity",
    "version-history" => "/admin/content/my-entity/{my_entity}/revisions",
  ],
)]
class MyEntity extends EditorialContentEntityBase implements MyEntityInterface {

  public static function baseFieldDefinitions(EntityTypeInterface $entity_type): array {
    $fields = parent::baseFieldDefinitions($entity_type);

    $fields['name'] = BaseFieldDefinition::create('string')
      ->setLabel(new TranslatableMarkup('Name'))
      ->setTranslatable(TRUE)
      ->setRevisionable(TRUE)
      ->setRequired(TRUE)
      ->setSetting('max_length', 255)
      ->setDisplayOptions('form', [
        'type' => 'string_textfield',
        'weight' => 0,
      ])
      ->setDisplayOptions('view', [
        'label' => 'hidden',
        'type' => 'string',
        'weight' => 0,
      ])
      ->setDisplayConfigurable('form', TRUE)
      ->setDisplayConfigurable('view', TRUE);

    $fields['created'] = BaseFieldDefinition::create('created')
      ->setLabel(new TranslatableMarkup('Created'))
      ->setTranslatable(TRUE);

    $fields['changed'] = BaseFieldDefinition::create('changed')
      ->setLabel(new TranslatableMarkup('Changed'))
      ->setTranslatable(TRUE);

    return $fields;
  }

}
```

## Bundled Entity

For entities with subtypes (like nodes with content types):

### Bundle Config Entity

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Entity;

use Drupal\Core\Config\Entity\ConfigEntityBundleBase;
use Drupal\Core\Entity\Attribute\ConfigEntityType;
use Drupal\Core\StringTranslation\TranslatableMarkup;

#[ConfigEntityType(
  id: "my_entity_type",
  label: new TranslatableMarkup("My Entity Type"),
  label_collection: new TranslatableMarkup("My Entity Types"),
  label_singular: new TranslatableMarkup("my entity type"),
  label_plural: new TranslatableMarkup("my entity types"),
  handlers: [
    "list_builder" => "Drupal\my_module\MyEntityTypeListBuilder",
    "form" => [
      "add" => "Drupal\my_module\Form\MyEntityTypeForm",
      "edit" => "Drupal\my_module\Form\MyEntityTypeForm",
      "delete" => "Drupal\Core\Entity\EntityDeleteForm",
    ],
    "route_provider" => [
      "html" => "Drupal\Core\Entity\Routing\AdminHtmlRouteProvider",
    ],
  ],
  config_prefix: "my_entity_type",
  admin_permission: "administer my_entity_type",
  bundle_of: "my_entity",
  entity_keys: [
    "id" => "id",
    "label" => "label",
  ],
  config_export: [
    "id",
    "label",
    "description",
  ],
  links: [
    "add-form" => "/admin/structure/my-entity-types/add",
    "edit-form" => "/admin/structure/my-entity-types/{my_entity_type}/edit",
    "delete-form" => "/admin/structure/my-entity-types/{my_entity_type}/delete",
    "collection" => "/admin/structure/my-entity-types",
  ],
)]
class MyEntityType extends ConfigEntityBundleBase {

  protected string $id;
  protected string $label;
  protected string $description = '';

  public function getDescription(): string {
    return $this->description;
  }

}
```

### Content Entity with Bundle Reference

```php
#[ContentEntityType(
  id: "my_entity",
  label: new TranslatableMarkup("My Entity"),
  bundle_label: new TranslatableMarkup("My Entity Type"),
  bundle_entity_type: "my_entity_type",
  handlers: [
    // ... handlers
  ],
  base_table: "my_entity",
  entity_keys: [
    "id" => "id",
    "uuid" => "uuid",
    "bundle" => "type",
    "label" => "name",
  ],
  links: [
    "add-page" => "/admin/content/my-entity/add",
    "add-form" => "/admin/content/my-entity/add/{my_entity_type}",
    // ... other links
  ],
)]
class MyEntity extends ContentEntityBase implements MyEntityInterface {

  public static function baseFieldDefinitions(EntityTypeInterface $entity_type): array {
    $fields = parent::baseFieldDefinitions($entity_type);

    $fields['type'] = BaseFieldDefinition::create('entity_reference')
      ->setLabel(new TranslatableMarkup('Type'))
      ->setSetting('target_type', 'my_entity_type')
      ->setReadOnly(TRUE);

    // ... other fields

    return $fields;
  }

}
```

---

## Handler Classes

### List Builder

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module;

use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Entity\EntityListBuilder;

class MyEntityListBuilder extends EntityListBuilder {

  /**
   * {@inheritdoc}
   */
  public function buildHeader(): array {
    $header['id'] = $this->t('ID');
    $header['name'] = $this->t('Name');
    $header['created'] = $this->t('Created');
    return $header + parent::buildHeader();
  }

  /**
   * {@inheritdoc}
   */
  public function buildRow(EntityInterface $entity): array {
    /** @var \Drupal\my_module\MyEntityInterface $entity */
    $row['id'] = $entity->id();
    $row['name'] = $entity->toLink();
    $row['created'] = \Drupal::service('date.formatter')
      ->format($entity->get('created')->value, 'short');
    return $row + parent::buildRow($entity);
  }

}
```

### Entity Form

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Form;

use Drupal\Core\Entity\ContentEntityForm;
use Drupal\Core\Form\FormStateInterface;

class MyEntityForm extends ContentEntityForm {

  /**
   * {@inheritdoc}
   */
  public function save(array $form, FormStateInterface $form_state): int {
    $result = parent::save($form, $form_state);

    $message_args = ['%label' => $this->entity->toLink()->toString()];
    $message = match($result) {
      SAVED_NEW => $this->t('Created new my entity %label.', $message_args),
      SAVED_UPDATED => $this->t('Updated my entity %label.', $message_args),
      default => throw new \RuntimeException('Unexpected save result'),
    };
    $this->messenger()->addStatus($message);

    $form_state->setRedirectUrl($this->entity->toUrl('collection'));

    return $result;
  }

}
```

### Access Control Handler

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module;

use Drupal\Core\Access\AccessResult;
use Drupal\Core\Access\AccessResultInterface;
use Drupal\Core\Entity\EntityAccessControlHandler;
use Drupal\Core\Entity\EntityInterface;
use Drupal\Core\Session\AccountInterface;

class MyEntityAccessControlHandler extends EntityAccessControlHandler {

  /**
   * {@inheritdoc}
   */
  protected function checkAccess(EntityInterface $entity, $operation, AccountInterface $account): AccessResultInterface {
    return match($operation) {
      'view' => AccessResult::allowedIfHasPermission($account, 'view my_entity'),
      'update' => AccessResult::allowedIfHasPermission($account, 'edit my_entity'),
      'delete' => AccessResult::allowedIfHasPermission($account, 'delete my_entity'),
      default => AccessResult::neutral(),
    };
  }

  /**
   * {@inheritdoc}
   */
  protected function checkCreateAccess(AccountInterface $account, array $context, $entity_bundle = NULL): AccessResultInterface {
    return AccessResult::allowedIfHasPermission($account, 'create my_entity');
  }

}
```

### Views Data Handler

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module;

use Drupal\views\EntityViewsData;

class MyEntityViewsData extends EntityViewsData {

  /**
   * {@inheritdoc}
   */
  public function getViewsData(): array {
    $data = parent::getViewsData();

    // Customize views data here if needed
    $data['my_entity']['table']['group'] = $this->t('My Entity');

    return $data;
  }

}
```

Add to entity attribute:
```php
handlers: [
  // ...
  "views_data" => "Drupal\my_module\MyEntityViewsData",
],
```

---

## Supporting Files

### Permissions (my_module.permissions.yml)

```yaml
administer my_entity:
  title: 'Administer My Entity'
  description: 'Full administrative access to My Entity configuration and content.'
  restrict access: true

create my_entity:
  title: 'Create My Entity'

view my_entity:
  title: 'View My Entity'

edit my_entity:
  title: 'Edit My Entity'

delete my_entity:
  title: 'Delete My Entity'
```

### Menu Links (my_module.links.menu.yml)

```yaml
entity.my_entity.collection:
  title: 'My Entities'
  route_name: entity.my_entity.collection
  parent: system.admin_content
  weight: 10
```

### Local Tasks (my_module.links.task.yml)

```yaml
entity.my_entity.collection:
  title: 'My Entities'
  route_name: entity.my_entity.collection
  base_route: system.admin_content

entity.my_entity.edit_form:
  title: 'Edit'
  route_name: entity.my_entity.edit_form
  base_route: entity.my_entity.canonical

entity.my_entity.canonical:
  title: 'View'
  route_name: entity.my_entity.canonical
  base_route: entity.my_entity.canonical
```

### Action Links (my_module.links.action.yml)

```yaml
entity.my_entity.add_form:
  title: 'Add My Entity'
  route_name: entity.my_entity.add_form
  appears_on:
    - entity.my_entity.collection
```

---

## Important Considerations

1. **Entity keys must match base field names** - The `entity_keys` in the attribute must correspond exactly to base field machine names

2. **Route provider generates routes automatically** - Using `AdminHtmlRouteProvider` generates standard admin routes based on the `links` array

3. **Translatable fields need data_table** - When `translatable: TRUE`, you must define `data_table` for field storage

4. **Revisionable fields need revision_table** - When `revisionable: TRUE`, define both `revision_table` and optionally `revision_data_table`

5. **Base field display settings** - Use `setDisplayOptions()` and `setDisplayConfigurable()` for Field UI integration

6. **Namespace conventions** - Entity classes in `Entity/`, forms in `Form/`, handlers in module root namespace

## Related Skills

- **Entity Architecture** - Decisions on entity types, bundles, revisions
- **Entity Operations** - Loading, querying, CRUD patterns
