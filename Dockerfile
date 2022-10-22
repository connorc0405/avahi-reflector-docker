FROM ubuntu:jammy

RUN apt-get update && apt-get install -y avahi-daemon

RUN sed -i "s/#enable-dbus=yes/enable-dbus=no/g" /etc/avahi/avahi-daemon.conf \
    && sed -i "s/#enable-reflector=no/enable-reflector=yes/g" /etc/avahi/avahi-daemon.conf \
    && sed -i "s/#deny-interfaces=eth1/deny-interfaces=lo/g" /etc/avahi/avahi-daemon.conf

CMD ["avahi-daemon"]
