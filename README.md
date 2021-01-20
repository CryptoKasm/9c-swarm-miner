# Nine Chronicles - CryptoKasm Swarm Miner

**Nine Chronicles is a fantasy MMORPG, set in a vast fantasy world powered by groundbreaking blockchain technology, that gives players the freedom to play how they want: exploring, crafting, mining or governing in a uniquely moddable, open-source adventure.** 

*Conquer dangerous dungeons to gather rare resources for trade; specialize in crafting the finest equipment; mine your own income; or pass legislation with the support of other players to inhabit this realm as you see fit.*

**This project was created to provide an easy solution for those wanting to mine their own income (NCG) via Docker containers. This branch holds automated scripts that setup the required environment to run these containers on both Linux & Windows 10, version 1903 or higher** 


<br>

#
### Quick Tip: 
- **Linux Users: Please skip down to [Section 2](#Linux) to begin install.**
- **Windows Users: MAKE SURE TO START DOCKER, before continuing to [Section 2](#Linux).**
#
<br>

# Windows 10

**Minimum System Requirements**
- Windows 10, version 1903 or higher
- 64 bit processor with Second Level Address Translation (SLAT)
- 4GB RAM
- BIOS-level hardware virtualization support must be enabled in the BIOS settings.

<br>

**Script Tasks**
1. Install: Windows Subsystem for Linux (WSL2)
1. Install: Virtual Machine Platform
1. Install: Linux Kernel
1. Install: Ubuntu 20.04
1. Install: Docker

## Usage
1. ***Run as administrator***
```PowerShell
powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr('https://raw.githubusercontent.com/CryptoKasm/9c-swarm-miner/master/setup_windows.ps1') -UseBasicParsing|iex"
```
2. ***Restart your computer***
3. ***Run same command again, as administrator***
4. ***Enable Docker WSL Integration***<br>
    1. Open Docker Desktop
    1. Goto: >Settings >Resources >WSL Integratoin >Switch ON - Ubuntu 20.04
    1. Hit Button: Apply & Restart

<br>

*Congratulations! You are now running Docker Desktop with WSL Support!*
*Continue below, following the Linux instructions in your newly downloaded Ubuntu distro!*

**TIP: Start your WSL Distro like any other program via the Shortcut Icon or by running wsl.exe**

<br>

# Linux

**Minimum System Requirements**
- Linux Distro (Physical/VM)
- (Min 2 cores) 64 bit processor with Second Level Address Translation (SLAT)
- 4GB RAM
- BIOS-level hardware virtualization support must be enabled in the BIOS settings.

<br>

**Script Tasks**
1. Install: Docker
1. Install: Compose
1. Install: Git & Unzip
1. Set Permissions
1. Create Configuration File
1. Create/Mange Snapshots
1. Updater

## Usage
1. ***Clone Repository***
```bash
# Quick Download
$ git clone https://github.com/CryptoKasm/9c-swarm-miner.git ~/9c-swarm-miner && cd 9c-swarm-miner
$ chmod +x 9c-swarm-miner.sh
```

2. ***Run Script***
```bash
# First run, will setup system. Checks for updates each run
$ sudo ./9c-swarm-miner.sh
```

3. ***Edit Configuration File***
```bash
# Quick Download
$ nano .settings.conf
```
```bash 
# Example Configuration

# Nine Chronicles - CryptoKasm Swarm Miner

DEBUG=0

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=1

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=4096M

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=2048M
```

<br>

* ***Congratulations! You are now mining NGC like a boss via Docker!***<br>

<br>

# Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


<br>

# Community & Support
Come join us in the community Discord server! If you have any questions, don't hesitate to ask!<br/>
- **Planetarium - [Discord](https://discord.gg/k6z2GS4yh2)**

Support & Bug Reports<br/>
- **CrytpoKasm - [Discord](https://discord.gg/k6z2GS4yh2)**

<br>

# License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)