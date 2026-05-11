# TODO - Arreglar Posts (Supabase vs MOCK)

- [ ] 1) Eliminar fallback de `PostModel.mockPosts()` en `PostsScreen` y mostrar solo error.
- [ ] 2) Ajustar `PostModel.fromSupabase()` para el schema real (`posts.user_id`, `username`, `likes integer`, etc.).
- [ ] 3) Ajustar `SupabaseService.createPost()` y `toggleLike()` para usar el schema real (`likes integer`, campos reales).
- [ ] 4) Ajustar UI en `PostsScreen/_PostCard` si usa `likes` como lista (p.ej. `post.likes.contains`).
- [ ] 5) Ejecutar `flutter run` y verificar que la pantalla de Posts muestre datos reales o el error real.

