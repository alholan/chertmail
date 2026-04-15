# CHERT Mail Installation Guide
# دليل تثبيت تشيرت ميل

Complete step-by-step guide for installing CHERT Mail on a fresh Ubuntu server (DigitalOcean Droplet).

دليل شامل خطوة بخطوة لتثبيت تشيرت ميل على خادم أوبونتو جديد (DigitalOcean Droplet).

---

## Table of Contents | جدول المحتويات

1. [Prerequisites | المتطلبات الأساسية](#1-prerequisites--المتطلبات-الأساسية)
2. [Create DigitalOcean Droplet | إنشاء Droplet](#2-create-digitalocean-droplet--إنشاء-droplet)
3. [Configure DNS Records | إعداد سجلات DNS](#3-configure-dns-records--إعداد-سجلات-dns)
4. [Server Preparation | تحضير الخادم](#4-server-preparation--تحضير-الخادم)
5. [Install CHERT Mail | تثبيت تشيرت ميل](#5-install-chert-mail--تثبيت-تشيرت-ميل)
6. [Post-Installation | ما بعد التثبيت](#6-post-installation--ما-بعد-التثبيت)
7. [Add Your Domain | إضافة نطاقك](#7-add-your-domain--إضافة-نطاقك)
8. [Create Mailbox | إنشاء صندوق بريد](#8-create-mailbox--إنشاء-صندوق-بريد)
9. [Test Your Mail Server | اختبار خادم البريد](#9-test-your-mail-server--اختبار-خادم-البريد)
10. [Troubleshooting | استكشاف الأخطاء](#10-troubleshooting--استكشاف-الأخطاء)

---

## 1. Prerequisites | المتطلبات الأساسية

### What You Need | ما تحتاجه

- DigitalOcean account (or any VPS provider)
- Domain name (e.g., `example.com`)
- Access to your domain's DNS settings
- SSH client (Terminal on Mac/Linux, or PuTTY on Windows)

### Minimum Server Requirements | الحد الأدنى لمتطلبات الخادم

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 4 GB | 8 GB |
| CPU | 2 cores | 4 cores |
| Storage | 40 GB SSD | 80 GB SSD |
| OS | Ubuntu 22.04/24.04 LTS | Ubuntu 24.04 LTS |

> **Note**: If you have less than 4GB RAM, ClamAV (antivirus) will be automatically disabled during installation.

---

## 2. Create DigitalOcean Droplet | إنشاء Droplet

### Step 2.1: Create Droplet

1. Log in to [DigitalOcean](https://cloud.digitalocean.com/)
2. Click **Create** → **Droplets**
3. Choose:
   - **Region**: Choose closest to your users (e.g., Frankfurt for Middle East)
   - **Image**: Ubuntu 24.04 LTS
   - **Size**: Regular → 4GB RAM / 2 CPUs ($24/month) or higher
   - **Authentication**: SSH Key (recommended) or Password
   - **Hostname**: `mail.example.com` (replace with your mail hostname)

4. Click **Create Droplet**

### Step 2.2: Note Your Server IP

After creation, note your droplet's IP address (e.g., `146.190.56.50`)

---

## 3. Configure DNS Records | إعداد سجلات DNS

### Required DNS Records | سجلات DNS المطلوبة

Go to your domain's DNS management (at your registrar or DigitalOcean DNS) and add these records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | mail | `YOUR_SERVER_IP` | 300 |
| MX | @ | `mail.example.com` | 300 |
| TXT | @ | `v=spf1 mx a -all` | 300 |
| TXT | _dmarc | `v=DMARC1; p=quarantine; rua=mailto:postmaster@example.com` | 300 |

### Example for domain `example.com` with IP `146.190.56.50`:

```
Type    Name        Value                                           Priority
----    ----        -----                                           --------
A       mail        146.190.56.50                                   -
MX      @           mail.example.com                                10
TXT     @           v=spf1 mx a -all                                -
TXT     _dmarc      v=DMARC1; p=quarantine; rua=mailto:postmaster@example.com
```

### Optional: Autodiscover Records

For automatic mail client configuration:

| Type | Name | Value |
|------|------|-------|
| CNAME | autoconfig | mail.example.com |
| CNAME | autodiscover | mail.example.com |

> **Important**: DNS propagation can take 5-30 minutes. Wait before proceeding to installation.

### Verify DNS (Optional)

```bash
# Check A record
dig +short mail.example.com

# Check MX record
dig +short MX example.com
```

---

## 4. Server Preparation | تحضير الخادم

### Step 4.1: Connect to Your Server

```bash
ssh root@YOUR_SERVER_IP
```

### Step 4.2: Set Hostname

```bash
hostnamectl set-hostname mail.example.com
```

### Step 4.3: Update /etc/hosts

```bash
nano /etc/hosts
```

Add this line (replace with your values):
```
YOUR_SERVER_IP    mail.example.com    mail
```

Example:
```
146.190.56.50    mail.example.com    mail
```

Save and exit (Ctrl+X, Y, Enter)

### Step 4.4: Update System

```bash
apt update && apt upgrade -y
```

### Step 4.5: Configure Firewall (if enabled)

```bash
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP (for Let's Encrypt)
ufw allow 443/tcp   # HTTPS
ufw allow 25/tcp    # SMTP
ufw allow 465/tcp   # SMTPS
ufw allow 587/tcp   # Submission
ufw allow 143/tcp   # IMAP
ufw allow 993/tcp   # IMAPS
ufw allow 110/tcp   # POP3
ufw allow 995/tcp   # POP3S
ufw allow 4190/tcp  # Sieve
```

### Step 4.6: Reboot (Recommended)

```bash
reboot
```

Wait 30 seconds, then reconnect:
```bash
ssh root@YOUR_SERVER_IP
```

---

## 5. Install CHERT Mail | تثبيت تشيرت ميل

### Step 5.1: Clone Repository

```bash
cd /opt
git clone https://github.com/alholan/chertmail.git
cd chertmail
```

### Step 5.2: Run Installation Script

```bash
./generate_config.sh
```

### Step 5.3: Answer the Prompts

The script will ask you for:

1. **Mail server hostname (FQDN)**:
   ```
   Mail server hostname (FQDN) - this is not your mail domain, but your mail servers hostname:
   اسم مضيف خادم البريد (FQDN) - هذا ليس نطاق بريدك، بل اسم مضيف خادم البريد:
   > mail.example.com
   ```

2. **Timezone** (default: Asia/Riyadh):
   ```
   Timezone (default: Asia/Riyadh):
   المنطقة الزمنية (الافتراضي: Asia/Riyadh):
   [Asia/Riyadh] >
   ```
   Press Enter to accept default, or type your timezone.

3. **ClamAV** (if low memory):
   ```
   Do you want to disable ClamAV now?
   هل تريد تعطيل ClamAV الآن؟
   [Y/n] >
   ```

### Step 5.4: Wait for Installation

The script will:
1. Install Docker (if not present)
2. Download all container images
3. Start all services
4. Wait for SSL certificate from Let's Encrypt

This takes approximately **5-10 minutes**.

### Step 5.5: Installation Complete

You will see:
```
========================================
  CHERT Mail installation complete!
  اكتمل تثبيت تشيرت ميل!
========================================

Access your mail server at: https://mail.example.com
الوصول إلى خادم البريد على: https://mail.example.com

Default login:
بيانات الدخول الافتراضية:
  Username | اسم المستخدم: admin
  Password | كلمة المرور: moohoo

IMPORTANT: Change the default password immediately!
مهم: قم بتغيير كلمة المرور الافتراضية فوراً!
```

---

## 6. Post-Installation | ما بعد التثبيت

### Step 6.1: Access Admin Panel

Open in browser:
```
https://mail.example.com
```

Login with:
- **Username**: `admin`
- **Password**: `moohoo`

### Step 6.2: Change Admin Password (IMPORTANT!)

1. Click on **admin** (top right)
2. Click **Edit**
3. Enter new secure password
4. Click **Save**

### Step 6.3: Configure DKIM

1. Go to **Configuration** → **ARC/DKIM keys**
2. Click **Add** for your domain
3. Select your domain, set selector (default: `dkim`)
4. Set key length: **2048 bits** (recommended)
5. Click **Add**
6. Copy the DKIM TXT record shown

### Step 6.4: Add DKIM to DNS

Add the DKIM record to your DNS:

| Type | Name | Value |
|------|------|-------|
| TXT | dkim._domainkey | `v=DKIM1; k=rsa; p=MIIBIjANBg...` (the long key) |

---

## 7. Add Your Domain | إضافة نطاقك

### Step 7.1: Add Domain

1. Go to **Configuration** → **E-Mail Setup** → **Domains**
2. Click **Add domain**
3. Enter:
   - **Domain**: `example.com`
   - **Max. Mailboxes**: Set your limit
   - **Max. Aliases**: Set your limit
   - **Quota**: Total storage for this domain (e.g., 10240 MB = 10 GB)
4. Click **Add domain**

### Step 7.2: Restart SOGo Container

After adding a domain, restart SOGo:

```bash
cd /opt/chertmail
docker compose restart sogo-mailcow
```

---

## 8. Create Mailbox | إنشاء صندوق بريد

### Step 8.1: Add Mailbox

1. Go to **Configuration** → **E-Mail Setup** → **Mailboxes**
2. Click **Add mailbox**
3. Enter:
   - **Username**: The part before @ (e.g., `user` for user@example.com)
   - **Domain**: Select your domain
   - **Full Name**: User's display name
   - **Password**: Strong password
   - **Quota**: Mailbox size limit (e.g., 1024 MB = 1 GB)
4. Click **Add**

### Step 8.2: Access Webmail

Users can access webmail at:
```
https://mail.example.com/SOGo
```

---

## 9. Test Your Mail Server | اختبار خادم البريد

### Step 9.1: Test Sending Email

1. Log in to webmail: `https://mail.example.com/SOGo`
2. Compose a new email to an external address (e.g., Gmail)
3. Send and verify it's received

### Step 9.2: Test Receiving Email

1. Send an email from external address to your new mailbox
2. Check it arrives in webmail

### Step 9.3: Test Mail Server Score

Use these tools to check your mail server configuration:

- **Mail-Tester**: https://www.mail-tester.com/
  - Send an email to the address shown
  - Get a score out of 10

- **MXToolbox**: https://mxtoolbox.com/
  - Check DNS, blacklist status, and more

### Step 9.4: Check DKIM Signing

Send test email to: `check-auth@verifier.port25.com`

You'll receive a report showing:
- SPF: pass/fail
- DKIM: pass/fail
- DMARC: pass/fail

---

## 10. Troubleshooting | استكشاف الأخطاء

### SSL Certificate Not Obtained

**Check ACME logs:**
```bash
cd /opt/chertmail
docker compose logs acme-mailcow
```

**Common issues:**
- DNS not propagated yet (wait 10-30 minutes)
- Port 80 blocked by firewall
- Wrong hostname in configuration

**Restart ACME:**
```bash
docker compose restart acme-mailcow
```

### Cannot Send/Receive Email

**Check Postfix logs:**
```bash
docker compose logs postfix-mailcow
```

**Check if port 25 is blocked:**
Many cloud providers block port 25 by default. Contact DigitalOcean support to unblock it:
- Go to Support → Create Ticket
- Request port 25 to be unblocked for email server

### Container Status

**Check all containers:**
```bash
docker compose ps
```

**Restart all containers:**
```bash
docker compose down
docker compose up -d
```

### View All Logs

```bash
docker compose logs -f
```

Press Ctrl+C to exit.

### Reset Admin Password

```bash
cd /opt/chertmail
source chertmail.conf
docker compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME} \
  -e "UPDATE admin SET password='{SSHA256}K8eVJ6YsZbQCfuJvSUbaQRLr0HPLz5rC9IAp0PAFl0tmNDBkMDc0' WHERE username='admin';"
```

This resets password to `moohoo`.

---

## Quick Reference | مرجع سريع

### Important URLs

| Service | URL |
|---------|-----|
| Admin Panel | `https://mail.example.com` |
| Webmail (SOGo) | `https://mail.example.com/SOGo` |
| Rspamd UI | `https://mail.example.com/rspamd` |

### Mail Client Settings

| Protocol | Server | Port | Security |
|----------|--------|------|----------|
| IMAP | mail.example.com | 993 | SSL/TLS |
| SMTP | mail.example.com | 587 | STARTTLS |
| POP3 | mail.example.com | 995 | SSL/TLS |

### Useful Commands

```bash
# Go to CHERT Mail directory
cd /opt/chertmail

# View container status
docker compose ps

# View logs (all)
docker compose logs -f

# View specific container logs
docker compose logs -f postfix-mailcow
docker compose logs -f dovecot-mailcow
docker compose logs -f acme-mailcow

# Restart all containers
docker compose restart

# Restart specific container
docker compose restart postfix-mailcow

# Update CHERT Mail
./update.sh

# Backup configuration
cp chertmail.conf chertmail.conf.backup
```

---

## Support | الدعم

- Documentation: https://docs.chertmail.com/
- GitHub Issues: https://github.com/alholan/chertmail/issues

---

**CHERT Mail** - Based on [mailcow](https://mailcow.email)
