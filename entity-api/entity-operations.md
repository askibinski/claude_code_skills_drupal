# Drupal Entity Operations Skill

This skill covers day-to-day patterns for working with entities: loading, querying, creating, updating, deleting, and rendering.

## Loading Entities

### Load Single Entity

```php
// Via entity type manager (recommended for services)
$storage = \Drupal::entityTypeManager()->getStorage('node');
$node = $storage->load(123);

// Static method on entity class
$node = \Drupal\node\Entity\Node::load(123);

// Via service injection (in classes)
public function __construct(
  private readonly EntityTypeManagerInterface $entityTypeManager,
) {}

public function loadNode(int $id): ?NodeInterface {
  return $this->entityTypeManager->getStorage('node')->load($id);
}
```

### Load Multiple Entities

```php
$storage = \Drupal::entityTypeManager()->getStorage('node');

// Load by IDs
$nodes = $storage->loadMultiple([1, 2, 3]);

// Load by properties
$nodes = $storage->loadByProperties([
  'type' => 'article',
  'status' => 1,
]);

// Load all (use with caution)
$nodes = $storage->loadMultiple();
```

### Load Unchanged (Bypass Cache)

```php
// Load from database, bypassing static cache
$node = $storage->loadUnchanged(123);
```

### Load Specific Revision

```php
$node = $storage->loadRevision($revision_id);
```

---

## Entity Queries

### Basic Query

```php
$ids = \Drupal::entityQuery('node')
  ->condition('type', 'article')
  ->condition('status', 1)
  ->accessCheck(TRUE)  // Required - explicitly state access checking
  ->execute();

$nodes = \Drupal::entityTypeManager()
  ->getStorage('node')
  ->loadMultiple($ids);
```

### Query Conditions

```php
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE);

// Equality
$query->condition('type', 'article');

// Not equal
$query->condition('type', 'page', '<>');

// In array
$query->condition('type', ['article', 'page'], 'IN');

// Not in array
$query->condition('type', ['article'], 'NOT IN');

// Range
$query->condition('created', strtotime('-7 days'), '>=');

// NULL check
$query->notExists('field_image');
$query->exists('field_image');

// LIKE (use with caution - not indexed)
$query->condition('title', '%drupal%', 'LIKE');

// STARTS_WITH / ENDS_WITH / CONTAINS
$query->condition('title', 'Drupal', 'STARTS_WITH');
```

### Sorting

```php
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE)
  ->sort('created', 'DESC')
  ->sort('title', 'ASC');  // Secondary sort
```

### Paging

```php
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE)
  ->range(0, 10);  // Offset, limit

// For pager integration
$query->pager(10);  // 10 items per page
```

### Condition Groups (OR/AND)

```php
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE);

// OR condition group
$or_group = $query->orConditionGroup()
  ->condition('type', 'article')
  ->condition('type', 'page');

$query->condition($or_group);

// AND within OR
$and_group = $query->andConditionGroup()
  ->condition('status', 1)
  ->condition('promote', 1);

$or_group = $query->orConditionGroup()
  ->condition($and_group)
  ->condition('sticky', 1);

$query->condition($or_group);
```

### Count Query

```php
$count = \Drupal::entityQuery('node')
  ->condition('type', 'article')
  ->accessCheck(TRUE)
  ->count()
  ->execute();
```

### Aggregate Queries

```php
$result = \Drupal::entityQueryAggregate('node')
  ->accessCheck(TRUE)
  ->groupBy('type')
  ->aggregate('nid', 'COUNT')
  ->execute();

// Returns: [['type' => 'article', 'nid_count' => 42], ...]
```

### Revision Queries

```php
// Query all revisions
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE)
  ->allRevisions()
  ->condition('nid', 123);

// Latest revision only
$query = \Drupal::entityQuery('node')
  ->accessCheck(TRUE)
  ->latestRevision()
  ->condition('nid', 123);
```

---

## Creating Entities

### Create and Save

```php
$storage = \Drupal::entityTypeManager()->getStorage('node');

$node = $storage->create([
  'type' => 'article',
  'title' => 'My Article',
  'body' => [
    'value' => '<p>Body content</p>',
    'format' => 'full_html',
  ],
  'field_tags' => [1, 2, 3],  // Term IDs
  'uid' => \Drupal::currentUser()->id(),
]);

$node->save();

// Get the new ID
$nid = $node->id();
```

### Create with Entity Reference

```php
$node = $storage->create([
  'type' => 'article',
  'title' => 'Article with Author',
  'field_author' => ['target_id' => 5],  // User ID
  // Or multiple values:
  'field_related' => [
    ['target_id' => 10],
    ['target_id' => 20],
  ],
]);
```

### Validate Before Save

```php
$node = $storage->create([
  'type' => 'article',
  'title' => '',  // Invalid - required field
]);

$violations = $node->validate();

if ($violations->count() > 0) {
  foreach ($violations as $violation) {
    \Drupal::logger('my_module')->error(
      'Validation error on @field: @message',
      [
        '@field' => $violation->getPropertyPath(),
        '@message' => $violation->getMessage(),
      ]
    );
  }
}
else {
  $node->save();
}
```

---

## Updating Entities

### Load, Modify, Save Pattern

```php
$node = \Drupal\node\Entity\Node::load(123);

if ($node) {
  $node->set('title', 'Updated Title');
  $node->set('field_tags', [4, 5, 6]);
  $node->save();
}
```

