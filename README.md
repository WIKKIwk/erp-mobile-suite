# Accord Mobile App

`Accord Mobile App` - ERPNext bilan ishlaydigan operatsion Flutter ilova. U Android-first tamoyiliga tayangan va 4 ta rol uchun alohida ish oqimlarini beradi:

- `Supplier`
- `Werka`
- `Customer`
- `Admin`

Bu client ilova biznes qoidalarni o'zi ishlab chiqmaydi. Ilovaning vazifasi:

- autentifikatsiya qilish
- rolga mos ekranlarni ko'rsatish
- API chaqiruvlarini yuborish
- unread, hidden, cache, push va local alert qatlamini boshqarish
- session, lock va runtime reset qoidalarini ushlab turish

Qisqa zanjir:

`mobile_app -> mobile_server -> ERPNext`

## 1. Hozirgi asosiy qoidalar

- ERP `Delivery Note` - status truth source.
- commentlar business truth emas, faqat qo'shimcha izoh.
- bir rol ichida bir nechta ekran bitta store'dan foydalanishi kerak.
- logout faqat tokenni o'chirmaydi, sessionga bog'liq runtime state'ni ham reset qiladi.
- release APK uchun `127.0.0.1` emas, domain URL ishlatiladi.

## 2. Arxitektura

Ilova 3 qatlamga bo'lingan:

1. `Presentation`
   - screenlar
   - widgetlar
   - dock navigation
   - local UI state

2. `Core`
   - API client
   - session
   - cache
   - notifications
   - security
   - theme
   - localization
   - network guard

3. `Shared models`
   - rol, status, summary, detail va form argument modellari

Asosiy entry fayllar:

- [main.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/main.dart)
- [app.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/app/app.dart)
- [app_router.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/app/app_router.dart)
- [mobile_api.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api.dart)
- [app_models.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/shared/models/app_models.dart)

### Startup oqimi

1. `main.dart` quyidagilarni load qiladi:
   - local notifications
   - session
   - unread store
   - security
   - theme
   - locale
2. `ErpnextStockMobileApp` ishga tushadi.
3. `MaterialApp` ichida:
   - `NetworkRequirementRuntime`
   - `NotificationRuntime`
   - `AppLockGate`
   - `DevicePreview` qatlamlari o'raladi
4. initial route doim `login` route'i.
5. `AppEntryScreen` mavjud local session'ni tekshiradi va kerak bo'lsa role home'ga o'tkazadi.

### Session oqimi

- `AppSession` token va `SessionProfile` ni `SharedPreferences` da saqlaydi.
- login muvaffaqiyatli bo'lsa:
  - session saqlanadi
  - last phone/code saqlanadi
  - role home route tanlanadi
- logout bo'lsa:
  - session tozalanadi
  - role store'lar reset qilinadi
  - unread/hidden state tozalanadi
  - notification snapshot va cache tozalanadi
  - avatar cache tozalanadi
  - last login phone/code o'chiriladi

Asosiy fayllar:

- [app_session.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/session/app_session.dart)
- [app_runtime_reset.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/session/app_runtime_reset.dart)
- [app_entry_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/auth/presentation/app_entry_screen.dart)
- [mobile_api_auth_profile.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api_auth_profile.dart)

## 3. Rol bo'yicha interface

### `Supplier`

Supplier oqimi:

- home summary
- status breakdown
- item picker
- qty kiritish
- dispatch yaratish
- recent/history
- notifications
- detail va status detail

Asosiy ekranlar:

- [supplier_home_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_home_screen.dart)
- [supplier_notifications_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_notifications_screen.dart)
- [supplier_recent_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_recent_screen.dart)
- [supplier_status_breakdown_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_status_breakdown_screen.dart)
- [supplier_status_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_status_detail_screen.dart)
- [supplier_item_picker_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_item_picker_screen.dart)
- [supplier_qty_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_qty_screen.dart)
- [supplier_confirm_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_confirm_screen.dart)
- [supplier_success_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/presentation/supplier_success_screen.dart)

### `Werka`

Werka oqimi:

- home summary
- pending list
- status breakdown
- status detail
- recent/history
- notifications
- create hub
- unannounced supplier flow
- customer issue flow
- receipt confirm / partial / reject

Asosiy ekranlar:

