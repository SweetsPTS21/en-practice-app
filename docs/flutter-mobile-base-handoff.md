# Flutter Mobile Base Handoff

Tài liệu này dành cho team mobile để có thể bắt đầu dựng base Flutter ngay, bám sát hệ thống hiện có ở web về:

- theme mode: `light | dark | system`
- theme profile: ngôn ngữ thiết kế toàn app
- background preset: mood nền toàn hệ thống
- solid primary: màu primary riêng cho `Solid System`
- semantic tokens: text, background, border, shadow, radius, typography, motion, density
- page palette: accent theo module
- đa ngôn ngữ: `en | vi`

Mục tiêu của tài liệu này không phải mô tả UI từng màn, mà là chốt phần nền kiến trúc để mobile có thể dựng app shell, design system và localization đúng từ đầu.

## 1. Source Of Truth Hiện Tại

Mobile cần coi các file sau là nguồn tham chiếu chính:

- `src/theme/themeTokens.js`
- `src/theme/themeProfiles.js`
- `src/theme/ThemeProvider.jsx`
- `src/theme/themeStorage.js`
- `src/config/pagePalettes.js`
- `src/i18n/index.js`
- `src/i18n/locales/en.js`
- `src/i18n/locales/vi.js`
- `docs/theme-system-refactor-plan.md`
- `docs/theme-profile-catalog.md`

## 2. Kết Luận Quan Trọng Trước Khi Dựng Base

Mobile không được hiểu theme của dự án này là "đổi màu primary".

Theme hiện tại là tổ hợp của 4 lớp:

1. `themePreference`
   - `light`
   - `dark`
   - `system`
2. `themeProfilePreference`
   - quyết định ngôn ngữ thiết kế: radius, typography, motion, density, đôi khi cả behavior lock
3. `themeBackgroundPreference`
   - quyết định mood nền tổng thể
4. `themeSolidPrimaryPreference`
   - chỉ có ý nghĩa khi profile là `solid`

Ngoài ra, mỗi page group còn có `page palette` riêng để tạo accent theo module như `dashboard`, `profile`, `dictionary`, `ielts`, `writing`, `speaking`, `leaderboard`.

Nếu mobile chỉ dựng `ThemeData.light()` và `ThemeData.dark()` thì sẽ lệch kiến trúc hiện tại.

## 3. Trạng Thái Theme Đang Được Web Quản Lý

Theo `ThemeProvider`, state logic hiện tại gồm:

- `themePreference`
- `effectiveThemePreference`
- `themeBackgroundPreference`
- `effectiveThemeBackgroundPreference`
- `themeProfilePreference`
- `themeSolidPrimaryPreference`
- `activeThemeProfile`
- `resolvedTheme`
- `isDark`
- `themeTokens`
- `themeModeLocked`
- `themeBackgroundLocked`

Ý nghĩa:

- `themePreference` là lựa chọn user.
- `resolvedTheme` là mode cuối cùng sau khi xét `system`.
- `activeThemeProfile` có thể khóa mode hoặc background.
- `effectiveThemePreference` và `effectiveThemeBackgroundPreference` là giá trị thực tế sau khi áp behavior lock.

Mobile phải giữ đúng tư duy này để tránh bug khi thêm profile cố định như `mono`.

## 4. Các Enum Và Giá Trị Hiện Có

### 4.1. Theme mode

```txt
light
dark
system
```

### 4.2. Theme background preset

```txt
balanced
sage
ocean
dawn
amethyst
blossom
petal
midnight
ember
canopy
```

### 4.3. Theme profile

```txt
glass
calm
contrast
editorial
pulse
focus
signal
solid
mono
```

### 4.4. Solid primary option

```txt
violet
blue
emerald
amber
rose
```

### 4.5. Supported language

```txt
en
vi
```

## 5. Storage Key Cần Đồng Bộ Về Mặt Semantics

Web đang dùng các key sau:

```txt
en_practice_theme_preference
en_practice_theme_background
en_practice_theme_profile
en_practice_theme_solid_primary
en_practice_language
```

