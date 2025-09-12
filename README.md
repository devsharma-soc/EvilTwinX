# EvilTwinX

**EvilTwinX** is an advanced Proof-of-Concept (PoC) Evil Twin Wi-Fi attack tool designed for educational and lab purposes. It allows security researchers and enthusiasts to understand how rogue Wi-Fi access points can capture WPA/WPA2 passwords through phishing-style captive portals.

> ⚠ **Disclaimer:** This tool is intended for lab testing and educational purposes **only**. Using it against networks or devices without explicit permission is illegal and unethical. The author is **not responsible** for any misuse.

---

## Table of Contents

1. [Features](#features)  
2. [Working](#working)  
3. [Prerequisites](#prerequisites)  
4. [Installation](#installation)  
5. [Folder & File Structure](#folder--file-structure)  
6. [Usage](#usage)  
7. [Cleanup & Security](#cleanup--security)  
8. [Disclaimer](#disclaimer)

---

## Features

- Fully automated Evil Twin AP setup with hostapd.  
- Live deauthentication attack to force clients to reconnect.  
- Captive portal with live PHP request monitoring.  
- Logs every portal visit and password attempt.  
- Password verification against WPA/WPA2 handshake files using `aircrack-ng`.  
- Automatic cleanup of services and terminals after successful capture.  
- Saves successfully captured passwords in organized files.  
- Multi-terminal visualization for monitoring attack in real-time.

---

## Working

EvilTwinX follows these steps:

1. **Monitor Mode & Network Scan:**  
   Enables monitor mode on the wireless interface (`wlan0`) and scans nearby networks. User selects the target BSSID, channel, and SSID.

2. **Handshake Capture:**  
   Launches `airodump-ng` to capture WPA/WPA2 handshake packets, while sending deauthentication packets with `aireplay-ng` to force reconnections.

3. **Evil Twin Setup:**  
   Configures `hostapd` to broadcast a rogue access point with the same SSID as the target network.

4. **DNS/DHCP Spoofing:**  
   Uses `dnsmasq` to assign IP addresses and redirect all HTTP traffic to a custom captive portal.

5. **Captive Portal & Password Logging:**  
   Runs a PHP-based portal to simulate Wi-Fi login. Logs requests and password attempts in real-time.

6. **Password Verification:**  
   Continuously verifies submitted passwords against the captured handshake using `aircrack-ng`. Upon success, it stores the password in a separate file.

7. **Automatic Cleanup:**  
   All services, terminals, and network configurations are cleaned up once the correct password is captured.

---

## Prerequisites

EvilTwinX requires the following installed on a Linux system (tested on **Kali Linux**):

- `aircrack-ng`  
- `aireplay-ng`  
- `airodump-ng`  
- `hostapd`  
- `dnsmasq`  
- `php` (for captive portal, built-in PHP server)  
- `iptables`  
- `gnome-terminal`  

### Using Two Wi-Fi Adapters

EvilTwinX supports setups with **two Wi-Fi adapters**, which is recommended for better reliability:

1. **Adapter 1:** Used exclusively for **monitor mode and deauthentication attacks**.  
   - Must support monitor mode and packet injection.  
   - Typically connected as `wlan0`.  
   - Handles scanning, handshake capture, and sending deauth packets.

2. **Adapter 2:** Used for **broadcasting the Evil Twin AP and running the captive portal**.  
   - Must support AP mode (master mode).  
   - Typically connected as `wlan1`.  
   - Hosts the rogue access point, runs DHCP/DNS (`dnsmasq`), and serves the captive portal.  

**Configuration Tips:**

- Make sure both adapters are recognized by Linux (`iwconfig` or `ip link`).  
- Assign the first adapter to `wlan0` and the second to `wlan1` in the script.  
- Verify driver support (`airmon-ng check <interface>` for monitor mode, `hostapd` compatibility for AP mode).  
- Using separate adapters avoids disconnecting the fake AP while performing deauth attacks.  

**Example:**

```bash
# wlan0 -> used for deauth & handshake capture
# wlan1 -> used for Evil Twin AP & captive portal
sudo ./eviltwinx.sh
```

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/devsharma-soc/EvilTwinX.git
cd EvilTwinX
```

2. Make the script executable:

```bash
chmod +x eviltwinx.sh
```

3. Ensure prerequisites are installed:

```bash
sudo apt update
sudo apt install -y aircrack-ng hostapd dnsmasq php gnome-terminal
```

4. Run the script as root:

```bash
sudo ./eviltwinx.sh
```

---

## Folder & File Structure

```
EvilTwinX/
├── eviltwinx.sh         # Main attack script
├── cleanup.sh           # Manual-cleanup script (if eviltwinx.sh exits unexpectedly)
├── portal/              # Captive portal files
│   ├── index.php        # Portal frontend & logging
│   ├── captured.txt     # Temporary file storing attempted passwords
│   ├── requests.log     # Logs all HTTP requests
│   └── attempts.log     # Logs all submitted password attempts
├── handshakes/          # Directory for captured WPA/WPA2 handshakes
│   └── <SSID>/          # Subdirectory per target network
├── logs/                # Optional additional logs
└── captured_passwords/  # Stores successfully cracked passwords per SSID
```

---

## Usage

1. Run the script and follow on-screen prompts to select the target network.

2. The script opens multiple gnome-terminal windows:

   * Handshake capture
   * Deauth attack
   * Evil Twin AP
   * DNS/DHCP service
   * Captive portal
   * Live log monitor

3. Monitor portal requests in real-time and wait for the target device to submit a password.

4. The script will verify passwords automatically and save the correct one in `captured_passwords/<SSID>.txt`.

5. All services will be automatically stopped once the password is captured.

---

## Cleanup & Security

- Automatically stops all terminals and background processes after success.  
- Flushes iptables rules and restores network interfaces.  
- Clears temporary files from previous runs to avoid conflicts.  

### Using `cleanup.sh`

In case the script exits unexpectedly or you need to manually terminate services, run:

```bash
sudo ./cleanup.sh
```

This script will safely:

* Kill all background services (hostapd, dnsmasq, php server, deauth and capture processes).
* Flush iptables rules.
* Restore wireless interfaces to normal managed mode.
* Remove temporary configuration and log files created by EvilTwinX.

---

## Future Enhancements

EvilTwinX is a lab-focused PoC, but the following features could be implemented in future versions to improve usability, reliability, and realism:

- **Automated Target Selection:** Automatically detect and select target devices based on activity, signal strength, or connected clients.  
- **Improved Captive Portal:** More realistic Wi-Fi login portal templates for phishing simulation.  
- **Multi-Platform Support:** Add support for other Linux distributions beyond Kali Linux.  
- **Customizable Deauth Settings:** Option to configure deauth packet intervals, number of packets, or selective targeting.  
- **Enhanced Logging:** Centralized and timestamped logs for all captured credentials, portal requests, and deauth activity.  
- **Notification System:** Real-time alerts for successful password capture or critical events.  
- **Modular Adapter Management:** Support for more than two Wi-Fi adapters, distributing tasks across devices for:
  - Sending deauth packets on both 2.4 GHz and 5 GHz networks simultaneously,  
  - Broadcasting multiple Evil Twin APs to prevent the victim from switching networks.  
- **Integration with Password Cracking Tools:** Automatically run captured passwords through additional cracking utilities for testing and reporting.  
- **GUI Frontend:** Optional graphical interface for easier control and monitoring of attack workflow.  

---

## Disclaimer

* **Lab use only:** Never run this tool against networks or devices without explicit authorization.
* **Legal consequences:** Unauthorized Wi-Fi access is illegal and can result in criminal charges.
* **Educational purposes:** Designed to teach penetration testing techniques in controlled environments.
* **No liability:** Author is not responsible for misuse or legal actions arising from the tool.

---

## Contribution

Contributions and improvements are welcome! Please submit pull requests or issues for bugs, new features, or documentation enhancements.

---

## License

This project is **for educational purposes** only. Please contact the author for licensing queries.
