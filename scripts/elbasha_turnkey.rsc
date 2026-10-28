# ==============================================================================
#  الباشا نت | EL BASHA NET — سكربت تجهيز الهوتسبوت الكامل (Turnkey)
#  RouterOS v7 فقط.
#
#  طريقة التشغيل:
#    1) عدّل المتغيرات في "البلوك 0" أدناه.
#    2) ارفع الملف إلى الراوتر (Files) ثم نفّذ في Terminal:
#         /import file-name=elbasha_turnkey.rsc verbose=yes
#
#  آمن لإعادة التشغيل (Non-destructive):
#    - لا يحذف ولا يصفّر أي كرت في /ip hotspot user ولا أي بروفايل موجود.
#    - كل عنصر يُبحث عنه أولاً: إن وُجد يُعدَّل، وإن لم يوجد يُضاف.
#    - قواعد الجدار الناري والطوابير التي يضيفها السكربت تحمل التعليق "ElBasha:"
#      وتُستبدل عند كل تشغيل، فلا تتكرر. قواعدك الأخرى لا تُمس.
#
#  نصيحة: خذ نسخة احتياطية قبل أول تشغيل:
#    /system backup save name=before-elbasha
#    /export show-sensitive file=before-elbasha
# ==============================================================================


# ==============================================================================
#  البلوك 0: المتغيرات العامة (Global Variables) — عدّل هنا فقط
# ==============================================================================

# ---- الهوية ----
# اسم الراوتر كما يظهر في Winbox
:global ebName "ElBasha-Net"
# نطاق صفحة الدخول: يكتبه العميل في المتصفح، ويُطبع في رمز QR على الكرت
:global ebDnsName "elbasha.net"
# المنطقة الزمنية (ضرورية لحساب صلاحية الكروت بدقة)
:global ebTimeZone "Asia/Aden"

# ---- المنافذ ----
# منفذ الإنترنت القادم من المزوّد (ether1، أو pppoe-out1 إن كان الخط PPPoE)
:global ebWan "ether1"
# الجسر الذي يعمل عليه الهوتسبوت. "bridge" هو اسم الجسر في الإعداد الافتراضي لميكروتك
:global ebBridge "bridge"
# المنافذ المتصلة بأجهزة الأكسس بوينت والمشتركين (تُضاف إلى الجسر إن لم تكن في جسر آخر)
:global ebLanPorts {"ether2";"ether3";"ether4";"ether5"}

# ---- عناوين الشبكة ----
# عنوان الراوتر داخل شبكة المشتركين
:global ebGw "10.10.0.1"
# الشبكة وطول القناع: 10.10.0.0/22 = نحو 1000 عنوان
:global ebNet "10.10.0.0"
:global ebPrefix "22"
# نطاق توزيع DHCP. العناوين 10.10.0.2 - 10.10.0.49 محجوزة للأجهزة الثابتة (البلوك 4)
:global ebPoolName "eb-pool"
:global ebPoolRange "10.10.0.50-10.10.3.250"
:global ebLeaseTime "1h"
# true = الراوتر لا يتعامل إلا مع من أخذ عنوانه من DHCP (يمنع تزوير الآيبي يدوياً)
# تحذير: أي جهاز بآيبي يدوي على الجسر (حتى جهازك) سيفقد الاتصال. ادخل عبر Winbox بالـ MAC عند الحاجة.
:global ebArpReplyOnly true

# ---- الأجهزة الثابتة (أكسس بوينت، سيرفرات) ----
# كل سطر: {"MAC";"IP";"الوصف"} — تُحجز لها آيبيهات ثابتة وتُعفى من صفحة الدخول (Bypassed)
# مثال:
# :global ebStatic {{"AA:BB:CC:00:00:01";"10.10.0.10";"AP-Roof"};{"AA:BB:CC:00:00:02";"10.10.0.11";"AP-Street"}}
:global ebStatic [:toarray ""]

# ---- DNS حماية العائلة ----
# AdGuard Family: يحظر المواقع الإباحية والضارة وإعلانات النوافذ المنبثقة
# بديل بلا حظر إعلانات: Cloudflare Family "1.1.1.3,1.0.0.3"
:global ebDns "94.140.14.15,94.140.15.16"

# ---- الهوتسبوت ----
:global ebHsName "eb-hotspot"
:global ebHsProfile "ElBasha_Profile"
# مجلد صفحات الدخول. الأجهزة التي لا تملك مجلد flash تستخدم "hotspot"
:global ebHtmlDir "flash/hotspot"
# تنزيل صفحات القالب من GitHub (true/false)
:global ebDownloadTheme true
# القالب: luxury-gold | oled-matrix | cyberpunk | swiss-minimal | aurora-glass | neo-brutalist | spatial-glass | nordic-studio
:global ebTheme "luxury-gold"
:global ebRepo "https://raw.githubusercontent.com/zeiad6/login-wifi-page"
# ثبّت وسم إصدار أو commit بدل main حتى لا يتغير ما يعرضه الراوتر دون علمك
:global ebRef "main"

# ---- الباقات ----
# كل سطر: {"اسم البروفايل";"سرعة رفع/تحميل"}. السرعة بصيغة رفع/تحميل، مثل "512k/2M".
# الصلاحية لم تعد تُحسب بتعديل تعليق الكرت (يتلف الفلاش)؛ صارت limit-uptime على الكرت نفسه:
# يفرضها RouterOS داخلياً بلا أي كتابة على الفلاش أثناء التشغيل. اضبطها عند توليد الكروت
# في vouchers.html (خانة "مدة الاستخدام")، أو يدوياً: limit-uptime=1d
:global ebPackages {{"eb-1M";"1M/1M"};{"eb-2M";"1M/2M"};{"eb-4M";"2M/4M"}}
# السماح بـ PAP كخيار احتياطي. القالب يستعمل CHAP تلقائياً متى أرسل الراوتر chap-id،
# ويرجع إلى PAP فقط إن غاب. تحذير: PAP يرسل رقم الكرت نصاً مكشوفاً على بوابة HTTP.
# اتركه true لتجنب فشل الدخول على أجهزة/متصفحات لا تكمل CHAP؛ اجعله false لأقصى تشفير.
:global ebAllowPap true