Khuyến nghị cho Flutter:

- Có thể giữ đúng các key này trong `SharedPreferences` để đồng nhất tư duy giữa web và mobile.
- Không cần ép dùng cùng storage backend, nhưng tên key nên giữ nguyên.

## 6. Kiến Trúc Flutter Đề Xuất

Khuyến nghị stack cho base:

- `flutter_riverpod`
- `go_router`
- `shared_preferences`
- `easy_localization` hoặc `slang`
- `google_fonts` nếu cần map profile typography gần hơn với web

Không nên nhét theme logic vào `main.dart`.

### 6.1. Cấu trúc thư mục đề xuất

```txt
lib/
  app/
    app.dart
    router/
      app_router.dart
  core/
    theme/
      app_theme_controller.dart
      app_theme_state.dart
      app_theme_storage.dart
      theme_mode_prefs.dart
      theme_profiles.dart
      theme_backgrounds.dart
      theme_solid_primary.dart
      theme_tokens.dart
      theme_resolver.dart
      theme_extensions.dart
      page_palettes.dart
    l10n/
      app_locale_controller.dart
      app_locale_storage.dart
      translations/
        en.json
        vi.json
    design/
      tokens/
        app_colors.dart
        app_text_tokens.dart
        app_radius.dart
        app_motion.dart
        app_density.dart
      widgets/
        app_shell.dart
        app_card.dart
        app_button.dart
        app_page_scaffold.dart
  features/
    settings/
    dashboard/
    profile/
    dictionary/
    ielts/
    writing/
    speaking/
```

## 7. Theme Contract Mà Flutter Cần Có

Flutter cần model hóa token ở cấp app, không nên chỉ dùng `ColorScheme`.

Khuyến nghị tạo `AppThemeTokens` với shape gần tương đương web:

```dart
class AppThemeTokens {
  final String mode;
  final bool isDark;

  final Color primary;
  final Color primaryStrong;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  final AppTextTokens text;
  final AppBackgroundTokens background;
  final AppBorderTokens border;
  final AppShadowTokens shadow;
  final AppRadiusTokens radius;
  final AppTypographyTokens typography;
  final AppMotionTokens motion;
  final AppDensityTokens density;

  final String profile;
}
```

### 7.1. Các group token bắt buộc

`text`
- `primary`
- `secondary`
- `muted`
- `soft`
- `inverse`

`background`
- `body`
- `canvas`
- `shell`
- `panel`
- `panelStrong`
- `frosted`
- `elevated`
- `overlay`
- `mobileDrawer`

`border`
- `strong`
- `subtle`
- `accent`

`shadow`
- `shell`
- `panel`
- `card`
- `accent`

`radius`
- `xs`
- `sm`
- `md`
- `lg`
- `xl`
- `2xl`
- `3xl`
- `hero`

`typography`
- `fontFamily`
- `fontFamilyDisplay`
- `titleTracking`
- `bodyTracking`

`motion`
- `fast`
- `normal`
- `slow`
- `blurSoft`
- `blurStrong`
- `hoverLift`

`density`
- `controlHeight`
- `controlHeightSmall`
- `controlHeightLarge`
- `panelPadding`
- `compactGap`
- `regularGap`

## 8. Theme Resolver Trên Flutter

Logic resolver của mobile cần khớp với web:

1. Lấy `themePreference`, `themeBackgroundPreference`, `themeProfilePreference`, `themeSolidPrimaryPreference`
2. Lấy `systemBrightness`
3. Lấy `activeThemeProfile`
4. Nếu profile có `behavior.lockMode`, override mode
5. Nếu profile có `behavior.lockBackground`, override background
6. Resolve theme tokens theo:
   - base semantic mode
   - merge background preset
   - merge profile preset
   - nếu profile là `solid`, merge solid primary preset

Pseudo flow:

