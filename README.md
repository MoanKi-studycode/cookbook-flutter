# CookBook

Ứng dụng Flutter tra cứu công thức nấu ăn, sử dụng Supabase để xác thực người dùng và lưu trữ dữ liệu.

![CookBook icon](assets/icon/app_icon.png)

## Công nghệ sử dụng

* Flutter
* Dart
* Supabase Auth
* Supabase Database
* GetX
* Figma

## Chức năng chính

* Đăng ký tài khoản
* Đăng nhập
* Xác thực OTP Email
* Xem danh mục món ăn
* Xem danh sách công thức
* Xem chi tiết công thức (ảnh, nguyên liệu, cách làm, thời gian, độ khó)
* Tìm kiếm món ăn
* Lưu món ăn yêu thích
* Xem và cập nhật thông tin cá nhân
* Đăng xuất

## Database

Các bảng chính:

* Category
* Recipe
* Favorite
* User (profile `hoTen` đồng bộ từ Auth)

Thông tin đăng nhập được quản lý bằng Supabase Auth.

Cột `doKho` trên Recipe: `1` = Dễ, `2` = Trung bình, `3` = Khó.

## Cấu trúc thư mục

```txt
lib/
├── main.dart
├── model/
├── helper/
├── controller/
└── page/
```

## Cách chạy project

```bash
flutter pub get
flutter run
```

## Cấu hình Supabase

Trong `lib/main.dart`, cập nhật:

```dart
supabaseUrl
supabaseAnonKey
```

Sau đó chạy file:

```txt
supabase_schema.sql
```

trong Supabase SQL Editor.

## Thành viên

| Thành viên        | Đóng góp |
| ----------------- | -------- |
| Trần Anh Tín      | 40%      |
| Nguyễn Thành Thục | 30%      |
| Trần Quốc Tiên    | 30%      |

## Tài liệu thêm

* `supabase_schema.sql` — script tạo bảng, RLS, dữ liệu mẫu
* `DATABASE_DIAGRAM.md` — sơ đồ và mô tả database
