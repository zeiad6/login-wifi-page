# 👑 الباشا نت | El Basha Net — MikroTik Hotspot Turnkey

[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![RouterOS](https://img.shields.io/badge/MikroTik-RouterOS_v6_%26_v7-blue.svg)](https://mikrotik.com)
[![Offline](https://img.shields.io/badge/Dependencies-Zero_Offline-emerald.svg)](#)
[![Security](https://img.shields.io/badge/Security-CHAP_MD5_%2B_Anti--Bruteforce-violet.svg)](#)

نظام قوالب هوتسبوت مايكروتك متعدد التصاميم الاحترافية لشبكة **الباشا نت (El Basha Net)** بنظام الكروت الفردي (Single Voucher Code) مع واجهة مدمجة لأماكن ونقاط بيع الكروت، وتشفير CHAP MD5 وحماية متكاملة ضد التخمين.

---

## 🎨 القوالب المتوفرة (Available Themes)

كل قالب مجلد مستقل في `themes/<id>/` يضم شعاره في `assets/logo.svg` وأربع صفحات: `login.html` و`status.html` و`alogin.html` و`logout.html`. الصفحات مكتفية ذاتياً (CSS وJS مضمّنان، بلا خطوط أو مكتبات خارجية)، فتعمل قبل أن يملك المستخدم إنترنت.

| المعاينة | الشعار | القالب | المعرّف | الطابع |
| :---: | :---: | :--- | :--- | :--- |
| <img src="previews/oled-matrix.webp" width="180" alt="معاينة متحركة لقالب oled-matrix"> | <img src="themes/oled-matrix/assets/logo.svg" width="160" alt="شعار oled-matrix"> | **OLED Matrix** | `oled-matrix` | أسود مطلق، نافذة طرفية، مطر أرقام عربية خافت |
| <img src="previews/cyberpunk.webp" width="180" alt="معاينة متحركة لقالب cyberpunk"> | <img src="themes/cyberpunk/assets/logo.svg" width="160" alt="شعار cyberpunk"> | **Cyberpunk Neon** | `cyberpunk` | أفق نيون بشمس مخططة وأرضية شبكية متحركة وزوايا مشطوفة |
| <img src="previews/swiss-minimal.webp" width="180" alt="معاينة متحركة لقالب swiss-minimal"> | <img src="themes/swiss-minimal/assets/logo.svg" width="160" alt="شعار swiss-minimal"> | **Swiss Minimal** | `swiss-minimal` | ورق فاتح وحبر أسود وشبكة صارمة واسم El Basha بعرض الصفحة |
| <img src="previews/aurora-glass.webp" width="180" alt="معاينة متحركة لقالب aurora-glass"> | <img src="themes/aurora-glass/assets/logo.svg" width="160" alt="شعار aurora-glass"> | **Aurora Glass** | `aurora-glass` | شفق قطبي متحرك خلف لوحة زجاجية متجمدة |
| <img src="previews/neo-brutalist.webp" width="180" alt="معاينة متحركة لقالب neo-brutalist"> | <img src="themes/neo-brutalist/assets/logo.svg" width="160" alt="شعار neo-brutalist"> | **Neo-Brutalist** | `neo-brutalist` | أصفر وحدود سوداء عريضة وظلال صلبة وشريط أسعار متحرك |
| <img src="previews/luxury-gold.webp" width="180" alt="معاينة متحركة لقالب luxury-gold"> | <img src="themes/luxury-gold/assets/logo.svg" width="160" alt="شعار luxury-gold"> | **Luxury Champagne** | `luxury-gold` | عاجي وذهب مسطح بخط نسخ وقائمة أسعار فندقية (المفعّل حالياً) |
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

## 📜 إعداد الراوتر (RouterOS v7)

سكربت واحد يجهّز الشبكة كاملة: [`scripts/elbasha_turnkey.rsc`](scripts/elbasha_turnkey.rsc).

1. عدّل المتغيرات في "البلوك 0" أعلى الملف: المنافذ، العناوين، الباقات، سرعة الخط، DNS، بيانات API محفظة شلن.
2. ارفع الملف إلى الراوتر ثم نفّذ: `/import file-name=elbasha_turnkey.rsc verbose=yes`
3. إعادة التشغيل آمنة: لا يحذف كروت `/ip hotspot user` ولا بروفايلاتها، ويستبدل فقط قواعده التي تحمل التعليق `ElBasha:`.

ما يفعله:
- بروفايل `ElBasha_Profile` باسم `elbasha.net` ودخول `http-chap,cookie` فقط (HTTP-PAP مغلق).
- DHCP مع `add-arp=yes` و`arp=reply-only` على الجسر، فلا يعمل آيبي مكتوب يدوياً.
- عزل المشتركين: `horizon=1` على منافذ الجسر، وقاعدة forward تمنع الحركة بين المشتركين.
- حجز آيبيهات ثابتة لأجهزة الأكسس بوينت والسيرفرات (`ebStatic`) وإعفاؤها من صفحة الدخول (Bypassed).
- DNS حماية العائلة (AdGuard Family) مفروض على الجميع، مع حجب DoT وخوادم DoH الشائعة.
- Walled Garden لمحفظة شلن (`qtbbank.com`)، ومستخدم API بصلاحيات `api,read,write` فقط عبر API-SSL ومقيد بعنوان السيرفر.
- باقات `eb-1M` و`eb-2M` و`eb-4M` بـ `shared-users=1`، والصلاحية تبدأ من أول دخول فعلي وتُحفظ في تعليق الكرت بالثانية.
- PCQ + Queue Tree بأربع أولويات: DNS/Ping/ألعاب/دردشة، ثم التصفح، ثم الباقي، ثم التحميلات الثقيلة والتحديثات.
- TTL=1 لمنع مشاركة النت من الهاتف، وFastTrack للأجهزة الثابتة فقط (FastTrack يعطّل الطوابير لو طُبق على المشتركين).
- نسخ احتياطي يومي للكروت واستهلاكها في ملفات الراوتر، وحذف يومي للكروت المنتهية، وإعادة تشغيل أسبوعية 4 فجراً، وWatchdog.
- حماية منافذ خادم الهوتسبوت `64872-64875`: حظر 15 دقيقة لمن يتجاوز 60 اتصالاً جديداً في الدقيقة أو 40 اتصالاً مفتوحاً.

## 🎫 طباعة الكروت

افتح [`vouchers/vouchers.html`](vouchers/vouchers.html) في المتصفح (يعمل بلا إنترنت؛ أبقِ `qrcode.min.js` بجواره):
- الصق أرقام الكروت أو ولّدها عشوائياً، واختر الباقة، ثم اطبع: 21 كرتاً في صفحة A4 مع خطوط قص.
- رمز QR يفتح `http://elbasha.net/login?v=<الرقم>` فتملأ صفحة الدخول الرقم وتدخل بتشفير CHAP تلقائياً.
- عند التوليد تظهر أوامر `/ip hotspot user add` جاهزة للصق في Terminal.

## 🔗 صفحة الترحيب

بعد الدخول تنقل صفحة `alogin.html` المشترك إلى صفحة الشبكة بعد 4 ثوانٍ. غيّر الرابط في كل القوالب بأمر واحد:
```bash
sed -i 's#https://www.facebook.com/elbasha.net#https://www.instagram.com/YOUR_PAGE#' themes/*/alogin.html alogin.html
```

---

## English

**El Basha Net (الباشا نت)** is a set of 8 MikroTik hotspot themes. Each `themes/<id>/` folder holds `login.html`, `status.html`, `alogin.html`, `logout.html` and `assets/logo.svg`. Pages are self-contained (inline CSS/JS, no external fonts or CDNs), so they load before the client has internet access.

- **Login:** HTTP-CHAP (MD5) with the router's `chap-id`/`chap-challenge`; MikroTik error messages are translated to Arabic.
- **Switch theme:** `./scripts/switch-theme.sh <id>` copies the four pages to the repository root.
- **Router setup:** edit "Block 0" variables in `scripts/elbasha_turnkey.rsc`, upload it, then run `/import file-name=elbasha_turnkey.rsc`. Non-destructive: existing hotspot users and profiles are kept.
- **Vouchers:** `vouchers/vouchers.html` prints 21 QR vouchers per A4 page; the QR opens `/login?v=CODE`, which signs in via CHAP.
- **Preview:** open `gallery.html` from a local web server to see every theme live.

---

## 📄 الترخيص (License)
مرخص تحت رخصة **[MIT License](LICENSE)** للاستخدام المفتوح.