- [werka_home_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_home_screen.dart)
- [werka_notifications_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_notifications_screen.dart)
- [werka_recent_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_recent_screen.dart)
- [werka_status_breakdown_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_status_breakdown_screen.dart)
- [werka_status_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_status_detail_screen.dart)
- [werka_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_detail_screen.dart)
- [werka_customer_delivery_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_customer_delivery_detail_screen.dart)
- [werka_create_hub_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_create_hub_screen.dart)
- [werka_unannounced_supplier_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_unannounced_supplier_screen.dart)
- [werka_customer_issue_customer_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_customer_issue_customer_screen.dart)
- [werka_success_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/presentation/werka_success_screen.dart)

### `Customer`

Customer oqimi:

- home summary
- pending / confirmed / rejected counts
- notifications
- delivery detail
- status detail
- approve / reject flow

Asosiy ekranlar:

- [customer_home_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/customer_home_screen.dart)
- [customer_notifications_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/customer_notifications_screen.dart)
- [customer_status_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/customer_status_detail_screen.dart)
- [customer_delivery_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/customer_delivery_detail_screen.dart)

### `Admin`

Admin oqimi:

- ERP settings
- supplier list
- blocked / inactive suppliers
- supplier detail
- customer detail
- item create
- werka info
- activity feed

Asosiy ekranlar:

- [admin_home_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_home_screen.dart)
- [admin_activity_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_activity_screen.dart)
- [admin_create_hub_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_create_hub_screen.dart)
- [admin_settings_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_settings_screen.dart)
- [admin_suppliers_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_suppliers_screen.dart)
- [admin_inactive_suppliers_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_inactive_suppliers_screen.dart)
- [admin_supplier_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_supplier_detail_screen.dart)
- [admin_customer_detail_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_customer_detail_screen.dart)
- [admin_item_create_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_item_create_screen.dart)
- [admin_supplier_create_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_supplier_create_screen.dart)
- [admin_customer_create_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_customer_create_screen.dart)
- [admin_supplier_items_view_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_supplier_items_view_screen.dart)
- [admin_supplier_items_add_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_supplier_items_add_screen.dart)
- [admin_werka_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/presentation/admin_werka_screen.dart)

## 4. Backend contract

Ilova backend bilan quyidagi umumiy model orqali ishlaydi:

- auth login/logout/profile
- role summary
- history/recent feed
- status breakdown
- status detail
- create/update actions
- notification detail va comments
- admin directory va settings

Delivery Note state fields:

- `accord_flow_state`
  - `0` = none
  - `1` = submitted
  - `2` = returned
- `accord_customer_state`
  - `0` = pending
  - `1` = confirmed
  - `2` = rejected
- `accord_customer_reason`
- `accord_delivery_actor`

Muhim:

- `accord_delivery_actor` live ERP'da hali `Data` turida qolgan.
- qiymat amalda string sifatida yoziladi, lekin semantik jihatdan `werka` ni bildiradi.
- business state commentlardan emas, ERP fieldlardan olinadi.

## 5. API qatlam

`mobile_api.dart` barcha endpointlarni role bo'yicha bo'lib beradi.

### Auth va profile

- login
- logout
- profile fetch
- nickname update
- avatar upload
- push token register/unregister

### Supplier endpointlari

- summary
- history
- status breakdown
- status details
- items
- dispatch create
- notification detail
- comments add
- unannounced response

### Werka endpointlari

- pending
- suppliers
- customers
- supplier items
- customer items
- unannounced create
- customer issue create
- summary
- status breakdown
- status details
- history
- confirm receipt

### Customer endpointlari

- summary
- history
- status details
- delivery detail
- respond delivery

### Admin endpointlari

- settings
- settings update
- werka code regenerate
- activity
- suppliers list
- suppliers summary
- inactive suppliers
- supplier detail
- customer detail
- customer phone update
- customer code regenerate
- customer remove
- customer item add/remove
- items list/create
- supplier create/update actions

Asosiy fayllar:

- [mobile_api_customer.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api_customer.dart)
- [mobile_api_werka.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api_werka.dart)
- [mobile_api_admin.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api_admin.dart)
- [mobile_api_supplier_notifications.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/api/mobile_api_supplier_notifications.dart)

## 6. State, cache va runtime

Ilova server response'lariga to'liq qaram bo'lib qolmasligi uchun local state ishlatadi.

### Role store'lar

- [customer_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/state/customer_store.dart)
- [werka_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/werka/state/werka_store.dart)
- [supplier_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/supplier/state/supplier_store.dart)
- [admin_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/admin/state/admin_store.dart)

Bu store'larning vazifasi:

- summary va listlarni markazlash
- loading/error state ushlash
- bir role ichidagi turli ekranlarga bir xil truth berish
- runtime mutation'larni qo'llash

### Runtime stores

