# raspberry-pi-vpn-router
Raspberry Pi VPN Router Setup


Steps:

1. Flash a new image of Raspbian to a fresh card via the official Raspberry Pi Imager utility. 
  https://www.raspberrypi.org/blog/raspberry-pi-imager-imaging-utility/

2. Plugin wired ethernet.

3. Do first boot on the raspberry pi. Follow the graphical prompts, skip updating packages or setting up the wifi client. 

4. Become root `sudo su`

5. `./installWifi`

6. Login to new dev hotspot with:
   Network SSID: Dev10101010
   Password: testertester