# ---- حدود حماية صفحة الدخول (Anti-Brute Force) ----
# الهواتف الحديثة تفتح عشرات الاتصالات فور الاتصال (خلفيات، خطوط، تحديثات). حدود واسعة
# تتجنب حظر المشتركين الشرعيين. الحماية الحقيقية من التخمين: كروت 10 أرقام أو أكثر.
:global ebMaxOpenConn 150
:global ebNewPerMin 150
:global ebNewBurst 300

# ---- منع مشاركة النت (Anti-Tethering) ----
# true = TTL=1 على الحزم النازلة للمشترك، فلا تعمل نقطة الاتصال من هاتفه. لا يؤثر على
# تصفح الهاتف نفسه. مكالمات الواي فاي وفحوص النظام (IPsec/IKE/ICMP) مستثناة.
:global ebAntiTether true

# ---- DNS المشفر ----
# true = رفض DoT (853) وDoH (على خوادمها المعروفة) بـ tcp-reset سريع، فيرجع المتصفح/النظام
# فوراً إلى DNS الشبكة بلا تعليق أو خطأ مرعب. false = السماح به.
:global ebBlockDoH true

# ---- إدارة الراوتر من الإنترنت ----
# عنوان (أو شبكة) يُسمح له بالوصول لـ Winbox/SSH من جهة WAN للصيانة عن بُعد. اتركه ""
# لإغلاق كل إدارة من الإنترنت (الإدارة من الشبكة الداخلية فقط). مثال: "41.x.x.x"
:global ebAdminAllow ""

# ---- سرعة الخط الكلية (لنظام الأولويات) ----
# ضع نحو 90% من السرعة الحقيقية للخط، وإلا لن تعمل الأولويات لأن الطابور لن يمتلئ أبداً
:global ebLineDown "45M"
:global ebLineUp "9M"
# منافذ UDP للألعاب (ببجي، EA FC/فيفا...). اتصال UDP يتجاوز 3Mbps يُخفَّض تلقائياً
:global ebGameUdp "3659,9000-20000"

# ---- محفظة شلن (بنك القطيبي) ----
# نطاقات مسموحة قبل تسجيل الدخول (يقبل * للنطاقات الفرعية)
:global ebShillingHosts {"qtbbank.com";"*.qtbbank.com"}
# أسماء كاملة بلا * لتطبيق الهاتف (HTTPS). أضف ما تراه في /ip dns cache أثناء فتح التطبيق
:global ebShillingAppHosts {"qtbbank.com";"ext.qtbbank.com"}
# مستخدم API لسيرفر الدفع. اتركه فارغاً لتخطي إنشائه.
# كلمة سر قوية (12 حرفاً على الأقل)، وعنوان السيرفر الوحيد المسموح له بالاتصال
:global ebApiUser "shilling-api"
:global ebApiPass ""
:global ebApiAllow ""

# ---- صفحة المطوّر ----
# رابط "تم التطوير بواسطة zeidexsoft" أسفل الصفحات يفتح قبل تسجيل الدخول. اتركه "" لإغلاقه
:global ebDevHost "zeidexlink.zeidexsoft.com"

# ---- الصيانة ----
:global ebBackupTime "02:30:00"
:global ebCleanupTime "03:00:00"
:global ebRebootTime "04:00:00"
:global ebWatchIp "8.8.8.8"


# ==============================================================================
#  فحص الإصدار: السكربت يعتمد على صيغة قوائم RouterOS v7
# ==============================================================================
:if ([:pick [/system resource get version] 0 1] != "7") do={
    :error "ElBasha: this script needs RouterOS v7"
}
:put "ElBasha: starting setup"


# ==============================================================================
#  البلوك 1: الهوية والوقت
# ==============================================================================

/system identity set name=$ebName

# الساعة يجب أن تكون صحيحة، فصلاحية الكروت تُحسب منها بالدقيقة
/system clock set time-zone-autodetect=no time-zone-name=$ebTimeZone
/system ntp client set enabled=yes servers=time.cloudflare.com,pool.ntp.org


# ==============================================================================
#  البلوك 4أ: الجسر، العناوين، DHCP (الجزء الأساسي من الشبكة)
# ==============================================================================

# ---- الجسر ----
/interface bridge
:if ([:len [find where name=$ebBridge]] = 0) do={
    add name=$ebBridge comment="ElBasha: hotspot bridge"
}

# ---- منافذ الجسر + العزل ----
# horizon=1 على كل المنافذ: الجسر لا يمرر الإطارات بين منفذين لهما نفس الرقم،
# فلا يرى مشترك على أكسس بوينت مشتركاً على أكسس بوينت آخر (يحجب Netcut وسحب البيانات).
# ملاحظة: horizon يعطّل تسريع العتاد (HW offload) لهذه المنافذ على أغلب الأجهزة.
/interface bridge port
:foreach p in=$ebLanPorts do={
    :if ([:len [/interface find where name=$p]] = 0) do={
        :put ("ElBasha: port " . $p . " not found, skipped")
    } else={
        :local bp [find where interface=$p]
        :if ([:len $bp] = 0) do={
            add bridge=$ebBridge interface=$p horizon=1 comment="ElBasha: client port"
        } else={
            :if ([get ($bp->0) bridge] = $ebBridge) do={
                set ($bp->0) horizon=1
            } else={
                :put ("ElBasha: " . $p . " belongs to bridge " . [get ($bp->0) bridge] . ", left unchanged")
            }
        }
    }
}

