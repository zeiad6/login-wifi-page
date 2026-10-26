# ⚡ Zeidex Hotspot | Multi-Theme MikroTik Captive Portal System

[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![RouterOS](https://img.shields.io/badge/MikroTik-RouterOS_v6_%26_v7-blue.svg)](https://mikrotik.com)
[![Offline](https://img.shields.io/badge/Dependencies-Zero_Offline-emerald.svg)](#)
[![Security](https://img.shields.io/badge/Security-CHAP_MD5_%2B_Anti--Bruteforce-violet.svg)](#)

نظام قوالب هوتسبوت مايكروتك متعدد التصاميم الاحترافية لشبكة **Zeidex** بنظام الكروت الفردي (Single Voucher Code) مع واجهة مدمجة لأماكن ونقاط بيع الكروت، وتشفير CHAP MD5 وحماية متكاملة ضد التخمين.

---

## 🎨 القوالب المتوفرة (Available Themes)

كل قالب مجلد مستقل في `themes/<id>/` يضم شعاره في `assets/logo.svg` وأربع صفحات: `login.html` و`status.html` و`alogin.html` و`logout.html`. الصفحات مكتفية ذاتياً (CSS وJS مضمّنان، بلا خطوط أو مكتبات خارجية)، فتعمل قبل أن يملك المستخدم إنترنت.

| المعاينة | الشعار | القالب | المعرّف | الطابع |
| :---: | :---: | :--- | :--- | :--- |
| <img src="previews/oled-matrix.webp" width="180" alt="معاينة متحركة لقالب oled-matrix"> | <img src="themes/oled-matrix/assets/logo.svg" width="160" alt="شعار oled-matrix"> | **OLED Matrix** | `oled-matrix` | أسود مطلق، نافذة طرفية، مطر أرقام عربية خافت (المفعّل حالياً) |
| <img src="previews/cyberpunk.webp" width="180" alt="معاينة متحركة لقالب cyberpunk"> | <img src="themes/cyberpunk/assets/logo.svg" width="160" alt="شعار cyberpunk"> | **Cyberpunk Neon** | `cyberpunk` | أفق نيون بشمس مخططة وأرضية شبكية متحركة وزوايا مشطوفة |
| <img src="previews/swiss-minimal.webp" width="180" alt="معاينة متحركة لقالب swiss-minimal"> | <img src="themes/swiss-minimal/assets/logo.svg" width="160" alt="شعار swiss-minimal"> | **Swiss Minimal** | `swiss-minimal` | ورق فاتح وحبر أسود وشبكة صارمة واسم Zeidex بعرض الصفحة |
| <img src="previews/aurora-glass.webp" width="180" alt="معاينة متحركة لقالب aurora-glass"> | <img src="themes/aurora-glass/assets/logo.svg" width="160" alt="شعار aurora-glass"> | **Aurora Glass** | `aurora-glass` | شفق قطبي متحرك خلف لوحة زجاجية متجمدة |
| <img src="previews/neo-brutalist.webp" width="180" alt="معاينة متحركة لقالب neo-brutalist"> | <img src="themes/neo-brutalist/assets/logo.svg" width="160" alt="شعار neo-brutalist"> | **Neo-Brutalist** | `neo-brutalist` | أصفر وحدود سوداء عريضة وظلال صلبة وشريط أسعار متحرك |
| <img src="previews/luxury-gold.webp" width="180" alt="معاينة متحركة لقالب luxury-gold"> | <img src="themes/luxury-gold/assets/logo.svg" width="160" alt="شعار luxury-gold"> | **Luxury Champagne** | `luxury-gold` | عاجي وذهب مسطح بخط نسخ وقائمة أسعار فندقية |
| <img src="previews/spatial-glass.webp" width="180" alt="معاينة متحركة لقالب spatial-glass"> | <img src="themes/spatial-glass/assets/logo.svg" width="160" alt="شعار spatial-glass"> | **Spatial Glass** | `spatial-glass` | زجاج عميق، لوحة تميل مع المؤشر، شريط خدمات بأسلوب Dock |
| <img src="previews/nordic-studio.webp" width="180" alt="معاينة متحركة لقالب nordic-studio"> | <img src="themes/nordic-studio/assets/logo.svg" width="160" alt="شعار nordic-studio"> | **Nordic Studio** | `nordic-studio` | بازلت داكن ولمسة برتقالية واحدة وعنوان معماري كبير |

ما تشترك فيه كل القوالب:
- تشفير CHAP MD5، مع رجوع إلى PAP إن لم يرسل الراوتر `chap-id`.
- ترجمة رسائل خطأ الراوتر الشائعة إلى العربية (رقم خاطئ، انتهاء الوقت أو البيانات، الكرت مستخدم على جهاز آخر).
- قائمة الباقات ظاهرة مباشرة، ونافذتا نقاط البيع (مع بحث يتجاهل الهمزات والتاء المربوطة) والدعم الفني.
- دعم لوحة المفاتيح وقارئات الشاشة، واحترام إعداد `prefers-reduced-motion`.
- طلب قياس زمن استجابة واحد فقط عند الفتح، حتى لا يُحظر المستخدم بقاعدة Anti-Brute Force.

- **المعاينات:** صور متحركة في `previews/<id>.webp` (خطأ الإدخال، تقسيم رقم الكرت، نافذة نقاط البيع) وصورة ثابتة في `previews/<id>.png`.
- **معرض القوالب:** [`gallery.html`](gallery.html) يعرض كل قالب حياً داخل إطار هاتف (`http://localhost:3000/gallery.html`).

---

## 🛠️ تبديل القوالب (Switching Themes)

ينسخ الأمر صفحات القالب الأربع إلى جذر المشروع:
```bash
./scripts/switch-theme.sh [oled-matrix | cyberpunk | swiss-minimal | aurora-glass | neo-brutalist | luxury-gold | spatial-glass | nordic-studio]
```

---

## 📜 إعداد الراوتر (RouterOS)

1. عدّل المتغيرات في أعلى [`scripts/deploy_zeidex.rsc`](scripts/deploy_zeidex.rsc): القالب `theme`، ورابط المستودع `repo`، والإصدار `ref` (يُفضَّل وسم إصدار ثابت بدل `main`)، ومجلد الصفحات `dir`.
2. ارفع الملف إلى الراوتر ثم نفّذ: `/import file-name=deploy_zeidex.rsc`
3. ارفع [`scripts/hotspot_security.rsc`](scripts/hotspot_security.rsc) ونفّذ: `/import file-name=hotspot_security.rsc`

ما يفعله السكربتان:
- بروفايل `Zeidex_Profile` باسم `zeidex.net` ودخول `http-chap,cookie` فقط، فلا يقبل الراوتر رقم الكرت نصاً مكشوفاً.
- تنزيل صفحات القالب من GitHub عبر HTTPS مع التحقق من الشهادة (`check-certificate=yes`). في RouterOS v7.19 فما فوق فعّل `/certificate settings set builtin-trust-anchors=trusted`.
- حذف استثناءات CDN القديمة من Walled Garden، فالصفحات لا تحتاج أي مورد خارجي.
- حماية منافذ خادم الهوتسبوت `64872-64875`: حظر 15 دقيقة لمن يتجاوز 60 اتصالاً جديداً في الدقيقة أو 40 اتصالاً مفتوحاً. الحدود واسعة عمداً لأن الهواتف ترسل فحوص اتصال متكررة.
- الحماية الحقيقية من تخمين الكروت هي طول الرقم: استخدم 10 أرقام عشوائية أو أكثر.

---

## English

**Zeidex Hotspot** is a set of 8 MikroTik hotspot themes. Each `themes/<id>/` folder holds `login.html`, `status.html`, `alogin.html`, `logout.html` and `assets/logo.svg`. Pages are self-contained (inline CSS/JS, no external fonts or CDNs), so they load before the client has internet access.

- **Login:** HTTP-CHAP (MD5) with the router's `chap-id`/`chap-challenge`; MikroTik error messages are translated to Arabic.
- **Switch theme:** `./scripts/switch-theme.sh <id>` copies the four pages to the repository root.
- **Router setup:** edit the variables at the top of `scripts/deploy_zeidex.rsc`, upload it, then run `/import file-name=deploy_zeidex.rsc`. Then import `scripts/hotspot_security.rsc` for per-IP rate limiting on the hotspot web ports (64872-64875).
- **Preview:** open `gallery.html` from a local web server to see every theme live.

---

## 📄 الترخيص (License)
مرخص تحت رخصة **[MIT License](LICENSE)** للاستخدام المفتوح.