```txt
stored preferences
-> apply profile behavior lock
-> resolve light/dark
-> merge semantic base
-> merge background preset
-> merge profile preset
-> merge solid primary when needed
-> build AppThemeTokens
-> build ThemeData + ThemeExtension
```

## 9. Theme Profile Không Chỉ Là Màu

Đây là điểm mobile cần bám rất sát.

Từ `themeProfiles.js`, mỗi profile hiện có:

- `palette`
- `radius`
- `typography`
- `motion`
- `density`
- đôi khi `behavior`

### 9.1. Ý nghĩa từng profile

- `glass`
  - nhiều blur, bo lớn, bóng đổ rõ, giàu chiều sâu
- `calm`
  - mềm, dịu, bo vừa, yên hơn
- `contrast`
  - sắc nét, gọn, đọc nhanh
- `editorial`
  - display serif, cảm giác magazine
- `pulse`
  - energetic, techy, giàu accent
- `focus`
  - flat hơn, blur bằng 0, ít shadow
- `signal`
  - warm accent, solid surface, tối giản
- `solid`
  - flat/safe/systematic, ít gradient, ít shadow
- `mono`
  - monochrome, khóa mode/background

### 9.2. Quy tắc cho Flutter

- Không hard-code radius chung cho mọi profile.
- Không hard-code font chung cho mọi profile.
- Không hard-code card elevation cố định.
- Theme profile phải thay đổi được feel của component nền.

## 10. Mapping ThemeData Trên Flutter

Khuyến nghị:

- Dùng `ThemeData` cho phần Material cơ bản
- Dùng `ThemeExtension` cho token sản phẩm riêng

Ví dụ:

```dart
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final AppThemeTokens tokens;
  final AppPagePalettes pagePalettes;
}
```

Những gì nên map vào `ThemeData`:

- `brightness`
- `scaffoldBackgroundColor`
- `colorScheme`
- `textTheme`
- `cardTheme`
- `appBarTheme`
- `dividerColor`
- `inputDecorationTheme`
- `elevatedButtonTheme`
- `outlinedButtonTheme`
- `chipTheme`

Những gì nên để ở `ThemeExtension`:

- gradient
- overlay
- blur intent
- hero surface
- semantic panel variants
- shell tokens
- page palettes
- design-system specific motion/density

## 11. Background Preset Trên Flutter

Background preset ở web hiện không chỉ là một màu nền.

Nó thay đổi cả:

- `body`
- `canvas`
- `shell`
- `panel`
- `panelStrong`
- `frosted`
- `elevated`
- `overlay`
- `mobileDrawer`

Do đó ở Flutter:

- Không nên model background preset như `Color background`.
- Nên model thành `AppBackgroundPreset` với đầy đủ surface variants.

Khuyến nghị UI shell của mobile:

- `body` dùng cho root gradient/background
- `canvas` cho scaffold nền chính
- `shell` cho nav shell, bottom nav container, side sheet
- `panel` và `panelStrong` cho card/panel
- `elevated` cho popup/dialog/dropdown-like surfaces

## 12. Solid Primary Logic

Theo web, `solid primary` chỉ áp dụng khi profile là `solid`.

Flutter cần giữ đúng behavior:

- Nếu profile != `solid`, vẫn lưu preference nhưng không áp effect
- Nếu profile == `solid`, merge preset tương ứng vào:
  - `primary`
  - `primaryStrong`
  - `secondary`
  - `accent`
  - `border.accent`
  - `shadow.accent`

## 13. Page Palette Trên Mobile

`src/config/pagePalettes.js` là lớp accent theo module.

Hiện có:

- `profile`
- `dashboard`
- `dictionary`
- `vocabularyTest`
- `vocabularyCheck`
- `review`
- `evaluation`
- `ielts`
- `speaking`
- `writing`
- `leaderboard`

Mỗi page palette không thay semantic base của app, mà thêm:

- hero gradient
- panel shadow bias
- result surfaces
- action gradients
- card emphasis
- custom module accent

Flutter nên có:

