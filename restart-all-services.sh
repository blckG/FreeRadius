sudo systemctl restart freeradius.service
ipsec restart
#service openvpn restart
systemctl daemon-reload
systemctl restart openvpn@server
systemctl enable openvpn@server
