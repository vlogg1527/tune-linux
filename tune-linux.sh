#!/bin/bash

echo "🔧 กำลังตั้งค่าระบบให้รองรับโหลดพร้อมกันสูง..."

USER_NAME=$(whoami)

# 1. เพิ่ม ulimit
echo "✅ กำลังเพิ่ม limits.conf"
sudo bash -c "cat >> /etc/security/limits.conf" <<EOF
$USER_NAME soft nofile 1048576
$USER_NAME hard nofile 1048576
EOF

# 2. เพิ่ม pam limits
echo "✅ กำลังเพิ่ม pam limits"
sudo grep -qxF 'session required pam_limits.so' /etc/pam.d/common-session || \
echo 'session required pam_limits.so' | sudo tee -a /etc/pam.d/common-session

# 3. systemd limits
echo "✅ กำลังเพิ่ม systemd ulimit"
sudo mkdir -p /etc/systemd/system.conf.d
sudo bash -c "cat > /etc/systemd/system.conf.d/ulimit.conf" <<EOF
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=1048576
EOF

# 4. ปรับ sysctl network
echo "✅ กำลังจูน sysctl network"
sudo bash -c "cat >> /etc/sysctl.conf" <<EOF
fs.file-max = 2097152
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc = fq
EOF

sudo sysctl -p

# 5. รีโหลด systemd
echo "🔁 รีโหลด systemd"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# 6. สรุป
echo ""
echo "🎉 ตั้งค่าเสร็จแล้ว กรุณา reboot เพื่อให้มีผล:"
echo "👉 sudo reboot"
