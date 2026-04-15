# CHERT Mail - Enterprise Email Server

CHERT Mail is a fully-featured email server solution based on [mailcow](https://mailcow.email), customized for the Saudi Arabian market with Arabic language support.

## Features

- Complete email server stack with web UI
- Arabic and English bilingual interface
- Let's Encrypt SSL certificate automation
- Docker-based deployment
- Webmail (SOGo), CalDAV, CardDAV support
- Anti-spam (Rspamd) and antivirus (ClamAV)
- DKIM, SPF, DMARC support

## Quick Start

```bash
git clone https://github.com/alholan/chertmail.git /opt/chertmail
cd /opt/chertmail
./generate_config.sh
```

## Documentation

Please see [the official documentation](https://docs.chertmail.com/) for installation and support instructions.

## Attribution

CHERT Mail is based on [mailcow: dockerized](https://github.com/mailcow/mailcow-dockerized), an open-source email server solution.

- Original project: [mailcow](https://mailcow.email)
- Original maintainers: The Infrastructure Company GmbH
- mailcow is a registered trademark of The Infrastructure Company GmbH

## License

This project is released under **GNU General Public License, Version 3**, same as the original mailcow project.

**Important**: CHERT Mail makes use of various open-source software. Please ensure you agree with their licenses before using CHERT Mail.