### Set Multiple Values

```php
$node->set('field_images', [
  ['target_id' => 10, 'alt' => 'Image 1'],
  ['target_id' => 20, 'alt' => 'Image 2'],
]);
```

### Append to Multi-Value Field

```php
$current_values = $node->get('field_tags')->getValue();
$current_values[] = ['target_id' => 99];
$node->set('field_tags', $current_values);
$node->save();
```

### Creating New Revision on Update

```php
$node = \Drupal\node\Entity\Node::load(123);
$node->setNewRevision(TRUE);
$node->setRevisionLogMessage('Updated via API');
$node->setRevisionCreationTime(\Drupal::time()->getRequestTime());
$node->setRevisionUserId(\Drupal::currentUser()->id());
$node->set('title', 'Updated Title');
$node->save();
```

### Update Without Loading (Be Careful)

```php
// Only for specific use cases - bypasses hooks
\Drupal::database()->update('node_field_data')
  ->fields(['title' => 'New Title'])
  ->condition('nid', 123)
  ->execute();

// Clear cache after direct DB update
\Drupal::entityTypeManager()->getStorage('node')->resetCache([123]);
```

---

## Deleting Entities

### Delete Single Entity

```php
$node = \Drupal\node\Entity\Node::load(123);
if ($node) {
  $node->delete();
}
```

### Delete Multiple Entities

```php
$storage = \Drupal::entityTypeManager()->getStorage('node');
$nodes = $storage->loadMultiple([1, 2, 3]);
$storage->delete($nodes);
```

### Delete by Query

```php
$ids = \Drupal::entityQuery('node')
  ->condition('type', 'article')
  ->condition('created', strtotime('-1 year'), '<')
  ->accessCheck(FALSE)  // Admin operation
  ->execute();

if ($ids) {
  $storage = \Drupal::entityTypeManager()->getStorage('node');
  $nodes = $storage->loadMultiple($ids);
  $storage->delete($nodes);
}
```

### Delete Specific Revision

```php
$storage = \Drupal::entityTypeManager()->getStorage('node');
$storage->deleteRevision($revision_id);
```

---

## Rendering Entities

### Render Single Entity

```php
$view_builder = \Drupal::entityTypeManager()->getViewBuilder('node');
$node = \Drupal\node\Entity\Node::load(123);

// Default view mode
$build = $view_builder->view($node);

// Specific view mode
$build = $view_builder->view($node, 'teaser');

// With language
$build = $view_builder->view($node, 'full', 'es');
```

### Render Multiple Entities

```php
$view_builder = \Drupal::entityTypeManager()->getViewBuilder('node');
$nodes = \Drupal\node\Entity\Node::loadMultiple([1, 2, 3]);

$build = $view_builder->viewMultiple($nodes, 'teaser');
```

### Get Rendered HTML String

```php
$build = $view_builder->view($node, 'teaser');
$html = \Drupal::service('renderer')->renderRoot($build);
```

### Render Entity Field

```php
$view_builder = \Drupal::entityTypeManager()->getViewBuilder('node');

// Single field
$build = $view_builder->viewField($node->get('body'), 'full');

// With display options
$build = $view_builder->viewField($node->get('body'), [
  'label' => 'hidden',
  'type' => 'text_default',
]);
```

---

## Access Checking

### Check Entity Access

```php
$node = \Drupal\node\Entity\Node::load(123);

// Current user
if ($node->access('view')) {
  // User can view
}

if ($node->access('update')) {
  // User can edit
}

if ($node->access('delete')) {
  // User can delete
}

// Specific user
$account = \Drupal\user\Entity\User::load(5);
if ($node->access('view', $account)) {
  // User 5 can view
}
```

### Check Field Access

```php
if ($node->get('field_private')->access('view')) {
  // User can view this field
}
```

### Check Create Access

```php
$access_handler = \Drupal::entityTypeManager()
  ->getAccessControlHandler('node');

$can_create = $access_handler->createAccess('article');

// For specific user
$can_create = $access_handler->createAccess('article', $account);
```

### Access Check in Queries

```php
// With access check (default for content)
$ids = \Drupal::entityQuery('node')
  ->accessCheck(TRUE)
  ->execute();

// Without access check (admin operations)
$ids = \Drupal::entityQuery('node')
  ->accessCheck(FALSE)
  ->execute();
```

---

## Important Considerations

1. **Always specify accessCheck()** - Entity queries require explicit `accessCheck(TRUE)` or `accessCheck(FALSE)`. Omitting it triggers a deprecation warning.

2. **Use dependency injection** - In services and controllers, inject `EntityTypeManagerInterface` rather than using static `\Drupal::` calls.

3. **Entity cache** - Drupal caches loaded entities. Use `loadUnchanged()` when you need fresh data.

4. **Batch operations** - For bulk operations on many entities, use the Batch API to avoid memory/timeout issues.

5. **Entity hooks** - CRUD operations trigger hooks (`hook_entity_presave`, `hook_entity_insert`, etc.). Direct database queries bypass these.

6. **Revision handling** - When updating revisionable entities, explicitly call `setNewRevision(TRUE)` if you want a new revision.

## Related Skills

- **Entity Architecture** - Decisions on entity types, bundles, revisions
- **Content Entity Creation** - Scaffold custom content entities
