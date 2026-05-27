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
| Trang chủ — chào tên, danh mục, món phổ biến | `page_home.dart` | `RecipeController`, `CategoryController` |
| Danh mục (list + lọc) | `page_category.dart` | `CategoryController`, điều hướng `PageRecipeList` |
| Danh sách món theo danh mục / tất cả | `page_recipe_list.dart` | Lọc `idCategory` + tìm trong list, `refreshData` |
| Chi tiết món (ảnh, mô tả, NL, cách làm, tim) | `page_recipe_detail.dart` | `RecipeSnapshot.getRecipeById`, `FavoriteController` |
| **Tìm kiếm theo tên (Supabase ilike)** | `page_search.dart` | `RecipeSnapshot.timKiem`, debounce, empty/error state |
| **Yêu thích — thêm/xóa, danh sách, refresh** | `page_favorite.dart`, `widget_recipe_card.dart` | `FavoriteSnapshot.toggleFavorite`, kiểm tra đăng nhập |
| Bottom nav 4 tab | `page_main.dart` | Trang chủ / Tìm / Yêu thích / Cá nhân |

### Trần Quốc Tiên — search / filter / favorite (đã merge `main`)

| Tiêu chí | Trạng thái |
|----------|------------|
| Ô tìm kiếm + gọi Supabase | Có — `PageSearch`, debounce 450ms |
| Hiển thị kết quả / không có kết quả | Có — empty state + nút thử lại khi lỗi |
| Lọc theo danh mục | Có — `PageRecipeList` + `RecipeController.locTheoCategory` |
| Thêm/xóa favorite + bảng `Favorite` | Có — `toggleFavorite`, return `-1` nếu chưa login |
| Màn yêu thích | Có — loading, refresh, pull-to-refresh, empty state |
| Card → chi tiết món | Có — `WidgetRecipeCard` + `Navigator.push` |

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
| Test tự động search/filter/favorite | Chưa có test script — chỉ test tay trên thiết bị |

Phần UI nâng cao (Figma) theo phân công **Nguyễn Thành Thục** có thể tiếp tục trên nhánh riêng, tránh conflict file core auth/data.

---

## Phân công công việc nhóm

| Thành viên | Mức độ đóng góp | Công việc |
|-----------|-----------------|-----------|
| Trần Anh Tín | 40% | Thiết kế cấu trúc project Flutter; cấu hình Supabase; xây dựng đăng nhập, đăng ký, xác thực OTP, quản lý session; thiết kế database; xây dựng model, helper, controller chính; điều hướng app; tổng hợp và hoàn thiện báo cáo. |
| Nguyễn Thành Thục | 30% | Thiết kế và xây dựng giao diện người dùng; xây dựng giao diện danh mục món ăn, danh sách món ăn và chi tiết công thức; hỗ trợ chuyển đổi giao diện từ Figma sang Flutter; tối ưu trải nghiệm giao diện trên thiết bị di động. |
| Trần Quốc Tiên | 30% | Xây dựng chức năng tìm kiếm và lọc món ăn; xây dựng chức năng lưu và hiển thị món ăn yêu thích; xử lý và hiển thị dữ liệu từ Supabase; kiểm thử chức năng tìm kiếm, lọc, yêu thích và hỗ trợ hoàn thiện màn hình chức năng. |

---

## Trạng thái branch thành viên

### Branch `tran-quoc-tien` (Trần Quốc Tiên)

| Mục | Kết quả |
|-----|---------|
| **Tỉ lệ hoàn thành ước lượng** | **~92%** (phạm vi 30%: search, filter, favorite, Supabase) |
| **Các chức năng đã hoàn thành** | Tìm kiếm Supabase (`RecipeSnapshot.timKiem`), debounce, empty/error state; lọc theo `idCategory` + lọc tên trong list; `FavoriteSnapshot` CRUD + `toggleFavorite` (kèm mã `-1` chưa đăng nhập); `FavoriteController` refresh + cache `favoriteIds`; màn yêu thích (loading, pull refresh, nút reload); `WidgetRecipeCard` tim + điều hướng detail; bổ sung UI home/category/list/detail liên quan |
| **Các phần đã bổ sung thêm** | Không cần patch lớn trước merge — branch đã có empty state, loading, error text, refresh favorite, kiểm tra user null. Commit merge: `5a62bc9` |
| **Các lỗi / thiếu còn lại** | Chưa có test tự động; `flutter analyze` cần chạy trên máy có Flutter SDK |
| **Trạng thái merge** | **Đã merge vào `main`** (fast-forward, không conflict) — `main` trỏ commit `5a62bc9` |

**Checklist kiểm tra nhanh sau merge:**

- [ ] `flutter pub get` && `flutter analyze` (trên máy dev)
- [ ] Đăng nhập → tìm món → mở chi tiết
- [ ] Bấm tim → tab Yêu thích cập nhật
- [ ] Lọc danh mục từ Home / Category

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

*CookBook — NTU / nhóm 2 Flutter. Cập nhật README sau merge `tran-quoc-tien`.*