```dart
enum AppPagePaletteKey {
  profile,
  dashboard,
  dictionary,
  vocabularyTest,
  vocabularyCheck,
  review,
  evaluation,
  ielts,
  speaking,
  writing,
  leaderboard,
}
```

Và helper:

```dart
AppPagePalette getPagePalette(AppPagePaletteKey key, BuildContext context)
```

Điều này giúp mobile dựng `AppPageScaffold` ngay từ base mà không bị lệch tinh thần module.

## 14. Đa Ngôn Ngữ

Theo `src/i18n/index.js`, web hiện:

- support `en`, `vi`
- fallback `en`
- detect theo local storage trước, sau đó navigator

### 14.1. Yêu cầu cho mobile

- supported locales: `en`, `vi`
- fallback locale: `en`
- persist locale bằng key `en_practice_language`
- nếu chưa có lựa chọn user:
  - ưu tiên locale thiết bị
  - nếu locale thiết bị không thuộc `en | vi`, fallback `en`

### 14.2. Nguồn dịch

Web đang giữ translation dưới dạng object JS rất lớn:

- `src/i18n/locales/en.js`
- `src/i18n/locales/vi.js`

Khuyến nghị cho mobile:

- convert sang `json` hoặc format của package localization đang dùng
- giữ nguyên key path nhiều nhất có thể

Ví dụ:

```txt
common.login
app.pageTitles.home
app.theme.modes.light
settingsPage.theme.title
notificationCenter.hero.title
writing.title
dictionary.hero.title
```

Không nên tạo lại hệ key mới trên mobile nếu chưa cần.

## 15. Typography Và Font Strategy

Web hiện dùng profile-specific font stacks:

- `Inter`
- `Manrope`
- `DM Sans`
- `Fraunces`
- `Space Grotesk`
- `IBM Plex Sans`
- `IBM Plex Mono`

Khuyến nghị cho Flutter:

- Dùng `google_fonts` hoặc bundle local fonts
- Tối thiểu phải hỗ trợ:
  - body font
  - display font

Ví dụ mapping thực dụng:

- `glass` -> Inter
- `calm` -> Manrope
- `contrast` -> IBM Plex Sans
- `editorial` -> DM Sans + Fraunces
- `pulse` -> DM Sans + Space Grotesk
- `focus` -> IBM Plex Sans
- `signal` -> DM Sans
- `solid` -> IBM Plex Sans
- `mono` -> IBM Plex Sans + IBM Plex Mono

Nếu phase đầu chưa kịp bundle đủ font:

- vẫn phải thiết kế `AppTypographyTokens` tách riêng
- cho phép thay font sau mà không đổi component tree

## 16. Motion, Blur, Density

Mobile thường dễ bỏ qua 3 lớp này, nhưng dự án hiện không coi chúng là phụ.

### 16.1. Motion

Mỗi profile có:

- `fast`
- `normal`
- `slow`
- `hoverLift`

Trên Flutter cần map sang:

- animation durations
- curve presets
- sheet transition / page transition intensity
- press elevation / scale intent

### 16.2. Blur

`blurSoft` và `blurStrong` phải được giữ ở token level dù phase đầu chưa dùng hết.

Lý do:

- `glass` khác `solid` chủ yếu ở cảm giác surface
- nếu bỏ blur token từ đầu thì sau này sẽ phải refactor design system

### 16.3. Density

Profile có thể thay đổi:

- chiều cao control
- khoảng cách compact
- khoảng cách regular
- panel padding

Flutter nên có helper như:

```dart
class AppSpacing {
  final double compactGap;
  final double regularGap;
  final double panelPadding;
}
```

## 17. Base Screen Mà Mobile Nên Dựng Ngay

Để base usable càng sớm càng tốt, nên dựng ngay:

1. `AppBootstrap`
   - load locale + theme prefs
2. `AppThemeController`
   - thay đổi mode/profile/background/solidPrimary
3. `AppLocaleController`
   - thay đổi `en | vi`
4. `AppShell`
   - root scaffold với background theo token
