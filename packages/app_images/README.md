# app_images

Package to centralize app images for reuse across the monorepo.

Usage:

1. Add a dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  app_images:
    path: ../packages/app_images
```

2. Use images in Flutter widgets:

```dart
Image.asset(AppImages.logo)
```

Note: Place image files under `assets/images/`.
