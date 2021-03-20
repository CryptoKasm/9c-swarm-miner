# Project: 9c-swarm-miner | Version: 1.7.0-beta

### Repository: https://github.com/CryptoKasm/9c-swarm-miner/tree/development

### Branch: development

<br>

### Getting Started:
```
If using existing source:
    - backup your settings.conf as it will be altered during testing.
    - run: ./9c-swarm-miner.sh --clean-all

OR

If not, download fresh source code (recommended so its separate from your working version)
```
```
- Run through script once to regenerate new needed files
- Begin testing
```

<br>

---
## What to test:

### 1.
```bash
New arguments:  [ Example: ./9c-swarm-miner.sh --keys ]
    --keys          # Should prompt for both public & private key and update settings.conf
    --public-key    # Should prompt for public key and update settings.conf
    --private-key   # Should prompt for private key and update settings.conf
    --settings      # Should open settings.conf in nano
    --logging       # Should display various logging commands for quick copy/paste
```
### 2.
```
After script execution, check:
    - Crontab is running
    - Crontab entry was made in the root crontab file
    - Pay attention to see if crontab actually runs and executes the entry properly. You will know if there is a log file inside the /logs directory.
```
### 3.
```
Once those previous things have been tested, please try various actions and to break it.
```

<br>

---
## Thank you for your assistance!
