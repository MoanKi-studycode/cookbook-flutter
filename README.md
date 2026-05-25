# CookBook — nhom2_flutter_app

Ứng dụng Flutter (GetX + Supabase) — công thức nấu ăn, danh mục, món yêu thích, đăng nhập/OTP.

## Yêu cầu

- Flutter SDK 3.12+
- Tài khoản Supabase (project URL + anon key)

## Cấu hình Supabase

1. Chạy script `supabase_schema.sql` trong **SQL Editor** của Supabase.
2. Trong `lib/main.dart`, thay `supabaseUrl` và `supabaseAnonKey` bằng giá trị project nhóm.
3. Auth: bật email; Confirm sign up dùng template OTP `{{ .Token }}` (6 số) nếu cần xác thực email.

## Chạy app

```bash
flutter pub get
flutter run
```

## Cấu trúc chính

| Thư mục | Nội dung |
|---------|----------|
| `lib/page/` | Màn hình UI |
| `lib/model/` | Model + `*Snapshot` (Supabase) |
| `lib/controller/` | GetX controllers |
| `lib/helper/` | Auth, Supabase helper, dialog |
| `lib/widget/` | `WidgetRecipeCard` (ListTile món) |

## Tài liệu

- `DATABASE_DIAGRAM.md` — sơ đồ bảng, RLS, ánh xạ Dart
- `supabase_schema.sql` — DDL + seed + RLS

## Lưu ý Git

Không commit `build/`, `.dart_tool/`, `android/local.properties`, file `.iml`. Đã cấu hình trong `.gitignore`.