# العزل داخل نفس نقطة الوصول اللاسلكية في الراوتر نفسه (إن وُجدت).
# أجهزة الأكسس بوينت الخارجية: فعّل فيها Client/AP Isolation يدوياً.
:do { /interface wireless set [find] default-forwarding=no } on-error={}
:do { /interface wifi datapath set [find] client-isolation=yes } on-error={}

# ---- عنوان الراوتر ----
/ip address
:if ([:len [find where address=($ebGw . "/" . $ebPrefix)]] = 0) do={
    add address=($ebGw . "/" . $ebPrefix) interface=$ebBridge comment="ElBasha: gateway"
}

# ---- IP Pool ----
/ip pool
:if ([:len [find where name=$ebPoolName]] = 0) do={
    add name=$ebPoolName ranges=$ebPoolRange
} else={
    set [find where name=$ebPoolName] ranges=$ebPoolRange
}

# ---- شبكة DHCP: البوابة وDNS = الراوتر نفسه (ليمر الجميع عبر DNS العائلة) ----
/ip dhcp-server network
:if ([:len [find where address=($ebNet . "/" . $ebPrefix)]] = 0) do={
    add address=($ebNet . "/" . $ebPrefix) gateway=$ebGw dns-server=$ebGw comment="ElBasha: clients"
} else={
    set [find where address=($ebNet . "/" . $ebPrefix)] gateway=$ebGw dns-server=$ebGw
}

# ---- خادم DHCP مع Add ARP For Leases ----
# add-arp=yes: الراوتر يضيف ARP ثابتاً لكل عنوان يوزعه. مع arp=reply-only على الجسر
# لا يعمل إلا من أخذ عنوانه من DHCP، فلا ينفع تزوير الآيبي أو كتابته يدوياً.
/ip dhcp-server
:if ([:len [find where interface=$ebBridge]] = 0) do={
    add name=eb-dhcp interface=$ebBridge address-pool=$ebPoolName lease-time=$ebLeaseTime add-arp=yes disabled=no
} else={
    set [find where interface=$ebBridge] address-pool=$ebPoolName lease-time=$ebLeaseTime add-arp=yes disabled=no
}
:global ebDhcpName [/ip dhcp-server get ([/ip dhcp-server find where interface=$ebBridge]->0) name]

:if ($ebArpReplyOnly) do={
    /interface bridge set [find where name=$ebBridge] arp=reply-only
}

# ---- كشف خوادم DHCP الدخيلة (Rogue DHCP Detection) ----
# ينبّه في السجل عند ظهور خادم DHCP آخر على الجسر (يسبب تعارض آيبيهات وسرقة جلسات).
# خادم الراوتر نفسه ليس دخيلاً. راقب /log أو /ip dhcp-server alert عند التنبيه.
/ip dhcp-server alert
:local alertMsg ":log warning \"ElBasha: ROGUE DHCP server detected on the hotspot bridge - check /ip dhcp-server alert\""
:if ([:len [find where interface=$ebBridge]] = 0) do={
    add interface=$ebBridge alert-timeout=1h disabled=no comment="ElBasha: rogue DHCP detection" on-alert=$alertMsg
} else={
    set [find where interface=$ebBridge] alert-timeout=1h disabled=no on-alert=$alertMsg
}


# ==============================================================================
#  البلوك 4ب: DNS حماية العائلة (Family Shield)
# ==============================================================================

# الراوتر يسأل خوادم العائلة فقط، ولا يأخذ DNS المزوّد
/ip dns set servers=$ebDns allow-remote-requests=yes
:do { /ip dhcp-client set [find] use-peer-dns=no } on-error={}


# ==============================================================================
#  البلوك 5أ: الهوتسبوت — البروفايل الرئيسي والخادم
# ==============================================================================

# login-by: CHAP أولاً (مشفّر)، وcookie لتذكّر الجهاز. PAP يُضاف فقط إن فعّلت ebAllowPap،
# ليكمل الدخول حين لا يرسل الراوتر chap-id فيرجع القالب تلقائياً إلى PAP.
:global ebLoginBy "http-chap,cookie"
:if ($ebAllowPap) do={ :set ebLoginBy "http-chap,http-pap,cookie" }
/ip hotspot profile
:if ([:len [find where name=$ebHsProfile]] = 0) do={ add name=$ebHsProfile }
set [find where name=$ebHsProfile] hotspot-address=$ebGw dns-name=$ebDnsName \
    html-directory=$ebHtmlDir login-by=$ebLoginBy http-cookie-lifetime=1d

# خادم هوتسبوت واحد على الجسر: إن وُجد يُربط بالبروفايل الجديد فقط
/ip hotspot
:if ([:len [find where interface=$ebBridge]] = 0) do={
    add name=$ebHsName interface=$ebBridge profile=$ebHsProfile disabled=no
} else={
    set [find where interface=$ebBridge] profile=$ebHsProfile
}


# ==============================================================================
#  البلوك 6ب: بروفايلات الباقات (Shared Users = 1)
# ==============================================================================

# rate-limit يحدد سقف سرعة كل كرت، وshared-users=1 يمنع تشغيل الكرت على جهازين معاً.
# لا on-login/on-logout ولا كتابة على التعليقات: الصلاحية تأتي من limit-uptime على الكرت
# نفسه (يفرضها RouterOS داخلياً)، فلا استهلاك للفلاش أثناء كل دخول وخروج.
# البروفايلات الموجودة مسبقاً (وكروتها) لا تُمس؛ هذه بروفايلات جديدة تبدأ بـ eb-
/ip hotspot user profile
:foreach pk in=$ebPackages do={
    :local n ($pk->0)
    :local rl ($pk->1)
    :if ([:len [find where name=$n]] = 0) do={ add name=$n }
    set [find where name=$n] shared-users=1 rate-limit=$rl keepalive-timeout=2m status-autorefresh=5m
}


