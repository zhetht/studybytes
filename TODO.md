# TODO

- [x] Run `flutter analyze` to capture current analyzer findings
- [ ] Fix analyzer findings in:
  - [ ] `lib/config/api_config.dart` (web-only import)
  - [ ] `lib/features/posts/screens/create_post_screen.dart` (prefer const)
  - [ ] `lib/features/posts/screens/posts_screen.dart` (dead code)
  - [ ] `lib/main.dart` (unused import)
- [ ] Re-run `flutter analyze` and confirm clean/only remaining warnings