- [customer_delivery_runtime_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/customer_delivery_runtime_store.dart)
- [supplier_runtime_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/supplier_runtime_store.dart)
- [werka_runtime_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/werka_runtime_store.dart)

Bu qatlam qisqa vaqt ichida lokal optimistic update qiladi. Masalan:

- customer detail ochilishi bilan status darhol yangilanadi
- supplier/wereka summary count'lari instant ko'rinadi
- server keyin kelganda mutation reconcile qilinadi

### Cache qatlamlari

- [json_cache_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/cache/json_cache_store.dart)
- [profile_avatar_cache.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/shared/data/profile_avatar_cache.dart)

### Unread/hidden qatlamlari

- [notification_unread_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/notification_unread_store.dart)
- [notification_hidden_store.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/notification_hidden_store.dart)

Muhim qoidalar:

- unread badge faqat real unread ID bo'lsa ko'rinadi
- hidden yozuvlar badge'ni ushlab turmaydi
- clear action server delete emas, local hide hisoblanadi
- notification snapshot eski role'dan yangisiga o'tganda tozalanadi

### RefreshHub

- [refresh_hub.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/refresh_hub.dart)

Bu tizim push yoki boshqa signal kelganda role ekranlarini qayta yuklash uchun ishlatiladi.

### Cache-first UX

Ba'zi screenlar:

- avval local cache ko'rsatadi
- keyin network refresh qiladi

Bu ayniqsa notifications va recent feed ekranlarida foydali.

## 7. Push va local alert

Ilovada ikki signal qatlami bor:

1. FCM push
2. app ichidagi runtime poll

Asosiy fayllar:

- [push_messaging_service.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/push_messaging_service.dart)
- [notification_runtime.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/notification_runtime.dart)
- [local_notification_service.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/notifications/local_notification_service.dart)

### Muhim xatti-harakatlar

- `PushMessagingService` faqat Android'da ishga tushadi.
- token login'dan keyin sync qilinadi.
- foreground push kelganda unread ID qo'shiladi.
- role mismatch bo'lsa push ignore qilinadi.
- `NotificationRuntime` har 12 soniyada history poll qiladi.
- poll bilan eski/yangilangan record signatures solishtiriladi.
- mos record o'zgarsa unread mark bo'ladi va local notification chiqadi.

## 8. Security

Ilovada PIN lock va biometrik unlock bor.

Asosiy fayllar:

- [security_controller.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/security/security_controller.dart)
- [app_lock_gate.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/security/app_lock_gate.dart)
- [pin_setup_entry_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/shared/presentation/pin_setup_entry_screen.dart)
- [pin_setup_confirm_screen.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/shared/presentation/pin_setup_confirm_screen.dart)

Imkoniyatlar:

- 4 xonali PIN
- PIN profil bo'yicha alohida saqlanadi
- biometrik unlock
- app background'dan qaytganda lock
- login'dan keyin unlock

## 9. UI tamoyillari

Ilova UI'si enterprise uslubga yaqin:

- `AppShell` asosiy frame
- `ActionDock` role navigation
- `SoftCard`, `StatusPill`, `MetricBadge` shared vizual bloklar
- `AppRefreshIndicator` custom refresh experience
- page enter/out motion
- `Material 3` tonal surface yo'nalishi

Asosiy shared widgetlar:

- [app_shell.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/widgets/app_shell.dart)
- [common_widgets.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/widgets/common_widgets.dart)
- [motion_widgets.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/widgets/motion_widgets.dart)
- [app_theme.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/theme/app_theme.dart)
- [app_motion.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/theme/app_motion.dart)

### Customer tab navigation

Customer oqimida home / notifications / profile o'rtasida swipe va route replacement ishlatiladi:

- [customer_tab_navigation.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/widgets/customer_tab_navigation.dart)
- [customer_dock.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/features/customer/presentation/widgets/customer_dock.dart)

## 10. Network va offline

Asosiy fayllar:

- [network_requirement_runtime.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/network/network_requirement_runtime.dart)
- [network_required_dialog.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/network/network_required_dialog.dart)

Xatti-harakatlar:

- app ochilganda backend healthz tekshiriladi
- resume bo'lganda yana tekshiriladi
- backend yetib bo'lmasa blur dialog chiqadi
- login screen internet muammosini aniq xabar bilan ko'rsatadi

## 11. Theme va localization

Asosiy fayllar:

- [theme_controller.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/theme/theme_controller.dart)
- [locale_controller.dart](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/lib/src/core/localization/locale_controller.dart)

Hozirgi holat:

- theme `light` / `dark`
- locale `uz`, `en`, `ru`
- sozlamalar local saqlanadi