# ==============================================================================
#  البلوك 5ب: Walled Garden لمحفظة شلن (الشراء قبل تسجيل الدخول)
# ==============================================================================

# حذف استثناءات CDN القديمة (الصفحات لا تحتاجها) واستثناءات هذا السكربت السابقة
/ip hotspot walled-garden remove [find where comment~"^Allow (Tailwind|Google)" or comment~"^ElBasha:"]
/ip hotspot walled-garden ip remove [find where comment~"^ElBasha:"]

# walled-garden: لصفحات الويب (HTTP). walled-garden ip: لتطبيق الهاتف (HTTPS وAPI)
:foreach h in=$ebShillingHosts do={
    /ip hotspot walled-garden add dst-host=$h action=allow comment="ElBasha: Shilling wallet"
}
:foreach h in=$ebShillingAppHosts do={
    /ip hotspot walled-garden ip add dst-host=$h action=accept comment="ElBasha: Shilling app"
}
:if ([:len $ebDevHost] > 0) do={
    /ip hotspot walled-garden add dst-host=$ebDevHost action=allow comment="ElBasha: developer page"
    /ip hotspot walled-garden ip add dst-host=$ebDevHost action=accept comment="ElBasha: developer page"
}


# ==============================================================================
#  البلوك 1ب: تنزيل صفحات القالب (الباشا نت)
# ==============================================================================

# check-certificate=yes يحتاج شهادة جذر موثوقة في الراوتر:
#   v7.19 فما فوق: /certificate settings set builtin-trust-anchors=trusted
:if ($ebDownloadTheme) do={
    :foreach f in={"login.html";"status.html";"alogin.html";"logout.html"} do={
        :do {
            /tool fetch url=($ebRepo . "/" . $ebRef . "/themes/" . $ebTheme . "/" . $f) \
                dst-path=($ebHtmlDir . "/" . $f) check-certificate=yes
        } on-error={ :put ("ElBasha: could not download " . $f . " (check certificates / internet)") }
    }
    # الخطوط العربية: يخدمها الراوتر نفسه، فتظهر قبل أن يملك المشترك إنترنت (نحو 170KB)
    :foreach f in={"eb-kufi-400.woff2";"eb-kufi-600.woff2";"eb-kufi-800.woff2";"eb-naskh-400.woff2";"eb-naskh-700.woff2"} do={
        :do {
            /tool fetch url=($ebRepo . "/" . $ebRef . "/fonts/" . $f) \
                dst-path=($ebHtmlDir . "/fonts/" . $f) check-certificate=yes
        } on-error={ :put ("ElBasha: could not download font " . $f) }
    }
}


# ==============================================================================
#  البلوك 4ج: الأجهزة الثابتة (Static Leases + IP Bindings Bypassed)
# ==============================================================================

# لكل جهاز: حجز آيبي ثابت في DHCP، وإعفاء من صفحة الدخول، وإضافته لقائمة eb-trusted
# (قائمة الأجهزة الموثوقة التي تُسرَّع بـ FastTrack في البلوك 6د)
/ip firewall address-list remove [find where list="eb-trusted" and comment~"^ElBasha:"]
:foreach d in=$ebStatic do={
    :local mac ($d->0)
    :local ip ($d->1)
    :local note ($d->2)

    /ip dhcp-server lease
    :local l [find where mac-address=$mac]
    :if ([:len $l] = 0) do={
        add mac-address=$mac address=$ip server=$ebDhcpName comment=("ElBasha: " . $note)
    } else={
        :if ([get ($l->0) dynamic]) do={ make-static ($l->0) }
        set [find where mac-address=$mac] address=$ip server=$ebDhcpName comment=("ElBasha: " . $note)
    }

    /ip hotspot ip-binding
    :if ([:len [find where mac-address=$mac]] = 0) do={
        add mac-address=$mac address=$ip type=bypassed comment=("ElBasha: " . $note)
    } else={
        set [find where mac-address=$mac] address=$ip type=bypassed
    }

    /ip firewall address-list add list=eb-trusted address=$ip comment=("ElBasha: " . $note)
}


# ==============================================================================
#  البلوك 4د + 6: الجدار الناري (حماية، عزل، DNS، FastTrack)
# ==============================================================================

# قواعد هذا السكربت (وقواعد الإصدار القديم Zeidex) تُحذف ثم تُضاف من جديد، فلا تتكرر
/ip firewall filter remove [find where comment~"^ElBasha:" or comment~"^Zeidex:"]
/ip firewall nat remove [find where comment~"^ElBasha:"]
/ip firewall mangle remove [find where comment~"^ElBasha:"]
/ip firewall address-list remove [find where (list="eb-chat" or list="eb-doh") and comment~"^ElBasha:"]

# ---- قوائم العناوين ----
# Telegram: نطاقاته الرسمية (core.telegram.org/resources/cidr.txt)
:foreach a in={"91.108.4.0/22";"91.108.8.0/22";"91.108.12.0/22";"91.108.16.0/22";"91.108.20.0/22";"91.108.56.0/22";"95.161.64.0/20";"149.154.160.0/20";"185.76.151.0/24"} do={
    /ip firewall address-list add list=eb-chat address=$a comment="ElBasha: Telegram"
}
# خوادم DNS-over-HTTPS الشائعة: تُحجب على 443 حتى لا يتجاوز أحد DNS العائلة
:foreach a in={"8.8.8.8";"8.8.4.4";"1.1.1.1";"1.0.0.1";"9.9.9.9";"149.112.112.112";"208.67.222.222";"208.67.220.220"} do={
    /ip firewall address-list add list=eb-doh address=$a comment="ElBasha: DoH resolver"
}

