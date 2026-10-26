# ==============================================================================
# ZEIDEX HOTSPOT SETUP
# RouterOS v6.x / v7.x — upload this file, then: /import file-name=deploy_zeidex.rsc
# (Run it with /import, not by pasting: :local values only live inside one script.)
# ==============================================================================

# ---- Settings ----------------------------------------------------------------
:local theme "oled-matrix"
:local repo "https://raw.githubusercontent.com/zeiad6/login-wifi-page"
# Pin a release tag or commit instead of "main" so a later push can't change
# what your router serves without you checking it first.
:local ref "main"
# Devices without a "flash" folder use "hotspot".
:local dir "flash/hotspot"
:local hotspotAddress "192.168.88.1"
:local dnsName "zeidex.net"

# ---- Identity ----------------------------------------------------------------
/system identity set name="Zeidex-Router"

# ---- Hotspot profile ----------------------------------------------------------
# http-chap only: the router never accepts the voucher as plain text (no http-pap).
/ip hotspot profile
:if ([:len [find where name="Zeidex_Profile"]] = 0) do={ add name="Zeidex_Profile" }
set [find where name="Zeidex_Profile"] hotspot-address=$hotspotAddress \
    dns-name=$dnsName html-directory=$dir login-by=http-chap,cookie

:if ([:len [/ip hotspot find where name="hotspot1"]] > 0) do={
    /ip hotspot set [find where name="hotspot1"] profile="Zeidex_Profile"
} else={
    :put "No hotspot named hotspot1. Create one with /ip hotspot setup, then re-run."
}

# ---- Walled garden ------------------------------------------------------------
# The pages have no external fonts or scripts, so the old CDN exceptions only
# gave unpaid clients free access to those hosts. Remove them.
/ip hotspot walled-garden remove [find where comment~"^Allow (Tailwind|Google)"]

# ---- Download the theme --------------------------------------------------------
# check-certificate=yes needs a trusted root CA on the router:
#   v7.19+: /certificate settings set builtin-trust-anchors=trusted
#   older:  import the root CA used by raw.githubusercontent.com (/certificate import)
:foreach f in={"login.html";"status.html";"alogin.html";"logout.html"} do={
    /tool fetch url=($repo . "/" . $ref . "/themes/" . $theme . "/" . $f) \
        dst-path=($dir . "/" . $f) check-certificate=yes
}
:put ("Zeidex theme '" . $theme . "' installed in " . $dir)

# ---- Firewall ------------------------------------------------------------------
# Rate limits for the login portal live in hotspot_security.rsc:
#   /tool fetch url=($repo . "/" . $ref . "/scripts/hotspot_security.rsc") check-certificate=yes
#   /import file-name=hotspot_security.rsc