5. `Settings demo page`
   - cho đổi:
     - mode
     - profile
     - background
     - solid primary
     - language
6. `Theme preview page`
   - hiển thị card, button, chip, section header, page hero

Nếu làm 6 phần này trước, team mobile có thể bắt đầu feature development mà không bị nợ kiến trúc nền.

## 18. Mẫu State Cho Flutter

```dart
class AppThemeState {
  final AppThemePreference themePreference;
  final AppThemeBackgroundPreference themeBackgroundPreference;
  final AppThemeProfilePreference themeProfilePreference;
  final AppThemeSolidPrimaryPreference themeSolidPrimaryPreference;
  final Brightness systemBrightness;

  final AppThemePreference effectiveThemePreference;
  final AppThemeBackgroundPreference effectiveThemeBackgroundPreference;
  final AppResolvedTheme resolvedTheme;
  final bool isDark;
  final bool themeModeLocked;
  final bool themeBackgroundLocked;

  final AppThemeProfile activeThemeProfile;
  final AppThemeTokens tokens;
}
```

## 19. Mẫu Controller API

```dart
abstract class AppThemeController {
  Future<void> initialize();
  Future<void> setThemePreference(AppThemePreference value);
  Future<void> setThemeBackgroundPreference(AppThemeBackgroundPreference value);
  Future<void> setThemeProfilePreference(AppThemeProfilePreference value);
  Future<void> setThemeSolidPrimaryPreference(AppThemeSolidPrimaryPreference value);
  Future<void> syncSystemBrightness(Brightness brightness);
}
```

## 20. Những Quy Tắc Không Được Làm Sai

- Không hard-code màu trực tiếp trong feature page nếu màu đó là semantic token.
- Không bind UI trực tiếp vào `Brightness` mà bỏ qua `themeProfile`.
- Không bỏ qua `behavior.lockMode` và `behavior.lockBackground`.
- Không gộp `background preset` vào `theme profile`.
- Không dựng localization bằng key mới khi key cũ đang dùng tốt.
- Không dùng string literal cho label ở settings nếu key dịch đã có trong `en.js` và `vi.js`.
- Không để page tự chọn typography/radius ngoài design system.

## 21. Phase 1 Done Checklist Cho Mobile Base

- Có `ThemeController` và `LocaleController`
- Có persistence cho 5 key:
  - `en_practice_theme_preference`
  - `en_practice_theme_background`
  - `en_practice_theme_profile`
  - `en_practice_theme_solid_primary`
  - `en_practice_language`
- Có support `light | dark | system`
- Có support đủ 9 theme profile
- Có support đủ 10 background preset
- Có support đủ 5 solid primary option
- Có support `en | vi`
- Có fallback locale `en`
- Có `ThemeExtension` hoặc lớp token tương đương
- Có page preview để kiểm tra token hoạt động
- Có settings base để đổi theme/language realtime
- Có shell base dùng token thật, không phải scaffold mặc định

## 22. Khuyến Nghị Thực Thi

Thứ tự nên làm:

1. Dựng model và enum
2. Dựng storage
3. Dựng theme resolver
4. Dựng localization bootstrap
5. Dựng `ThemeData + ThemeExtension`
6. Dựng settings preview page
7. Sau đó mới bắt đầu các feature như auth/home/profile

Nếu làm ngược, team mobile sẽ rất dễ rơi vào tình trạng feature chạy được nhưng phải refactor lại toàn bộ theme sau.

## 23. Chốt Phạm Vi Cho Team Mobile

Để bắt đầu xây base luôn, mobile chỉ cần chốt 3 nguyên tắc:

1. Theme là multi-layer system, không phải chỉ light/dark.
2. Token là source of truth, component phải đọc từ token.
3. Localization phải dùng lại key structure hiện có của web.

Khi 3 nguyên tắc này đúng từ đầu, phần còn lại như home, profile, dictionary, IELTS hay writing sẽ vào được rất nhanh mà không lệch nền kiến trúc.
