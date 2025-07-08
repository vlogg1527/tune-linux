# ⚡ Linux Performance Tuner

Linux Performance Tuner คือชุดสคริปต์อัตโนมัติสำหรับปรับแต่ง Linux ให้เหมาะสมกับการใช้งานหนัก เช่น Streaming, Server รองรับโหลดสูง, การเร่ง IO, Network, CPU และ Disk

## ✅ Features

- ปรับแต่ง sysctl.conf เพื่อเพิ่ม performance
- จูน I/O Scheduler สำหรับ NVMe/SSD
- เพิ่ม TCP connection และ tune network stack
- ตั้งค่าความเหมาะสมกับ Server ที่มี concurrent users จำนวนมาก
- ปรับค่า swappiness, dirty_ratio, และ virtual memory ให้เหมาะกับ HLS/Streaming
- รองรับระบบ Ubuntu 20.04/22.04, Debian, CentOS
- 🔥 ตัวอย่างไฟล์ nginx.conf สำหรับโหลดสูงและ HLS Streaming

## ⚙️ วิธีใช้งาน

### 1. Clone โปรเจกต์นี้
```bash
git clone https://github.com/vlogg1527/tune-linux.git
cd tune-linux
```

### 2. รันสคริปต์จูนระบบ
```bash
sudo bash tune.sh
```



🛠 วิธีใช้งาน: tune-hls-streaming.sh
```bash
bash
chmod +x tune-hls-streaming.sh
sudo ./tune-hls-streaming.sh
```


> ⚠️ **ควรทำ backup ก่อนใช้งาน**

## 🧠 สิ่งที่ปรับแต่ง

### Network (sysctl)
- เพิ่ม `tcp_max_syn_backlog`, `somaxconn`, `tcp_tw_reuse`
- ลด latency โดยการเพิ่ม `tcp_fin_timeout` และ `tcp_keepalive`

### Disk / IO
- ปรับ I/O scheduler เป็น `none` หรือ `mq-deadline` สำหรับ NVMe
- ลด write-back delay ด้วย dirty_ratio/dirt_background_ratio

### Memory
- ลด `swappiness` เพื่อให้ใช้ RAM ก่อน swap
- เพิ่ม `min_free_kbytes` ให้ระบบเสถียรเมื่อโหลดสูง

### NGINX Config (สำหรับ HLS และโหลดสูง)
- ตัวอย่าง nginx.conf ปรับค่า buffer, connection, cache, gzip และระบบไฟล์
- แนะนำให้ใช้คู่กับระบบ Streaming หรือ Reverse Proxy เพื่อรองรับผู้ใช้จำนวนมาก
- ใช้ `worker_connections`, `proxy_buffers`, `open_file_cache` และ `gzip` อย่างเหมาะสม

> 🔧 ตัวอย่างไฟล์ `nginx.conf` มีให้ดาวน์โหลดในโฟลเดอร์นี้

## 📄 License

MIT

## 🙋‍♂️ ผู้พัฒนา

- [@vlogg1527](https://github.com/vlogg1527)

---

✨ หากคุณใช้แล้วมีปัญหา หรืออยากเสนอปรับปรุง สามารถเปิด Issue ได้เลย!
