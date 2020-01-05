<p align="center">
    <a href="https://nordvpn.com/"><img src="https://github.com/bubuntux/nordvpn/raw/master/NordVpn_logo.png"/></a>
    </br>
    <a href="https://github.com/bubuntux/nordvpn/blob/master/LICENSE"><img src="https://badgen.net/github/license/bubuntux/nordvpn?color=cyan"/></a>
    <a href="https://cloud.docker.com/u/bubuntux/repository/docker/bubuntux/nordvpn"><img src="https://images.microbadger.com/badges/image/bubuntux/nordvpn.svg"/></a>
    <a href="https://cloud.docker.com/u/bubuntux/repository/docker/bubuntux/nordvpn"><img src="https://badgen.net/docker/pulls/bubuntux/nordvpn?icon=docker&label=pulls"/></a>
    <a href="https://cloud.docker.com/u/bubuntux/repository/docker/bubuntux/nordvpn"><img src="https://badgen.net/docker/stars/bubuntux/nordvpn?icon=docker&label=stars"/></a>
    <a href="https://github.com/bubuntux/nordvpn"><img src="https://badgen.net/github/forks/bubuntux/nordvpn?icon=github&label=forks"/></a>
    <a href="https://github.com/bubuntux/nordvpn"><img src="https://badgen.net/github/stars/bubuntux/nordvpn?icon=github&label=stars"/></a>
    <a href="https://cloud.docker.com/repository/docker/bubuntux/nordvpn/builds"><img src="https://badgen.net/github/status/bubuntux/nordvpn"/></a>
</p>

NordVpn official client in a docker. It makes routing containers' traffic through NordVpn easy.

# Supported Architectures

This image use [docker manifest for multi-platform awareness](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list), simply pulling `bubuntux/nordvpn` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

| Architecture      | Tag | 
| :----:            | :---: | 
| Linux x86-64      | amd64-latest | 
| Linux x86/i686    | i386-latest |
| ARMv8 64-bit      | aarch64-latest | 
| ARMv7 32-bit      | armv7hf-latest | 

# How to use this image

This container was designed to be started first to provide a connection to other containers (using `--net=container:vpn`, see below *Starting an NordVPN client instance*).

**NOTE**: More than the basic privileges are needed for NordVPN. With docker 1.2 or newer you can use the `--cap-add=NET_ADMIN` and `--device /dev/net/tun` options. Earlier versions, or with fig, and you'll have to run it in privileged mode.

## Starting an NordVPN instance

    docker run -ti --cap-add=NET_ADMIN --device /dev/net/tun --name vpn \
                -e USER=user@email.com -e PASS='pas$word' \
                -e COUNTRY=country -e CATEGORY=category \
                -e PROTOCOL=protocol -d bubuntux/nordvpn

Once it's up other containers can be started using it's network connection:

    docker run -it --net=container:vpn -d some/docker-container

## Local Network access to services connecting to the internet through the VPN.

The environment variable NETWORK must be your local network that you would connect to the server running the docker containers on. Running the following on your docker host should give you the correct network: `ip route | awk '!/ (docker0|br-)/ && /src/ {print $1}'`

    docker run -ti --cap-add=NET_ADMIN --device /dev/net/tun --name vpn \
                -p 8080:80 -e NETWORK=192.168.1.0/24 \ 
                -e USER=user@email.com -e PASS='pas$word' -d bubuntux/nordvpn                

Now just create the second container _without_ the `-p` parameter, only inlcude the `--net=container:vpn`, the port should be declare in the vpn container.

    docker run -ti --rm --net=container:vpn -d bubuntux/riot-web

now the service provided by the second container would be available from the host machine (http://localhost:8080) or anywhere inside the local network (http://192.168.1.xxx:8080).

## docker-compose

```
version: "3"
services:
  vpn:
    image: bubuntux/nordvpn
    cap_add:
      - net_admin
    devices:
      - /dev/net/tun
    environment:
      - USER=user@email.com
      - PASS='pas$word'
      - COUNTRY=United_States
      - PROTOCOL=UDP
      - CATEGORY=P2P
      - NETWORK=192.168.1.0/24
      - OPENVPN_OPTS=--pull-filter ignore "ping-restart" --ping-exit 180
      - TZ=America/Denver
    ports:
      - 8080:80
    restart: unless-stopped
  
  web:
    image: nginx
    network_mode: service:vpn
```


## Killswitch
All traffic going through the container is router to the vpn (unless whitelisted), If connection to the vpn drops your connection to the internet stays blocked until the VPN tunnel is restored. THIS IS THE DEFAULT BEHAVIOUR AND CAN NOT BE DISABLE.

# ENVIRONMENT VARIABLES

 * `USER`     - User for NordVPN account.
 * `PASS`     - Password for NordVPN account, surrounding the password in single quotes will prevent issues with special characters such as `$`.
 * `CONNECT`  -  [country]/[server]/[country_code]/[city]/[group] or [country] [city] 
   - Provide a [country] argument to connect to a specific country. For example: Australia
   - Provide a [server] argument to connecto to a specific server. For example: jp35
   - Provide a [country_code] argument to connect to a specific country. For example: us
   - Provide a [city] argument to connect to a specific city. For example: 'Hungary Budapest'
   - Provide a [group] argument to connect to a specific servers group. For example: Onion_Over_VPN
   - --group value, -g value  Specify a server group to connect to
 * `TECHNOLOGY` - OpenVPN or NordLynx.
 * `PROTOCOL`   - TCP or UDP (only valid when using OpenVPN).
 * `OBFUSCATE`  - When enabled, this feature allows to bypass network traffic sensors which aim to detect usage of the protocol and log, throttle or block it (only valid when using OpenVpn, values: enable or disable). 
 * `CYBER_SEC`  - When enabled, the CyberSec feature will automatically block suspicious websites so that no malware or other cyber threats can infect your device. Additionally, no flashy ads will come into your sight. More information on how it works: https://nordvpn.com/features/cybersec/ (values: enable or disable).
 * `DNS` -   Can set up to 3 DNS servers  (0.0.0.0 1.1.1.1 or disable).
 * `SUBNET` - CIDR networks (IE 192.168.1.0/24), add a route to allows replies once the VPN is up.
 * `DEBUG`    - Set to 'on' for troubleshooting (User and Pass would be log, so use it carefully)

# Issues

If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/bubuntux/nordvpn/issues).
