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

## Cách chạy project

```bash
flutter pub get
flutter run
```

## Cấu hình Supabase

Trong `lib/main.dart`, cập nhật `supabaseUrl` và `supabaseAnonKey` theo project Supabase của nhóm.

Database và Auth đã được cấu hình sẵn trên Supabase (bảng `Category`, `Recipe`, `Favorite`).

## Thành viên

| Thành viên        | Đóng góp |
| ----------------- | -------- |
| Trần Anh Tín      | 40%      |
| Nguyễn Thành Thục | 30%      |
| Trần Quốc Tiên    | 30%      |
