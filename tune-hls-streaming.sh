#!/bin/bash

echo "📺 จูนระบบสำหรับ HLS/Streaming Server โดยเฉพาะ..."

USER_NAME=$(whoami)

# 1. เพิ่ม limits.conf
if ! grep -q "$USER_NAME.*nofile" /etc/security/limits.conf; then
  echo "$USER_NAME soft nofile 1048576" | sudo tee -a /etc/security/limits.conf
  echo "$USER_NAME hard nofile 1048576" | sudo tee -a /etc/security/limits.conf
fi

# 2. PAM limits
sudo grep -qxF 'session required pam_limits.so' /etc/pam.d/common-session || echo 'session required pam_limits.so' | sudo tee -a /etc/pam.d/common-session

# 3. systemd limits
sudo mkdir -p /etc/systemd/system.conf.d
sudo bash -c "cat > /etc/systemd/system.conf.d/ulimit.conf" <<EOF
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=1048576
EOF

# 4. sysctl tuning
sudo bash -c "cat >> /etc/sysctl.conf" <<EOF

# HLS/Streaming Performance
fs.file-max = 2097152
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq

# Memory tuning
vm.swappiness = 10
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.min_free_kbytes = 65536

# Disable Transparent HugePages
vm.nr_hugepages = 0
EOF

sudo sysctl -p

# 5. ปิด Transparent HugePages
if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]]; then
  echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
fi

# 6. ตรวจสอบ BBR
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
  echo "✅ BBR พร้อมใช้งาน"
else
  echo "⚠️ Kernel นี้ไม่รองรับ BBR โปรดตรวจสอบด้วยคำสั่ง: uname -r"
fi

# 7. รีโหลด systemd
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# 8. สรุป
echo ""
echo -e "\033[1;32m🎉 จูนระบบสำหรับ HLS เสร็จสิ้น กรุณา reboot:\033[0m"
echo -e "\033[1;36m👉 sudo reboot\033[0m"
