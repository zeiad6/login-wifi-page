# ==============================================================================
# ZEIDEX HOTSPOT FIREWALL: rate limiting and temporary bans for the login portal
# RouterOS v6.x / v7.x — run with: /import file-name=hotspot_security.rsc
#
# The hotspot dst-nats every client request on :80/:443 to its own web server
# on 64872-64875, so these are the ports the login pages are actually served on.
# Limits are generous on purpose: phones fire OS connectivity checks
# (generate_204, hotspot-detect) that land here too, and a tight limit bans
# real customers. The real defence against voucher guessing is voucher length:
# use 10+ random digits so guessing is hopeless even at the allowed rate.
# ==============================================================================

# Re-running the script replaces the old rules instead of duplicating them.
/ip firewall filter remove [find where comment~"^Zeidex:"]

/ip firewall filter
add chain=input protocol=tcp dst-port=64872-64875 src-address-list=zeidex_blacklist \
    action=drop comment="Zeidex: drop banned clients"
add chain=input protocol=tcp dst-port=64872-64875 connection-state=new \
    connection-limit=40,32 action=add-src-to-address-list \
    address-list=zeidex_blacklist address-list-timeout=15m \
    comment="Zeidex: more than 40 open connections from one IP -> ban 15m"
add chain=input protocol=tcp dst-port=64872-64875 connection-state=new \
    action=jump jump-target=zeidex-rate comment="Zeidex: check new connection rate"

add chain=zeidex-rate dst-limit=60,120,src-address/1m action=return \
    comment="Zeidex: allow up to 60 new connections/min per IP (burst 120)"
add chain=zeidex-rate action=add-src-to-address-list \
    address-list=zeidex_blacklist address-list-timeout=15m \
    comment="Zeidex: over the rate -> ban 15m"
add chain=zeidex-rate action=drop comment="Zeidex: drop the excess connection"

# To lift a ban early:
#   /ip firewall address-list remove [find list=zeidex_blacklist address=192.168.88.50]