## 12. Android integratsiya

Muhim Android fayllar:

- [android/app/build.gradle.kts](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/android/app/build.gradle.kts)
- [android/build.gradle.kts](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/android/build.gradle.kts)
- [android/app/src/main/AndroidManifest.xml](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/android/app/src/main/AndroidManifest.xml)
- [android/app/google-services.json](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/android/app/google-services.json)

Integratsiyalar:

- FCM
- local notifications
- launcher icon
- Android permission handling
- release APK uchun domain URL

## 13. Fayl tuzilmasi

Qisqacha xarita:

```text
mobile_app/
├── android/
├── assets/
│   ├── branding/
│   └── icons/
├── lib/
│   ├── main.dart
│   └── src/
│       ├── app/
│       ├── core/
│       │   ├── api/
│       │   ├── cache/
│       │   ├── localization/
│       │   ├── network/
│       │   ├── notifications/
│       │   ├── security/
│       │   ├── session/
│       │   ├── theme/
│       │   └── widgets/
│       └── features/
│           ├── auth/
│           ├── customer/
│           ├── supplier/
│           ├── werka/
│           ├── admin/
│           └── shared/
├── test/
├── Makefile
└── pubspec.yaml
```

## 14. Dependencies

Asosiy package'lar:

- `flutter_svg`
- `google_fonts`
- `shared_preferences`
- `file_picker`
- `local_auth`
- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`
- `device_preview`
- `http`

To'liq ro'yxat uchun:

- [pubspec.yaml](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/pubspec.yaml)

## 15. Run va build buyruqlari

### Dependencies

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
flutter pub get
```

### Local run

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make run
```

Bu:

- local backend/core'ni ko'taradi
- Flutter Linux preview ishga tushiradi
- default API URL sifatida `http://127.0.0.1:8081` ni ishlatadi

### Web preview

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make web
```

### Remote tunnel run

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make run-remote
```

### Domain run

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make run-domain
```

Domain URL:

- `https://core.wspace.sbs`

### Domain APK

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make apk-domain APK_NAME=accord.apk
```

Natija:

- [accord.apk](/home/wikki/local.git/erpnext_stock_telegram/mobile_app/build/app/outputs/flutter-apk/accord.apk)

### Remote APK

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
make apk-remote APK_NAME=accord.apk
```

### Static verification

```bash
cd /home/wikki/local.git/erpnext_stock_telegram/mobile_app
flutter analyze
flutter test
```

### Muhim Make targetlar

- `make deps`
- `make run`
- `make web`
- `make run-remote`
- `make run-domain`
- `make remote-up`
- `make remote-stop`
- `make domain-up`
- `make apk-remote`
- `make apk-domain`
- `make analyze`
- `make test`

## 16. Muhim environment

`dart-define`:

- `MOBILE_API_BASE_URL`

Default:

```text
http://127.0.0.1:8081
```

APK uchun:

- release build'larda domain URL ishlatilsin
- `127.0.0.1` / `localhost` release uchun ishlatilmasin

## 17. Local-only fayllar

Commit qilinmasligi kerak bo'lgan fayllar:

- `android/app/google-services.json`
- local secretlar
- machine-specific build artefaktlar

## 18. Manual verification uchun eng muhim flows

Tavsiya etiladigan real testlar:

- supplier login
- werka login
- customer login
- admin login
- app kill / reopen
- logout / reopen
- supplier dispatch
- werka accept / partial / reject
- werka customer issue
- werka unannounced supplier
- customer approve / reject
- unread badge
- hidden notifications
- app lock
- offline warning
- real Android APK install

## 19. Hozirgi known gap

Lokal testlarda bir nechta widget testlar uchun localization wrapper hali to'liq to'g'rilanmagan bo'lishi mumkin. Hozirgi kod bazada:

- `flutter analyze` yashil
- `flutter test` esa ayrim widget testlarda `AppLocalizations` context setup'iga urilishi mumkin

Bu README doc muammosi emas, test harness masalasi.

## 20. Qisqa xulosa

Bu repo oddiy Flutter demo emas. Bu:

- ERPNext bilan integratsiyalashgan
- role-based
- session-aware
- cache-first
- push-ready
- app-lock bilan himoyalangan
- Android-first operatsion mobil client

Keyingi README ishlari uchun eng muhim yozuvlar shu faylda jamlangan. Agar xohlasangiz, keyingi bosqichda men shu README'ni yana ham qisqartirib, tashqi odamga beriladigan "clean" versiyaga ham aylantirib beraman.