/ip firewall filter

# ---- حماية صفحة الدخول من التخمين والإغراق ----
# الهوتسبوت يحوّل كل طلبات :80/:443 إلى خادمه على المنافذ 64872-64875.
# الحدود واسعة (ebMaxOpenConn/ebNewPerMin) لأن الهواتف تفتح عشرات الاتصالات المتزامنة فور
# الاتصال. الحماية الحقيقية من التخمين: كروت بـ 10 أرقام أو أكثر.
add chain=input protocol=tcp dst-port=64872-64875 src-address-list=eb-blacklist \
    action=drop comment="ElBasha: drop banned clients"
add chain=input protocol=tcp dst-port=64872-64875 connection-state=new \
    connection-limit=($ebMaxOpenConn . ",32") action=add-src-to-address-list \
    address-list=eb-blacklist address-list-timeout=15m \
    comment=("ElBasha: more than " . $ebMaxOpenConn . " open connections from one IP -> ban 15m")
add chain=input protocol=tcp dst-port=64872-64875 connection-state=new \
    action=jump jump-target=eb-rate comment="ElBasha: check new connection rate"
add chain=eb-rate dst-limit=($ebNewPerMin . "," . $ebNewBurst . ",src-address/1m") action=return \
    comment=("ElBasha: allow up to " . $ebNewPerMin . " new connections/min per IP (burst " . $ebNewBurst . ")")
add chain=eb-rate action=add-src-to-address-list address-list=eb-blacklist \
    address-list-timeout=15m comment="ElBasha: over the rate -> ban 15m"
add chain=eb-rate action=drop comment="ElBasha: drop the excess connection"

# ---- حماية الراوتر نفسه من الإنترنت (البلوك 8) ----
# يُسقط الحزم التالفة، ويمنع الوصول من WAN إلى بوابة الدخول وإلى إدارة الراوتر
# (Winbox/SSH/Telnet/FTP/API/الويب). القواعد مقيّدة بـ in-interface=WAN فقط،
# فإدارة الراوتر من الشبكة الداخلية تبقى تعمل ولا يُحبس المشرف.
add chain=input connection-state=invalid action=drop comment="ElBasha: drop invalid"
add chain=input in-interface=$ebWan protocol=icmp limit=10/1s,5:packet \
    action=accept comment="ElBasha: limited ICMP from WAN"
# السماح بالإدارة عن بُعد من عنوان واحد فقط إن حُدّد
:if ([:len $ebAdminAllow] > 0) do={
    add chain=input in-interface=$ebWan src-address=$ebAdminAllow protocol=tcp dst-port=8291,22 \
        action=accept comment="ElBasha: remote admin from trusted address"
}
# بوابة الدخول وخدمات الإدارة ممنوعة من الإنترنت
add chain=input in-interface=$ebWan protocol=tcp dst-port=64872-64875 action=drop comment="ElBasha: no hotspot portal from WAN"
add chain=input in-interface=$ebWan protocol=tcp dst-port=8291,22,23,21,8728,80,443 action=drop comment="ElBasha: no management from WAN"

# ---- DNS الراوتر لا يُفتح للإنترنت (حتى لا يُستغل في هجمات DNS Amplification) ----
add chain=input in-interface=$ebWan protocol=udp dst-port=53 action=drop comment="ElBasha: no public DNS (udp)"
add chain=input in-interface=$ebWan protocol=tcp dst-port=53 action=drop comment="ElBasha: no public DNS (tcp)"

# ---- API-SSL لسيرفر محفظة شلن فقط ----
:if ([:len $ebApiAllow] > 0) do={
    add chain=input src-address=$ebApiAllow protocol=tcp dst-port=8729 action=accept comment="ElBasha: Shilling API-SSL"
}

# ---- عزل المشتركين على مستوى IP ----
# يكمّل horizon في الجسر: يمنع أي حركة بين مشتركَين تمر عبر الراوتر.
# الأجهزة الموثوقة (eb-trusted) مستثناة حتى يبقى الوصول إليها ممكناً.
add chain=forward src-address=($ebNet . "/" . $ebPrefix) dst-address=($ebNet . "/" . $ebPrefix) \
    src-address-list=!eb-trusted dst-address-list=!eb-trusted action=drop comment="ElBasha: client isolation"

# ---- منع تجاوز DNS العائلة (برفض سريع لا حظر صامت) ----
# reject بـ tcp-reset/icmp بدل drop: يفشل اتصال DNS المشفّر فوراً فيرجع المتصفح والنظام
# تلقائياً إلى DNS الشبكة (المُعاد توجيهه في NAT إلى AdGuard)، بلا تعليق طويل ولا خطأ مرعب.
:if ($ebBlockDoH) do={
    add chain=forward src-address=($ebNet . "/" . $ebPrefix) protocol=tcp dst-port=853 \
        action=reject reject-with=tcp-reset comment="ElBasha: reject DNS-over-TLS (fast fallback)"
    add chain=forward src-address=($ebNet . "/" . $ebPrefix) protocol=udp dst-port=853 \
        action=reject reject-with=icmp-port-unreachable comment="ElBasha: reject DNS-over-QUIC (fast fallback)"
    add chain=forward src-address=($ebNet . "/" . $ebPrefix) dst-address-list=eb-doh protocol=tcp dst-port=443 \
        action=reject reject-with=tcp-reset comment="ElBasha: reject DoH tcp (fast fallback)"
    add chain=forward src-address=($ebNet . "/" . $ebPrefix) dst-address-list=eb-doh protocol=udp dst-port=443 \
        action=reject reject-with=icmp-port-unreachable comment="ElBasha: reject DoH quic (fast fallback)"
}

