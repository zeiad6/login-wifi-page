# دليل تنصيب الباشا نت على ميكروتيك (RouterOS v7)

شرح كامل خطوة بخطوة لتجهيز شبكة هوتسبوت الباشا نت من الصفر. اقرأه كاملاً قبل البدء.

> ⚠️ **تحذير قبل التشغيل:** قواعد الحماية الجديدة تمنع إدارة الراوتر من الإنترنت (WAN). إن كنت تدير الراوتر عن بُعد، اضبط `ebAdminAllow` بعنوانك العام **قبل** التشغيل، وإلا فقدت الوصول عن بُعد (تبقى الإدارة من الشبكة الداخلية عبر الجسر).

---

## 0. المتطلبات

- راوتر ميكروتيك بنظام **RouterOS v7** (السكربت لا يعمل على v6).
- وصول إلى الراوتر عبر **WinBox** أو **WebFig** أو **SSH**.
- اتصال إنترنت على الراوتر (لتنزيل صفحات القالب والخطوط من GitHub).
- منفذ WAN واحد للإنترنت (`ether1` افتراضياً)، ومنافذ/أكسس بوينت للمشتركين.

---

## 1. خذ نسخة احتياطية أولاً (إلزامي)

في Terminal الراوتر:

```
/system backup save name=before-elbasha
/export show-sensitive file=before-elbasha
```

تنشأ `before-elbasha.backup` و`before-elbasha.rsc` في **Files**. نزّلهما إلى حاسوبك. إن حدث أي خطأ: `/system backup load name=before-elbasha`.

---

## 2. عدّل المتغيرات (البلوك 0)

افتح [`scripts/elbasha_turnkey.rsc`](../scripts/elbasha_turnkey.rsc) في محرر نصوص وعدّل "البلوك 0" أعلى الملف. أهم المتغيرات:

| المتغير | الوصف | مثال |
| :--- | :--- | :--- |
| `ebWan` | منفذ الإنترنت من المزوّد | `ether1` أو `pppoe-out1` |
| `ebBridge` | جسر المشتركين | `bridge` |
| `ebLanPorts` | منافذ المشتركين والأكسس بوينت | `{"ether2";"ether3"}` |
| `ebGw` | عنوان الراوتر للمشتركين | `10.10.0.1` |
| `ebDns` | DNS حماية العائلة | `94.140.14.15,94.140.15.16` |
| `ebTheme` | القالب | `luxury-gold` |
| `ebRepo` / `ebRef` | مستودع الصفحات وإصداره | ثبّت وسم إصدار بدل `main` |
| `ebPackages` | الباقات `{بروفايل;سرعة}` | `{{"eb-1M";"1M/1M"}}` |
| `ebLineDown`/`ebLineUp` | نحو 90% من سرعة الخط الحقيقية | `45M` / `9M` |
| `ebAllowPap` | PAP احتياطي للدخول | `true` |
| `ebAntiTether` | منع مشاركة النت (TTL=1) | `true` |
| `ebAdminAllow` | إدارة عن بُعد من عنوان واحد | `""` (مغلق) |
| `ebApiUser`/`ebApiPass`/`ebApiAllow` | مستخدم API لمحفظة شلن | اتركها فارغة لتخطيها |

راجع تعليقات كل متغير داخل الملف.

---

## 3. ارفع السكربت ونفّذه

1. في WinBox: **Files** → اسحب `elbasha_turnkey.rsc` إلى نافذة الملفات.
2. في **New Terminal**:

```
/import file-name=elbasha_turnkey.rsc verbose=yes
```

3. راقب السطور. يجب أن ينتهي بـ `ElBasha: setup finished`. أي سطر يبدأ بـ `ElBasha: could not ...` يشير إلى خطوة فشلت (غالباً تنزيل من الإنترنت أو شهادة).

> **إعادة التشغيل آمنة:** لا يحذف كروت `/ip hotspot user` ولا بروفايلاتها، ويستبدل فقط قواعده التي تحمل التعليق `ElBasha:`.

---

## 4. شهادة التنزيل من GitHub

السكربت ينزّل الصفحات بـ `check-certificate=yes`. إن ظهر خطأ شهادة:

- **RouterOS 7.19 فأحدث:**
  ```
  /certificate settings set builtin-trust-anchors=trusted
  ```
  ثم أعد تشغيل `/import`.
