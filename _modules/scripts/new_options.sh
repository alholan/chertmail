#!/usr/bin/env bash
# _modules/scripts/new_options.sh
# THIS SCRIPT IS DESIGNED TO BE RUNNING BY MAILCOW SCRIPTS ONLY!
# DO NOT, AGAIN, NOT TRY TO RUN THIS SCRIPT STANDALONE!!!!!!

adapt_new_options() {

  CONFIG_ARRAY=(
  "AUTODISCOVER_SAN"
  "SKIP_LETS_ENCRYPT"
  "SKIP_SOGO"
  "USE_WATCHDOG"
  "WATCHDOG_NOTIFY_EMAIL"
  "WATCHDOG_NOTIFY_WEBHOOK"
  "WATCHDOG_NOTIFY_WEBHOOK_BODY"
  "WATCHDOG_NOTIFY_BAN"
  "WATCHDOG_NOTIFY_START"
  "WATCHDOG_EXTERNAL_CHECKS"
  "WATCHDOG_SUBJECT"
  "SKIP_CLAMD"
  "SKIP_OLEFY"
  "SKIP_IP_CHECK"
  "ADDITIONAL_SAN"
  "DOVEADM_PORT"
  "IPV4_NETWORK"
  "IPV6_NETWORK"
  "LOG_LINES"
  "SNAT_TO_SOURCE"
  "SNAT6_TO_SOURCE"
  "COMPOSE_PROJECT_NAME"
  "DOCKER_COMPOSE_VERSION"
  "SQL_PORT"
  "API_KEY"
  "API_KEY_READ_ONLY"
  "API_ALLOW_FROM"
  "MAILDIR_GC_TIME"
  "MAILDIR_SUB"
  "ACL_ANYONE"
  "FTS_HEAP"
  "FTS_PROCS"
  "SKIP_FTS"
  "ENABLE_SSL_SNI"
  "ALLOW_ADMIN_EMAIL_LOGIN"
  "SKIP_HTTP_VERIFICATION"
  "SOGO_EXPIRE_SESSION"
  "SOGO_URL_ENCRYPTION_KEY"
  "REDIS_PORT"
  "REDISPASS"
  "DOVECOT_MASTER_USER"
  "DOVECOT_MASTER_PASS"
  "MAILCOW_PASS_SCHEME"
  "ADDITIONAL_SERVER_NAMES"
  "WATCHDOG_VERBOSE"
  "WEBAUTHN_ONLY_TRUSTED_VENDORS"
  "SPAMHAUS_DQS_KEY"
  "SKIP_UNBOUND_HEALTHCHECK"
  "DISABLE_NETFILTER_ISOLATION_RULE"
  "HTTP_REDIRECT"
  "ENABLE_IPV6"
  "ACME_DNS_CHALLENGE"
  "ACME_DNS_PROVIDER"
  "ACME_ACCOUNT_EMAIL"
  )

  sed -i --follow-symlinks '$a\' chertmail.conf
  for option in ${CONFIG_ARRAY[@]}; do
    if grep -q "^#\?${option}=" chertmail.conf; then
      continue
    fi

    echo "Adding new option \"${option}\" to chertmail.conf"

    case "${option}" in
        AUTODISCOVER_SAN)
            echo '# Obtain certificates for autodiscover.* and autoconfig.* domains.' >> chertmail.conf
            echo '# This can be useful to switch off in case you are in a scenario where a reverse proxy already handles those.' >> chertmail.conf
            echo '# There are mixed scenarios where ports 80,443 are occupied and you do not want to share certs' >> chertmail.conf
            echo '# between services. So acme-mailcow obtains for maildomains and all web-things get handled' >> chertmail.conf
            echo '# in the reverse proxy.' >> chertmail.conf
            echo 'AUTODISCOVER_SAN=y' >> chertmail.conf
            ;;

        DOCKER_COMPOSE_VERSION)
            echo "# Used Docker Compose version" >> chertmail.conf
            echo "# Switch here between native (compose plugin) and standalone" >> chertmail.conf
            echo "# For more informations take a look at the mailcow docs regarding the configuration options." >> chertmail.conf
            echo "# Normally this should be untouched but if you decided to use either of those you can switch it manually here." >> chertmail.conf
            echo "# Please be aware that at least one of those variants should be installed on your machine or mailcow will fail." >> chertmail.conf
            echo "" >> chertmail.conf
            echo "DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION}" >> chertmail.conf
            ;;

        DOVEADM_PORT)
            echo "DOVEADM_PORT=127.0.0.1:19991" >> chertmail.conf
            ;;

        LOG_LINES)
            echo '# Max log lines per service to keep in Redis logs' >> chertmail.conf
            echo "LOG_LINES=9999" >> chertmail.conf
            ;;
        IPV4_NETWORK)
            echo '# Internal IPv4 /24 subnet, format n.n.n. (expands to n.n.n.0/24)' >> chertmail.conf
            echo "IPV4_NETWORK=172.22.1" >> chertmail.conf
            ;;
        IPV6_NETWORK)
            echo '# Internal IPv6 subnet in fc00::/7' >> chertmail.conf
            echo "IPV6_NETWORK=fd4d:6169:6c63:6f77::/64" >> chertmail.conf
            ;;
        SQL_PORT)
            echo '# Bind SQL to 127.0.0.1 on port 13306' >> chertmail.conf
            echo "SQL_PORT=127.0.0.1:13306" >> chertmail.conf
            ;;
        API_KEY)
            echo '# Create or override API key for web UI' >> chertmail.conf
            echo "#API_KEY=" >> chertmail.conf
            ;;
        API_KEY_READ_ONLY)
            echo '# Create or override read-only API key for web UI' >> chertmail.conf
            echo "#API_KEY_READ_ONLY=" >> chertmail.conf
            ;;
        API_ALLOW_FROM)
            echo '# Must be set for API_KEY to be active' >> chertmail.conf
            echo '# IPs only, no networks (networks can be set via UI)' >> chertmail.conf
            echo "#API_ALLOW_FROM=" >> chertmail.conf
            ;;
        SNAT_TO_SOURCE)
            echo '# Use this IPv4 for outgoing connections (SNAT)' >> chertmail.conf
            echo "#SNAT_TO_SOURCE=" >> chertmail.conf
            ;;
        SNAT6_TO_SOURCE)
            echo '# Use this IPv6 for outgoing connections (SNAT)' >> chertmail.conf
            echo "#SNAT6_TO_SOURCE=" >> chertmail.conf
            ;;
        MAILDIR_GC_TIME)
            echo '# Garbage collector cleanup' >> chertmail.conf
            echo '# Deleted domains and mailboxes are moved to /var/vmail/_garbage/timestamp_sanitizedstring' >> chertmail.conf
            echo '# How long should objects remain in the garbage until they are being deleted? (value in minutes)' >> chertmail.conf
            echo '# Check interval is hourly' >> chertmail.conf
            echo 'MAILDIR_GC_TIME=1440' >> chertmail.conf
            ;;
        ACL_ANYONE)
            echo '# Set this to "allow" to enable the anyone pseudo user. Disabled by default.' >> chertmail.conf
            echo '# When enabled, ACL can be created, that apply to "All authenticated users"' >> chertmail.conf
            echo '# This should probably only be activated on mail hosts, that are used exclusively by one organisation.' >> chertmail.conf
            echo '# Otherwise a user might share data with too many other users.' >> chertmail.conf
            echo 'ACL_ANYONE=disallow' >> chertmail.conf
            ;;
        FTS_HEAP)
            echo '# Dovecot Indexing (FTS) Process maximum heap size in MB, there is no recommendation, please see Dovecot docs.' >> chertmail.conf
            echo '# Flatcurve is used as FTS Engine. It is supposed to be pretty efficient in CPU and RAM consumption.' >> chertmail.conf
            echo '# Please always monitor your Resource consumption!' >> chertmail.conf
            echo "FTS_HEAP=128" >> chertmail.conf
            ;;
        SKIP_FTS)
            echo '# Skip FTS (Fulltext Search) for Dovecot on low-memory, low-threaded systems or if you simply want to disable it.' >> chertmail.conf
            echo "# Dovecot inside mailcow use Flatcurve as FTS Backend." >> chertmail.conf
            echo "SKIP_FTS=y" >> chertmail.conf
            ;;
        FTS_PROCS)
            echo '# Controls how many processes the Dovecot indexing process can spawn at max.' >> chertmail.conf
            echo '# Too many indexing processes can use a lot of CPU and Disk I/O' >> chertmail.conf
            echo '# Please visit: https://doc.dovecot.org/configuration_manual/service_configuration/#indexer-worker for more informations' >> chertmail.conf
            echo "FTS_PROCS=1" >> chertmail.conf
            ;;
        ENABLE_SSL_SNI)
            echo '# Create seperate certificates for all domains - y/n' >> chertmail.conf
            echo '# this will allow adding more than 100 domains, but some email clients will not be able to connect with alternative hostnames' >> chertmail.conf
            echo '# see https://wiki.dovecot.org/SSL/SNIClientSupport' >> chertmail.conf
            echo "ENABLE_SSL_SNI=n" >> chertmail.conf
            ;;
        SKIP_SOGO)
            echo '# Skip SOGo: Will disable SOGo integration and therefore webmail, DAV protocols and ActiveSync support (experimental, unsupported, not fully implemented) - y/n' >> chertmail.conf
            echo "SKIP_SOGO=n" >> chertmail.conf
            ;;
        MAILDIR_SUB)
            echo '# MAILDIR_SUB defines a path in a users virtual home to keep the maildir in. Leave empty for updated setups.' >> chertmail.conf
            echo "#MAILDIR_SUB=Maildir" >> chertmail.conf
            echo "MAILDIR_SUB=" >> chertmail.conf
            ;;
        WATCHDOG_NOTIFY_WEBHOOK)
            echo '# Send notifications to a webhook URL that receives a POST request with the content type "application/json".' >> chertmail.conf
            echo '# You can use this to send notifications to services like Discord, Slack and others.' >> chertmail.conf
            echo '#WATCHDOG_NOTIFY_WEBHOOK=https://discord.com/api/webhooks/XXXXXXXXXXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' >> chertmail.conf
            ;;
        WATCHDOG_NOTIFY_WEBHOOK_BODY)
            echo '# JSON body included in the webhook POST request. Needs to be in single quotes.' >> chertmail.conf
            echo '# Following variables are available: SUBJECT, BODY' >> chertmail.conf
            WEBHOOK_BODY='{"username": "mailcow Watchdog", "content": "**${SUBJECT}**\n${BODY}"}'
            echo "#WATCHDOG_NOTIFY_WEBHOOK_BODY='${WEBHOOK_BODY}'" >> chertmail.conf
            ;;
        WATCHDOG_NOTIFY_BAN)
            echo '# Notify about banned IP. Includes whois lookup.' >> chertmail.conf
            echo "WATCHDOG_NOTIFY_BAN=y" >> chertmail.conf
            ;;
        WATCHDOG_NOTIFY_START)
            echo '# Send a notification when the watchdog is started.' >> chertmail.conf
            echo "WATCHDOG_NOTIFY_START=y" >> chertmail.conf
            ;;
        WATCHDOG_SUBJECT)
            echo '# Subject for watchdog mails. Defaults to "Watchdog ALERT" followed by the error message.' >> chertmail.conf
            echo "#WATCHDOG_SUBJECT=" >> chertmail.conf
            ;;
        WATCHDOG_EXTERNAL_CHECKS)
            echo '# Checks if mailcow is an open relay. Requires a SAL. More checks will follow.' >> chertmail.conf
            echo '# No data is collected. Opt-in and anonymous.' >> chertmail.conf
            echo '# Will only work with unmodified mailcow setups.' >> chertmail.conf
            echo "WATCHDOG_EXTERNAL_CHECKS=n" >> chertmail.conf
            ;;
        SOGO_EXPIRE_SESSION)
            echo '# SOGo session timeout in minutes' >> chertmail.conf
            echo "SOGO_EXPIRE_SESSION=480" >> chertmail.conf
            ;;
        REDIS_PORT)
            echo "REDIS_PORT=127.0.0.1:7654" >> chertmail.conf
            ;;
        DOVECOT_MASTER_USER)
            echo '# DOVECOT_MASTER_USER and _PASS must _both_ be provided. No special chars.' >> chertmail.conf
            echo '# Empty by default to auto-generate master user and password on start.' >> chertmail.conf
            echo '# User expands to DOVECOT_MASTER_USER@mailcow.local' >> chertmail.conf
            echo '# LEAVE EMPTY IF UNSURE' >> chertmail.conf
            echo "DOVECOT_MASTER_USER=" >> chertmail.conf
            ;;
        DOVECOT_MASTER_PASS)
            echo '# LEAVE EMPTY IF UNSURE' >> chertmail.conf
            echo "DOVECOT_MASTER_PASS=" >> chertmail.conf
            ;;
        MAILCOW_PASS_SCHEME)
            echo '# Password hash algorithm' >> chertmail.conf
            echo '# Only certain password hash algorithm are supported. For a fully list of supported schemes,' >> chertmail.conf
            echo '# see https://docs.mailcow.email/models/model-passwd/' >> chertmail.conf
            echo "MAILCOW_PASS_SCHEME=BLF-CRYPT" >> chertmail.conf
            ;;
        ADDITIONAL_SERVER_NAMES)
            echo '# Additional server names for mailcow UI' >> chertmail.conf
            echo '#' >> chertmail.conf
            echo '# Specify alternative addresses for the mailcow UI to respond to' >> chertmail.conf
            echo '# This is useful when you set mail.* as ADDITIONAL_SAN and want to make sure mail.maildomain.com will always point to the mailcow UI.' >> chertmail.conf
            echo '# If the server name does not match a known site, Nginx decides by best-guess and may redirect users to the wrong web root.' >> chertmail.conf
            echo '# You can understand this as server_name directive in Nginx.' >> chertmail.conf
            echo '# Comma separated list without spaces! Example: ADDITIONAL_SERVER_NAMES=a.b.c,d.e.f' >> chertmail.conf
            echo 'ADDITIONAL_SERVER_NAMES=' >> chertmail.conf
            ;;
        WEBAUTHN_ONLY_TRUSTED_VENDORS)
            echo "# WebAuthn device manufacturer verification" >> chertmail.conf
            echo '# After setting WEBAUTHN_ONLY_TRUSTED_VENDORS=y only devices from trusted manufacturers are allowed' >> chertmail.conf
            echo '# root certificates can be placed for validation under mailcow-dockerized/data/web/inc/lib/WebAuthn/rootCertificates' >> chertmail.conf
            echo 'WEBAUTHN_ONLY_TRUSTED_VENDORS=n' >> chertmail.conf
            ;;
        SPAMHAUS_DQS_KEY)
            echo "# Spamhaus Data Query Service Key" >> chertmail.conf
            echo '# Optional: Leave empty for none' >> chertmail.conf
            echo '# Enter your key here if you are using a blocked ASN (OVH, AWS, Cloudflare e.g) for the unregistered Spamhaus Blocklist.' >> chertmail.conf
            echo '# If empty, it will completely disable Spamhaus blocklists if it detects that you are running on a server using a blocked AS.' >> chertmail.conf
            echo '# Otherwise it will work as usual.' >> chertmail.conf
            echo 'SPAMHAUS_DQS_KEY=' >> chertmail.conf
            ;;
        WATCHDOG_VERBOSE)
            echo '# Enable watchdog verbose logging' >> chertmail.conf
            echo 'WATCHDOG_VERBOSE=n' >> chertmail.conf
            ;;
        SKIP_UNBOUND_HEALTHCHECK)
            echo '# Skip Unbound (DNS Resolver) Healthchecks (NOT Recommended!) - y/n' >> chertmail.conf
            echo 'SKIP_UNBOUND_HEALTHCHECK=n' >> chertmail.conf
            ;;
        DISABLE_NETFILTER_ISOLATION_RULE)
            echo '# Prevent netfilter from setting an iptables/nftables rule to isolate the mailcow docker network - y/n' >> chertmail.conf
            echo '# CAUTION: Disabling this may expose container ports to other neighbors on the same subnet, even if the ports are bound to localhost' >> chertmail.conf
            echo 'DISABLE_NETFILTER_ISOLATION_RULE=n' >> chertmail.conf
            ;;
        HTTP_REDIRECT)
            echo '# Redirect HTTP connections to HTTPS - y/n' >> chertmail.conf
            echo 'HTTP_REDIRECT=n' >> chertmail.conf
            ;;
        ENABLE_IPV6)
            echo '# IPv6 Controller Section' >> chertmail.conf
            echo '# This variable controls the usage of IPv6 within mailcow.' >> chertmail.conf
            echo '# Can either be true or false | Defaults to true' >> chertmail.conf
            echo '# WARNING: MAKE SURE TO PROPERLY CONFIGURE IPv6 ON YOUR HOST FIRST BEFORE ENABLING THIS AS FAULTY CONFIGURATIONS CAN LEAD TO OPEN RELAYS!' >> chertmail.conf
            echo '# A COMPLETE DOCKER STACK REBUILD (compose down && compose up -d) IS NEEDED TO APPLY THIS.' >> chertmail.conf
            echo ENABLE_IPV6=${IPV6_BOOL} >> chertmail.conf
            ;;
        SKIP_CLAMD)
            echo '# Skip ClamAV (clamd-mailcow) anti-virus (Rspamd will auto-detect a missing ClamAV container) - y/n' >> chertmail.conf
            echo 'SKIP_CLAMD=n' >> chertmail.conf
            ;;
        SKIP_OLEFY)
            echo '# Skip Olefy (olefy-mailcow) anti-virus for Office documents (Rspamd will auto-detect a missing Olefy container) - y/n' >> chertmail.conf
            echo 'SKIP_OLEFY=n' >> chertmail.conf
            ;;
        REDISPASS)
            echo "REDISPASS=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c 28)" >> chertmail.conf
            ;;
        SOGO_URL_ENCRYPTION_KEY)
            echo '# SOGo URL encryption key (exactly 16 characters, limited to A–Z, a–z, 0–9)' >> chertmail.conf
            echo '# This key is used to encrypt email addresses within SOGo URLs' >> chertmail.conf
            echo "SOGO_URL_ENCRYPTION_KEY=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c 16)" >> chertmail.conf
            ;;
        ACME_DNS_CHALLENGE)
            echo '# Enable DNS-01 challenge for ACME (acme-mailcow) - y/n' >> chertmail.conf
            echo '# This requires you to set ACME_DNS_PROVIDER and ACME_ACCOUNT_EMAIL below' >> chertmail.conf
            echo 'ACME_DNS_CHALLENGE=n' >> chertmail.conf
            ;;
        ACME_DNS_PROVIDER)
            echo '# DNS provider for DNS-01 challenge (e.g. dns_cf, dns_azure, dns_gd, etc.)' >> chertmail.conf
            echo '# See the dns-01 provider documentation for more information.' >> chertmail.conf
            echo 'ACME_DNS_PROVIDER=dns_xxx' >> chertmail.conf
            ;;
        ACME_ACCOUNT_EMAIL)
            echo '# Account email for ACME DNS-01 challenge registration' >> chertmail.conf
            echo 'ACME_ACCOUNT_EMAIL=me@example.com' >> chertmail.conf
            ;;
        *)
            echo "${option}=" >> chertmail.conf
            ;;
    esac
  done
}