# ---- FastTrack للبيانات الموثوقة فقط ----
# FastTrack يتخطى Mangle والطوابير، فلو طُبق على المشتركين لتعطلت السرعات والأولويات.
# لذلك يُطبق على الأجهزة الثابتة (eb-trusted) فقط، وتُعطَّل قاعدة FastTrack العامة الافتراضية.
add chain=forward connection-state=established,related src-address-list=eb-trusted \
    action=fasttrack-connection hw-offload=yes comment="ElBasha: fasttrack trusted (from)"
add chain=forward connection-state=established,related dst-address-list=eb-trusted \
    action=fasttrack-connection hw-offload=yes comment="ElBasha: fasttrack trusted (to)"
add chain=forward connection-state=established,related action=accept comment="ElBasha: accept established"

:foreach r in=[find where action=fasttrack-connection and !(comment~"^ElBasha")] do={
    set $r disabled=yes comment=("ElBasha-disabled (breaks hotspot queues): " . [get $r comment])
}

# قواعد السكربت تنتقل إلى أعلى القائمة (بعد قواعد الهوتسبوت الديناميكية) لتسبق أي drop عام
:local anchor [find where !dynamic and !(comment~"^ElBasha:")]
:if ([:len $anchor] > 0) do={
    move [find where comment~"^ElBasha:"] destination=($anchor->0)
}

# ---- NAT ----
/ip firewall nat
# أي طلب DNS من المشتركين يُعاد توجيهه إلى الراوتر (DNS العائلة) حتى لو غيّر المشترك DNS جهازه
add chain=dstnat src-address=($ebNet . "/" . $ebPrefix) protocol=udp dst-port=53 \
    action=redirect to-ports=53 comment="ElBasha: force family DNS (udp)"
add chain=dstnat src-address=($ebNet . "/" . $ebPrefix) protocol=tcp dst-port=53 \
    action=redirect to-ports=53 comment="ElBasha: force family DNS (tcp)"
add chain=srcnat src-address=($ebNet . "/" . $ebPrefix) out-interface=$ebWan \
    action=masquerade comment="ElBasha: masquerade clients"


# ==============================================================================
#  البلوك 6ج: Mangle — تصنيف الحركة للأولويات + منع مشاركة النت (TTL)
# ==============================================================================

# أربع فئات (connection-mark):
#   eb-prio  أولوية 1: DNS، ICMP (Ping)، الألعاب، واتساب وتليجرام
#   eb-web   أولوية 3: تصفح الويب (أول 5MB من كل اتصال)
#   eb-other أولوية 5: كل ما سبق غير ذلك
#   eb-bulk  أولوية 8: التحميلات الثقيلة وتحديثات الأنظمة
# كل قاعدة لاحقة تستبدل علامة السابقة (passthrough=yes)، فالترتيب مهم.
/ip firewall mangle
:local lan $ebBridge

# --- عند بداية كل اتصال ---
add chain=prerouting in-interface=$lan connection-state=new action=mark-connection \
    new-connection-mark=eb-other passthrough=yes comment="ElBasha: QoS default"
add chain=prerouting in-interface=$lan connection-state=new protocol=tcp dst-port=80,443 \
    action=mark-connection new-connection-mark=eb-web passthrough=yes comment="ElBasha: QoS web"
add chain=prerouting in-interface=$lan connection-state=new protocol=udp dst-port=443 \
    action=mark-connection new-connection-mark=eb-web passthrough=yes comment="ElBasha: QoS web QUIC"
add chain=prerouting in-interface=$lan connection-state=new protocol=udp dst-port=53 \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS DNS udp"
add chain=prerouting in-interface=$lan connection-state=new protocol=tcp dst-port=53 \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS DNS tcp"
add chain=prerouting in-interface=$lan connection-state=new protocol=icmp \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS ping"
add chain=prerouting in-interface=$lan connection-state=new protocol=udp dst-port=$ebGameUdp \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS games"
add chain=prerouting in-interface=$lan connection-state=new dst-address-list=eb-chat \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS Telegram"
add chain=prerouting in-interface=$lan connection-state=new protocol=tcp dst-port=5222 \
    action=mark-connection new-connection-mark=eb-prio passthrough=yes comment="ElBasha: QoS WhatsApp chat port"

# --- حسب اسم الموقع في مصافحة TLS (أول 20KB من الاتصال فقط لتوفير المعالج) ---
:foreach h in={"*.whatsapp.net";"*.whatsapp.com";"*.telegram.org"} do={
    add chain=prerouting in-interface=$lan connection-mark=eb-web connection-bytes=0-20000 \
        protocol=tcp tls-host=$h action=mark-connection new-connection-mark=eb-prio \
        passthrough=yes comment="ElBasha: QoS chat by name"
}
:foreach h in={"*.windowsupdate.com";"*.delivery.mp.microsoft.com";"*.gvt1.com";"*.swcdn.apple.com";"*.steamcontent.com"} do={
    add chain=prerouting in-interface=$lan connection-mark=eb-web connection-bytes=0-20000 \
        protocol=tcp tls-host=$h action=mark-connection new-connection-mark=eb-bulk \
        passthrough=yes comment="ElBasha: QoS system updates"
}

# --- التحميلات الثقيلة: اتصال تجاوز 5MB ينزل لأدنى أولوية ---
add chain=prerouting in-interface=$lan connection-mark=eb-web connection-bytes=5000000-0 \
    action=mark-connection new-connection-mark=eb-bulk passthrough=yes comment="ElBasha: QoS heavy web download"
add chain=prerouting in-interface=$lan connection-mark=eb-other connection-bytes=5000000-0 \
    action=mark-connection new-connection-mark=eb-bulk passthrough=yes comment="ElBasha: QoS heavy other download"
