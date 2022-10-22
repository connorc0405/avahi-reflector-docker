This image contains an avahi daemon instance set up for reflecting mDNS queries.  This is useful in situations where you want to want to use devices across VLANs which are discovered using mDNS (e.g. Chromecast).

To set this up, you first need to create sub-interfaces for your network adapter(s).  One adapter is all that is needed.
Here's a corresponding netplan config (located at /etc/netplan/\<filename\>.yaml):

```
network:
  ethernets:
    enp1s0:
      dhcp4: true
  version: 2

  vlans:
    enp1s0.10:
      id: 10
      link: enp1s0
      dhcp4: true
    enp1s0.20:
      id: 20
      link: enp1s0
      dhcp4: true
```

Apply this configuration with `sudo netplan apply`.

Below is an example docker compose YAML file.  You must create a MACVLAN network for each interface you want to reflect mDNS traffic to/from.  This example config makes use of the two VLANs, 10 and 20, that we created with Netplan.

```
version: "3.9"
services:
  avahi:
    image: avahi:latest
    build: .
    ports:
      - "5353:5353"
    networks:
      vlan10:
        ipv4_address: 192.168.10.2
      vlan20:
        ipv4_address: 192.168.20.2
    restart: always

networks:
  vlan10:
    driver: macvlan
    driver_opts:
      parent: enp1s0.10
    ipam:
      driver: default
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
  vlan20:
    driver: macvlan
    driver_opts:
      parent: enp1s0.20
    ipam:
      driver: default
      config:
        - subnet: 192.168.20.0/24
          gateway: 192.168.20.1
```
