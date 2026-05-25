# CookBook — `nhom2_flutter_app`

Ứng dụng Flutter học tập: sổ tay công thức nấu ăn. Backend **Supabase** (Auth + PostgreSQL), state **GetX**, UI đơn giản theo phong cách project thực hành.

---

## Yêu cầu

| Công cụ | Phiên bản gợi ý |
|---------|------------------|
| Flutter SDK | 3.12+ (`sdk: ^3.12.0` trong `pubspec.yaml`) |
| Android Studio / VS Code | Có plugin Flutter |
| Supabase | Project riêng của nhóm |

---

## Cấu hình Supabase (bắt buộc trước khi chạy app)

### Bước 1 — Database

1. Mở [Supabase Dashboard](https://supabase.com/dashboard) → project nhóm → **SQL Editor**.
2. Dán và chạy **toàn bộ** file [`supabase_schema.sql`](supabase_schema.sql).
3. Kiểm tra 4 bảng `public`: `"Category"`, `"Recipe"`, `"Favorite"`, `"User"`.

Script gồm: tạo bảng, index, RLS, grant, dữ liệu mẫu (3 danh mục, 3 món). Chạy lại script **không** nhân đôi dữ liệu mẫu (dùng `ON CONFLICT`).

### Bước 2 — Auth (Dashboard)

| Mục | Cấu hình |
|-----|----------|
| **Authentication → Providers** | Bật **Email** |
| **Confirm signup** | Bật nếu nhóm dùng OTP email; template dùng `{{ .Token }}` (mã 6 số) |
| **Tắt confirm email** | Có thể đăng nhập ngay sau đăng ký (app hỗ trợ cả hai luồng) |

### Bước 3 — Flutter

Trong [`lib/main.dart`](lib/main.dart), đặt `supabaseUrl` và `supabaseAnonKey` của project (Settings → API).

```bash
flutter pub get
flutter run
```

---

## Chức năng đã xây dựng

### Xác thực & profile (Trần Anh Tín / core)

| Chức năng | Màn hình / file | Ghi chú |
|-----------|-----------------|--------|
| Splash ngắn | `page_splash.dart` | ~0.8s rồi vào auth gate |
| Welcome | `page_welcome.dart` | Đăng nhập / Đăng ký |
| Đăng nhập email + mật khẩu | `page_login.dart`, `auth_helper.dart` | Sau login đồng bộ `"User"` |
| Đăng ký + họ tên | `page_register.dart` | Metadata `hoTen`, `full_name` |
| Xác thực OTP 6 số | `page_verify_otp.dart` | `verifyOTP`, gửi lại OTP |
| Đăng xuất | `page_profile.dart` | `signOutAuth` + dialog xác nhận |
| Profile `hoTen` | `User` + `UserSnapshot` | Upsert bảng `"User"`, hiển thị Home / Profile |
| Auth gate | `main.dart` `PageAuthGate` | `StreamBuilder` session → Main hoặc Welcome |

### Dữ liệu & nghiệp vụ

| Chức năng | Màn hình | API / controller |
|-----------|----------|------------------|
| Trang chủ — chào tên, menu, danh mục, món phổ biến | `page_home.dart` | `RecipeController`, `CategoryController` |
| Danh mục (list) | `page_category.dart` | `CategorySnapshot` |
| Danh sách món theo danh mục / tất cả | `page_recipe_list.dart` | Lọc client + ô tìm trong list |
| Chi tiết món (ảnh, mô tả, NL, cách làm) | `page_recipe_detail.dart` | `RecipeSnapshot.getRecipeById` |
| Tìm kiếm theo tên | `page_search.dart` | `RecipeSnapshot.timKiem` (ilike) |
| Yêu thích — thêm/xóa, danh sách | `page_favorite.dart`, icon tim | `FavoriteSnapshot.toggleFavorite` |
| Bottom nav 4 tab | `page_main.dart` | Trang chủ / Tìm / Yêu thích / Cá nhân |

### Kỹ thuật

- **GetX:** `RecipeController`, `CategoryController`, `FavoriteController` (`Get.put` trong `PageMain`).
- **Supabase:** model + `*Snapshot`, helper `getMapData` / `getListData` trong `supabase_helper.dart`.
- **Điều hướng:** `Navigator.push` + `MaterialPageRoute` (không go_router).

Chi tiết bảng, RLS, FK: xem [`DATABASE_DIAGRAM.md`](DATABASE_DIAGRAM.md).

---

## Chức năng chưa làm / còn thiếu

| Hạng mục | Trạng thái |
|----------|------------|
| Sửa thông tin cá nhân (đổi `hoTen` trên app) | Chưa có màn — chỉ set lúc đăng ký / đồng bộ auth |
| Menu Cá nhân: Thông tin tài khoản, Thông báo, Trợ giúp | UI `ListTile` chưa gắn logic |
| Thêm/sửa/xóa **Recipe**, **Category** từ app | Chỉ đọc DB + seed SQL; không CRUD admin |
| Realtime stream món | Đã gỡ `getRecipeStream` — load một lần qua `getMapRecipe` |
| Độ khó món (`difficulty`) | Dùng `danhGia` (số) thay enum |
| `created_at` trên bảng | Chưa có trong schema |
| Ảnh upload (Storage) | Chỉ URL `hinhAnh` text |
| Đa ngôn ngữ / theme tối | Chưa có |
| Unit/widget test thật | Chỉ placeholder trong `test/widget_test.dart` |
| CI/CD GitLab build APK tự động | Chưa cấu hình (có thể thêm sau) |

Phần UI placeholder theo phân công nhóm (nếu còn) nên bổ sung trên nhánh feature riêng, tránh conflict file core auth/data.

---

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Supabase init, splash, auth gate
├── page/                     # Các màn UI
├── model/                    # User, Category, Recipe, Favorite + Snapshot
├── controller/               # GetX
├── helper/                   # auth_helper, supabase_helper, dialogs
└── widget/                   # widget_recipe_card.dart
supabase_schema.sql           # DDL + RLS + seed
DATABASE_DIAGRAM.md           # ERD, ánh xạ Dart
```

---

## Lưu ý khi dùng GitLab

### Trước khi push lần đầu

1. **Không commit** thư mục build: `build/`, `.dart_tool/`, `android/.gradle/`, `android/local.properties` — đã liệt kê trong [`.gitignore`](.gitignore).
2. **Khóa Supabase (anon key):** Nếu repo **public** hoặc nhiều người ngoài nhóm có quyền đọc:
   - Không để anon key thật trên GitLab lâu dài; rotate key trên Supabase nếu đã lộ.
   - Cách an toàn hơn: dùng `--dart-define=SUPABASE_URL=...` / `--dart-define=SUPABASE_ANON_KEY=...` hoặc file local không commit (`.env` + `.gitignore`). Hiện project đang hardcode trong `main.dart` — **đổi key trước khi public** hoặc chuyển sang biến môi trường.
3. Chạy `flutter pub get` sau khi clone; không commit `pubspec.lock` nếu nhóm quy ước (Flutter thường **nên** commit `pubspec.lock` — giữ file này để build đồng nhất).
4. Xóa cache local nếu cần: `flutter clean` (không push thư mục `build/`).

### Quy trình làm việc nhóm

| Việc nên làm | Gợi ý |
|--------------|--------|
| Nhánh | `main` ổn định; feature: `feature/ten-thanh-vien-mo-ta` |
| Commit message | Tiếng Việt hoặc Anh ngắn gọn: `feat: them man tim kiem`, `fix: dong bo hoTen` |
| Merge Request | 1 MR = 1 chức năng; mô tả: đã test gì, cần chạy SQL không |
| Conflict | Ưu tiên giữ `lib/helper/auth_helper.dart`, `lib/model/`, `main.dart` — trao đổi trước khi sửa |
| SQL thay đổi | Commit kèm cập nhật `supabase_schema.sql` + ghi chú trong MR cho cả nhóm chạy lại trên Supabase |

### File nên có trên GitLab

| File | Mục đích |
|------|----------|
| `README.md` | Hướng dẫn này |
| `DATABASE_DIAGRAM.md` | Tài liệu DB |
| `supabase_schema.sql` | Schema chuẩn cho mọi thành viên |
| `.gitignore` | Loại build / IDE |
| `pubspec.yaml` + `pubspec.lock` | Dependency |

### Không nên push

- APK/IPA trong repo (`*.apk` — có thể thêm vào `.gitignore` nếu cần).
- Screenshot cá nhân / file zip build.
- Mật khẩu service role Supabase (chỉ dùng server-side, **không** đưa vào Flutter).

### Clone project mới

```bash
git clone <url-gitlab-nhom>
cd nhom2_flutter_app
flutter pub get
# Sua supabaseUrl / supabaseAnonKey trong lib/main.dart
# Chay supabase_schema.sql tren Supabase neu DB trong
flutter run
```

### Issue / Wiki GitLab (tùy nhóm)

- Ghi link Supabase project (private) trong Wiki, **không** paste service_role key.
- Checklist đồ án: [ ] SQL đã chạy [ ] Auth OTP [ ] Đăng nhập được [ ] Yêu thích hoạt động.

---

## Tài liệu liên quan

- [`DATABASE_DIAGRAM.md`](DATABASE_DIAGRAM.md) — ERD, RLS, mapping model Dart
- [`supabase_schema.sql`](supabase_schema.sql) — Script tạo DB đầy đủ

---

## Thành viên & phạm vi (tham khảo)

| Phạm vi | Nội dung |
|--------|----------|
| Core (đã có) | Auth, OTP, đồng bộ `"User"`, model/Snapshot, controllers, điều hướng chính, CRUD yêu thích, đọc món/danh mục |
| Mở rộng (nhánh riêng) | UI nâng cao, CRUD admin món, sửa profile, test, CI GitLab |

---

*CookBook — NTU / nhóm 2 Flutter. Cập nhật README theo codebase hiện tại.*