# UDP في فئة الألعاب بسرعة أعلى من 3Mbps ليس لعبة (غالباً تورنت): ينزل لأدنى أولوية
add chain=prerouting in-interface=$lan connection-mark=eb-prio protocol=udp \
    connection-rate=3000000-4294967295 action=mark-connection new-connection-mark=eb-bulk \
    passthrough=yes comment="ElBasha: QoS UDP flood out of prio"

# --- علامات الحزم: -up للرفع و -dn للتحميل ---
:foreach c in={"eb-prio";"eb-web";"eb-other";"eb-bulk"} do={
    add chain=forward in-interface=$lan connection-mark=$c action=mark-packet \
        new-packet-mark=($c . "-up") passthrough=no comment="ElBasha: QoS packet up"
    add chain=forward out-interface=$lan connection-mark=$c action=mark-packet \
        new-packet-mark=($c . "-dn") passthrough=no comment="ElBasha: QoS packet down"
    add chain=output out-interface=$lan connection-mark=$c action=mark-packet \
        new-packet-mark=($c . "-dn") passthrough=no comment="ElBasha: QoS packet down (router)"
}

# --- منع مشاركة النت (Anti-Tethering) ---
# كل حزمة تصل للمشترك بـ TTL=1. الهاتف ينقصها 1 عند تمريرها لجهاز آخر فتصبح 0 وتُرمى،
# فنقطة الاتصال من الهاتف لا تعمل، بينما الهاتف نفسه يتصفح طبيعياً.
# استثناءات: مكالمات الواي فاي (IPsec ESP وIKE على 500/4500) وفحوص ICMP الأمنية
# لا تُمسّ، حتى لا تنكسر خدمات أندرويد/iOS الأساسية. action=accept في mangle يوقف
# بقية سلسلة postrouting لهذه الحزمة فلا تصلها قاعدة TTL.
:if ($ebAntiTether) do={
    add chain=postrouting out-interface=$lan protocol=ipsec-esp action=accept \
        comment="ElBasha: keep TTL for IPsec (Wi-Fi calling)"
    add chain=postrouting out-interface=$lan protocol=udp dst-port=500,4500 action=accept \
        comment="ElBasha: keep TTL for IKE (Wi-Fi calling)"
    add chain=postrouting out-interface=$lan protocol=icmp action=accept \
        comment="ElBasha: keep TTL for ICMP checks"
    add chain=postrouting out-interface=$lan dst-address-list=!eb-trusted action=change-ttl \
        new-ttl=set:1 passthrough=yes comment="ElBasha: TTL=1 anti-tethering"
}


# ==============================================================================
#  البلوك 6د: PCQ + Queue Tree — توزيع عادل وأولويات
# ==============================================================================

# PCQ يقسم السرعة بالتساوي بين المشتركين النشطين تلقائياً (pcq-rate=0 = بلا سقف للفرد هنا؛
# سقف كل كرت يأتي من rate-limit في بروفايل الباقة).
/queue type
:if ([:len [find where name="eb-pcq-down"]] = 0) do={ add name=eb-pcq-down kind=pcq pcq-classifier=dst-address pcq-rate=0 }
:if ([:len [find where name="eb-pcq-up"]] = 0) do={ add name=eb-pcq-up kind=pcq pcq-classifier=src-address pcq-rate=0 }

# التحميل على منفذ الجسر، والرفع على global (قبل NAT، ليبقى عنوان كل مشترك ظاهراً لـ PCQ)
/queue tree
remove [find where comment~"^ElBasha:"]
add name=EB-DOWN parent=$ebBridge max-limit=$ebLineDown comment="ElBasha: total download"
add name=EB-UP parent=global max-limit=$ebLineUp comment="ElBasha: total upload"
:foreach q in={{"eb-prio";1};{"eb-web";3};{"eb-other";5};{"eb-bulk";8}} do={
    :local c ($q->0)
    add name=("EB-DN-" . $c) parent=EB-DOWN packet-mark=($c . "-dn") priority=($q->1) \
        queue=eb-pcq-down comment="ElBasha: download class"
    add name=("EB-UP-" . $c) parent=EB-UP packet-mark=($c . "-up") priority=($q->1) \
        queue=eb-pcq-up comment="ElBasha: upload class"
}


# ==============================================================================
#  البلوك 5ج: مستخدم API لمحفظة شلن (صلاحيات محدودة)
# ==============================================================================

# المجموعة eb-api: api + read + write فقط. لا Winbox ولا SSH ولا reboot ولا تعديل المستخدمين،
# ومقيدة بعنوان سيرفر الدفع. الاتصال عبر API-SSL (8729) المشفر؛ API العادي (8728) يرسل كلمة السر مكشوفة.
:if ([:len $ebApiPass] >= 12 && [:len $ebApiAllow] > 0) do={
    /user group
    :if ([:len [find where name="eb-api"]] = 0) do={ add name=eb-api policy=api,read,write }
    set [find where name="eb-api"] policy=api,read,write comment="ElBasha: Shilling server"

    /user
    :if ([:len [find where name=$ebApiUser]] = 0) do={
        add name=$ebApiUser group=eb-api password=$ebApiPass address=$ebApiAllow comment="ElBasha: Shilling API"
    } else={
        set [find where name=$ebApiUser] group=eb-api password=$ebApiPass address=$ebApiAllow
    }

    /certificate
    :if ([:len [find where name="eb-api-ssl"]] = 0) do={
        add name=eb-api-ssl common-name=$ebDnsName days-valid=3650 key-usage=digital-signature,key-encipherment,tls-server
        sign eb-api-ssl
    }
    # التوقيع يأخذ ثواني على الأجهزة الضعيفة: نعيد المحاولة حتى تجهز الشهادة
    :local ok false
    :for i from=1 to=30 do={
        :if (!$ok) do={
            :do {
                /ip service set api-ssl certificate=eb-api-ssl address=$ebApiAllow disabled=no
                :set ok true
            } on-error={ :delay 2s }
        }
    }
    :if (!$ok) do={ :put "ElBasha: api-ssl certificate not ready, re-run the script in a minute" }
} else={
    :put "ElBasha: Shilling API user skipped (set ebApiPass >= 12 chars and ebApiAllow)"
}