- **أقدم:** استورد شهادة الجذر التي يستخدمها `raw.githubusercontent.com` عبر `/certificate import`.

للتحقق من وصول الصفحات: **Files** → يجب أن ترى `flash/hotspot/login.html` وأخواتها ومجلد `flash/hotspot/fonts/`.

---

## 5. أنشئ خادم الهوتسبوت إن لم يكن موجوداً

السكربت يربط الهوتسبوت بالجسر إن وُجد. إن لم يكن لديك خادم هوتسبوت أصلاً، أنشئه مرة واحدة:

```
/ip hotspot setup
```

اختر الجسر `bridge`، والعناوين التي ضبطتها، ثم أعد تشغيل `/import` ليطبّق البروفايل والصفحات.

---

## 6. ولّد كروت الشحن

1. افتح [`vouchers/vouchers.html`](../vouchers/vouchers.html) في متصفح على حاسوبك (يعمل بلا إنترنت).
2. عدّل الفئات (الاسم، السرعة، السعر، الصلاحية، **مدة الاستخدام** `limit-uptime`، بروفايل الراوتر، اللون)، واختر تصميم الكرت.
3. اضغط **توليد وطباعة** لطباعة الكروت (21 في صفحة A4 مع خطوط قص).
4. انسخ أوامر `/ip hotspot user add` من قسم "أوامر إضافة الكروت" والصقها في Terminal الراوتر — تضيف الكروت ببروفايلاتها و`limit-uptime`.

> الصلاحية تأتي من `limit-uptime` على الكرت نفسه (مدة الاستخدام الفعلي)، يفرضها RouterOS داخلياً بلا أي كتابة على الفلاش.

---

## 7. تبديل القالب لاحقاً

على حاسوبك:

```
node scripts/switch-theme.mjs luxury-gold
```

ثم ادفع التغيير إلى المستودع، أو غيّر `ebTheme` في السكربت وأعد تشغيل `/import` على الراوتر.

---

## 8. التحقق بعد التنصيب

| تحقّق | الأمر |
| :--- | :--- |
| البروفايل والدخول | `/ip hotspot profile print` → `login-by=http-chap,...` |
| الصفحات نزلت | `/file print where name~"hotspot/login"` |
| قواعد الحماية | `/ip firewall filter print where comment~"ElBasha"` |
| الطوابير | `/queue tree print where comment~"ElBasha"` |
| الجدولة | `/system scheduler print where name~"eb-"` |
| كشف DHCP الدخيل | `/ip dhcp-server alert print` |

جرّب الاتصال بهاتف: افتح أي موقع → تظهر صفحة الباشا نت → أدخل رقم كرت → تتصفح.

---

## 9. حل المشكلات الشائعة

| العرض | السبب / الحل |
| :--- | :--- |
| `this script needs RouterOS v7` | الراوتر على v6. السكربت لـ v7 فقط. |
| فشل تنزيل الصفحات | شهادة GitHub — راجع القسم 4، أو تأكد من إنترنت الراوتر. |
| الصفحة بلا خطوط عربية جميلة | ملفات `fonts/*.woff2` لم تنزل؛ أعد `/import` بعد إصلاح الشهادة. |
| "رقم الكرت غير صحيح" دائماً | راجع `login-by`؛ إن كانت أجهزة قديمة تفشل، اجعل `ebAllowPap true`. |
| فقدت إدارة الراوتر عن بُعد | قواعد WAN تمنعها. ادخل من الشبكة الداخلية واضبط `ebAdminAllow`. |
| مشترك يشارك النت للهاتف | `ebAntiTether true` (TTL=1). إن كسر خدمة، القواعد تستثني IPsec/IKE/ICMP. |
| خطأ DNS مشفّر في المتصفح | `ebBlockDoH true` يرفض DoT/DoH بسرعة فيرجع المتصفح لـ DNS الشبكة. |
| الراوتر يعيد التشغيل كل ~20 دقيقة | خط المزوّد منقطع والـ Watchdog ينعشه. حلّ انقطاع الخط. |

---

## 10. استعادة الوضع السابق

```
/system backup load name=before-elbasha
```

أو لحذف إعدادات الباشا نت يدوياً، احذف ما يحمل التعليق `ElBasha:` من `/ip firewall filter`, `nat`, `mangle`, `/queue tree`, `/system scheduler`, و`/ip hotspot walled-garden`.
