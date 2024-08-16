#/bin/bash

# TODO: detect it automaticly
OS="macos"

if [ $OS == "macos" ]; then
    PF_FILE="/etc/pf.anchors/nginx.local"

    echo 'rdr pass on lo0 inet proto tcp from any to self port 80  -> 127.0.0.1 port 9998' >  ${PF_FILE}
    echo 'rdr pass on lo0 inet proto tcp from any to self port 443 -> 127.0.0.1 port 9999' >> ${PF_FILE}

    sysctl -w net.inet.ip.forwarding=1
    pfctl -F nat
    pfctl -e
    pfctl -f ${PF_FILE}
    pfctl -s nat
    # pfctl -s states
else
    iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 9998
    iptables -t nat -A OUTPUT -o lo -p tcp --dport 443 -j REDIRECT --to-port 9999
fi
