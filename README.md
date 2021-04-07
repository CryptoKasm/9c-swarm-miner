# Nine Chronicles - CryptoKasm Swarm Miner

**Nine Chronicles is a fantasy MMORPG, set in a vast fantasy world powered by groundbreaking blockchain technology, that gives players the freedom to play how they want: exploring, crafting, mining or governing in a uniquely moddable, open-source adventure.** 

*Conquer dangerous dungeons to gather rare resources for trade; specialize in crafting the finest equipment; mine your own income; or pass legislation with the support of other players to inhabit this realm as you see fit.*

**This project was created to provide an easy solution for those wanting to mine their own income (NCG) via Docker containers. This branch holds automated scripts that setup the required environment to run these containers on both Linux & Windows 10, version 1903 or higher** 


<br>

#
### Notes: 
- **<span style="color:green">TIP:</span> Linux Users: Please skip down to [Section 2](#Linux) to begin install.**

- **<span style="color:green">TIP:</span> Windows Users: MAKE SURE TO START DOCKER, before continuing to [Section 2](#Linux).**

- **<span style="color:red">WARNING:</span> Installing the Swarm Miner enables Hyper-V on Windows. This could cause issues with VMware Workstation if it is installed.**

- **<span style="color:red">WARNING:</span> Some anti-virus software may flag the miner as malicious, please add an exception or disable and retry before contacting support.**

- **<span style="color:red">WARNING:</span> Those upgrading to v1.6.2-beta, MAKE SURE TO RUN BOTH COMMANDS: git pull && ./9c-swarm-miner.sh --update**
#
<br>

# Windows 10 (Skip, if already installed or Linux User)

**Minimum System Requirements**
- Windows 10, version 1903 or higher
- 64 bit processor with Second Level Address Translation (SLAT)
- 4GB RAM
- BIOS-level hardware virtualization support must be enabled in the BIOS settings.

**Script Tasks**
1. Install: Windows Subsystem for Linux (WSL2)
1. Install: Virtual Machine Platform
1. Install: Linux Kernel
1. Install: Ubuntu 20.04
1. Install: Docker

## Usage
1. ***Open PowerShell Terminal (as administrator) & run the command below***
```PowerShell
powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr('https://raw.githubusercontent.com/CryptoKasm/9c-swarm-miner/master/setup_windows.ps1') -UseBasicParsing|iex"
```
2. ***Restart your computer***
3. ***Open PowerShell Terminal (as administrator) & re-run the command above***
4. ***Enable Docker WSL Integration***<br>
    1. Open Docker Desktop
    1. Goto: >Settings >Resources >WSL Integratoin >Switch ON - Ubuntu 20.04
    1. Hit Button: Apply & Restart

<br>

*Congratulations! You are now running Docker Desktop with WSL Support!*
*Continue below, following the Linux instructions in your newly downloaded Ubuntu distro!*

**TIP: Start your WSL Distro like any other program via the Shortcut Icon or by running wsl.exe**

<br>

## References
- https://docs.microsoft.com/en-us/windows/wsl/install-win10
- https://docs.docker.com/docker-for-windows/install-windows-home/

<br>

# Linux

**Minimum System Requirements**
- Linux Distro (Physical/VM)
- (Min 2 cores) 64 bit processor with Second Level Address Translation (SLAT)
- 4GB RAM
- BIOS-level hardware virtualization support must be enabled in the BIOS settings.

**Script Tasks**
1. Install: Dependencies
1. Set Permissions
1. Create Configuration File
1. Create/Refresh Snapshots
1. Updater

## Usage
1. ***Install Git***
```bash
# Quick Download
$ sudo apt install -y git
```

2. ***Clone Repository***
```bash
# Quick Download
$ git clone https://github.com/CryptoKasm/9c-swarm-miner.git $HOME/9c-swarm-miner
$ cd $HOME/9c-swarm-miner
```

3. ***Run Script***
```bash
# First run will setup system, each run after that will execute like normal
$ ./9c-swarm-miner.sh
# Follow terminal instuctions
```

```bash
# Usage:
./9c-swarm-miner.sh [OPTION] #Run normally, without options
    --start             # Starts miners in docker
    --stop              # Stops docker miners
    --update            # Updates source code
    --setup             # Installs prereqs for script
    --settings          # Edit settings.conf
    --refresh           # Refresh snapshot if older than 2hrs
    --force-refresh     # Force refresh snapshot
    --clean             # Cleans refreshable files (downloaded/generated files)
    --clean-all         # Fresh Install (downloaded/generated files,settings)
    --check-vol         # Checks if volume data matches data in 'latest-snapshot' directory
    --check-permissions # Makes files runable and editable
    --logging           # Display logging commands for quick copy/paste
    --send-logs         # Sends your docker logs to our support email
    --check-gold        # Checks current gold balance via GraphQL query
    --keys              # Display current private/public keys and prompt to update
    --private-key       # Display current private key and prompt to update
    --public-key        # Display current public key and prompt to update
```

<br>

* ***Congratulations! You are now mining NCG like a boss via Docker!***<br>

<br>

***Extra Features***
```bash
# Check: Nine Chronicles Gold Balance
./9c-swarm-miner.sh --check-gold
```

***Update***
```bash
# To update run these commands from the 9c-swarm-miner directory
git pull
./9c-swarm-miner.sh --update
```

<br>

## References
- https://github.com/planetarium/NineChronicles.Headless

<br>

# Example: Settings.conf
```bash 
# Nine Chronicles - CryptoKasm Swarm Miner

# Turn on/off debugging for this script (1 ON/0 OFF)
DEBUG=0

# Set log level for all miners
LOG_LEVEL=debug

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=1

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=6144M

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=2048M

# Refresh Snapshot each run (NATIVE LINUX ONLY 4 NOW) (1 ON/0 OFF)
NC_REFRESH_SNAPSHOT=1

# Cronjob Auto Restart **HOURS** (0 OFF)
NC_CRONJOB_AUTO_RESTART=0

# Enable GraphQL Query Commands
NC_GRAPHQL_QUERIES=1
```
<br>

# Issues & Solutions
- **WslRegisterDistribution failed with error: 0xc03a001a**
~~~powershell
1. Find the folder "CanonicalGroupLimited.Ubuntu20.04onWindows_xxxx" located at "C:\Users\<USERNAME>\AppData\Local\Packages".
2. Right click folder > Properties > Advanced > Uncheck "Compress Contents to save disk"
~~~

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
