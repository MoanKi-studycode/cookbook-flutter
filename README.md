# CookBook — `nhom2_flutter_app`

Ứng dụng Flutter quản lý công thức nấu ăn, dùng Supabase cho Auth và dữ liệu.

## About

- Nền tảng: Flutter + GetX
- Backend: Supabase (Auth + PostgreSQL)
- Chức năng chính: đăng nhập/đăng ký OTP, tìm kiếm món, lọc danh mục, yêu thích món ăn

## Chức năng đã xây dựng (theo thành viên)

### Trần Anh Tín

- [x] Cấu trúc project Flutter + điều hướng chính
- [x] Cấu hình Supabase và kết nối app
- [x] Auth: đăng nhập / đăng ký / OTP / quản lý session
- [x] Thiết kế database, model/helper/controller chính
- [x] Tài liệu database (`DATABASE_DIAGRAM.md`, `supabase_schema.sql`)

### Nguyễn Thành Thục

- [x] Giao diện danh mục món ăn
- [x] Giao diện danh sách món ăn
- [x] Giao diện chi tiết công thức
- [x] Hỗ trợ chuyển UI từ Figma sang Flutter
- [x] Tối ưu giao diện cơ bản cho mobile
- [ ] Hoàn thiện toàn bộ UI nâng cao theo bản Figma cuối cùng

### Trần Quốc Tiên

- [x] Tìm kiếm món ăn theo tên
- [x] Lọc món ăn theo danh mục
- [x] Lưu / bỏ lưu món yêu thích
- [x] Màn hình danh sách món yêu thích
- [x] Xử lý dữ liệu Supabase cho search/filter/favorite
- [ ] Bộ kiểm thử tự động cho search/filter/favorite (hiện chủ yếu test tay)

## Cấu hình nhanh

1. Chạy file `supabase_schema.sql` trên Supabase SQL Editor.
2. Trong `lib/main.dart`, cập nhật `supabaseUrl` và `supabaseAnonKey`.
3. Ở Supabase Auth:
   - Bật Email provider
   - Nếu dùng OTP signup, template confirm dùng `{{ .Token }}`

## Chạy project

```bash
flutter pub get
flutter run
```

## Cấu trúc chính

```text
lib/
├── main.dart
├── page/
├── model/
├── controller/
├── helper/
└── widget/
```

## Hướng dẫn dùng GitLab

- Không push các thư mục/file build local: `build/`, `.dart_tool/`, `android/local.properties`, `android/.gradle/`.
- Tránh để lộ key Supabase khi repo public.
- Làm việc theo nhánh feature, merge về `main` qua MR.
- Mỗi khi đổi schema, cập nhật luôn `supabase_schema.sql`.

## Tài liệu

- `DATABASE_DIAGRAM.md`: mô tả database
- `supabase_schema.sql`: script tạo bảng + policy