# ==============================================================================
#  البلوك 3: النسخ الاحتياطي اليومي وتنظيف الكروت المنتهية
# ==============================================================================

# eb-backup: يومياً يحفظ الكروت (مع كلمات سرها) وبروفايلاتها واستهلاكها في ملفات الراوتر:
#   eb-users-<اليوم>.rsc     للاستعادة: /import file-name=flash/eb-users-27.rsc
#   eb-profiles-<اليوم>.rsc  البروفايلات
#   eb-usage-<اليوم>.txt     الوقت والبيانات المستهلكة لكل كرت
# الملفات تُستبدل بعد شهر (ملف لكل يوم من الشهر). انسخها خارج الراوتر من حين لآخر.
/system script
:if ([:len [find where name="eb-backup"]] = 0) do={ add name="eb-backup" }
set [find where name="eb-backup"] policy=read,write,test,sensitive source="# Day of month as the file suffix: one file per day, overwritten next month (31-day rotation).\r\
    \n:local d [/system clock get date]\r\
    \n:local day [:pick \$d 8 10]\r\
    \n:if ([:typeof [:find \$d \"/\"]] = \"num\") do={ :set day [:pick \$d 4 6] }\r\
    \n:local dir \"\"\r\
    \n:if ([:len [/file find where name=\"flash\"]] > 0) do={ :set dir \"flash/\" }\r\
    \n/ip hotspot user export show-sensitive file=(\$dir . \"eb-users-\" . \$day)\r\
    \n/ip hotspot user profile export file=(\$dir . \"eb-profiles-\" . \$day)\r\
    \n/ip hotspot user print detail without-paging file=(\$dir . \"eb-usage-\" . \$day)\r\
    \n:log info (\"ElBasha: vouchers backed up to \" . \$dir . \"eb-users-\" . \$day . \".rsc\")"

# eb-cleanup: دفعة يومية لطيفة تحذف الكروت المستنفَدة فقط: استنفدت limit-uptime (مدة
# الاستخدام) أو limit-bytes-total. الكروت بلا حدود لا تُمس أبداً. بلا أي كتابة على
# الفلاش أثناء التشغيل. يعمل بعد النسخ الاحتياطي، فكل كرت محذوف موجود في نسخة اليوم.
:if ([:len [find where name="eb-cleanup"]] = 0) do={ add name="eb-cleanup" }
set [find where name="eb-cleanup"] policy=read,write,test source="# Gentle daily batch (no per-event flash writes): expiry comes from each voucher's\r\
    \n# native limit-uptime (usage time from first login) and limit-bytes-total, which\r\
    \n# RouterOS enforces itself. This only purges vouchers that already hit their limit.\r\
    \n:local n 0\r\
    \n:foreach id in=[/ip hotspot user find where name!=\"default-trial\"] do={\r\
    \n  :local dead false\r\
    \n  :local lu [/ip hotspot user get \$id limit-uptime]\r\
    \n  :if ([:typeof \$lu] = \"time\") do={\r\
    \n    :if (\$lu > 0s && [/ip hotspot user get \$id uptime] >= \$lu) do={ :set dead true }\r\
    \n  }\r\
    \n  :local lb [/ip hotspot user get \$id limit-bytes-total]\r\
    \n  :if ([:typeof \$lb] = \"num\") do={\r\
    \n    :if (\$lb > 0 && ([/ip hotspot user get \$id bytes-in] + [/ip hotspot user get \$id bytes-out]) >= \$lb) do={ :set dead true }\r\
    \n  }\r\
    \n  :if (\$dead) do={\r\
    \n    :local u [/ip hotspot user get \$id name]\r\
    \n    /ip hotspot active remove [find where user=\$u]\r\
    \n    /ip hotspot user remove \$id\r\
    \n    :set n (\$n + 1)\r\
    \n  }\r\
    \n}\r\
    \n:log info (\"ElBasha: cleanup removed \" . \$n . \" used-up vouchers\")"


# ==============================================================================
#  البلوك 7: الجدولة، إعادة التشغيل الأسبوعية، Watchdog
# ==============================================================================

/system scheduler
remove [find where name~"^eb-"]
add name=eb-backup start-time=$ebBackupTime interval=1d policy=read,write,test,sensitive \
    on-event="/system script run eb-backup" comment="ElBasha: daily voucher backup"
add name=eb-cleanup start-time=$ebCleanupTime interval=1d policy=read,write,test \
    on-event="/system script run eb-cleanup" comment="ElBasha: daily used-up voucher cleanup"
# إعادة تشغيل أسبوعية الساعة 4 فجراً. اليوم = يوم تشغيل هذا السكربت؛ لتغييره عدّل start-date
add name=eb-weekly-reboot start-time=$ebRebootTime interval=1w policy=read,write,reboot \
    on-event="/system reboot" comment="ElBasha: weekly reboot"

# Watchdog:
#   watchdog-timer=yes : يعيد التشغيل تلقائياً إن تجمّد نظام التشغيل.
#   watch-address      : إن لم يرد 8.8.8.8 لمدة 10 دقائق يعيد تشغيل الراوتر لإنعاش الخط.
# تحذير: إن انقطع خط المزوّد نفسه لساعات سيعيد الراوتر تشغيل نفسه كل نحو 20 دقيقة حتى يعود الخط.
/system watchdog set watchdog-timer=yes watch-address=$ebWatchIp \
    ping-start-after-boot=10m ping-timeout=10m automatic-supout=no


:put "ElBasha: setup finished"
:log info "ElBasha: turnkey setup finished"
