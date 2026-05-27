# CookBook — `nhom2_flutter_app`

Ứng dụng Flutter quản lý công thức nấu ăn, dùng Supabase cho Auth và dữ liệu.

## About

- Nền tảng: Flutter + GetX
- Backend: Supabase (Auth + PostgreSQL)
- Chức năng chính: đăng nhập/đăng ký OTP, tìm kiếm món, lọc danh mục, yêu thích món ăn

## Chức năng đã xây dựng (theo thành viên)

| Thành viên | Tỷ lệ | Phần đã xây dựng |
|-----------|------|------------------|
| Trần Anh Tín | 40% | Cấu trúc project, cấu hình Supabase, Auth (login/register/OTP/session), model/helper/controller chính, điều hướng app, thiết kế database và tài liệu tổng hợp. |
| Nguyễn Thành Thục | 30% | Thiết kế và hoàn thiện UI các màn hình chính: danh mục, danh sách món, chi tiết công thức; hỗ trợ chuyển UI từ Figma sang Flutter và tối ưu hiển thị mobile. |
| Trần Quốc Tiên | 30% | Tìm kiếm món theo tên, lọc món theo danh mục, thêm/xóa món yêu thích, màn hình yêu thích, xử lý dữ liệu Supabase cho search/filter/favorite và kiểm thử các chức năng này. |

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
