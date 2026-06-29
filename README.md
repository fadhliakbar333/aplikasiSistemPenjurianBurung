# 🦜 Sistem Penjurian Burung Berbasis Web

## Deskripsi

Sistem Penjurian Burung merupakan aplikasi berbasis web yang dirancang untuk membantu penyelenggaraan lomba burung berkicau secara digital. Aplikasi ini memudahkan panitia dalam mengelola event, peserta, juri, operator, dan proses penilaian sehingga hasil lomba menjadi lebih cepat, akurat, transparan, dan terdokumentasi dengan baik.

---

# Fitur Utama

## 🔐 Autentikasi
- Login
- Register
- Verifikasi Email
- Lupa Password
- Ganti Password
- Role Based Access Control

## 👤 Peserta
- Registrasi akun
- Melihat daftar event
- Mendaftar event
- Melihat detail event
- Melihat detail sesi
- Instruksi pembayaran
- Upload bukti pembayaran
- Riwayat pendaftaran
- Mengelola profil

## 👨‍⚖️ Juri
- Dashboard
- Daftar kelas
- Daftar peserta
- Input penilaian
- Edit nilai
- Submit nilai
- Rekap nilai
- Profil

## 👨‍💼 Admin
- Dashboard
- Kelola event
- Kelola peserta
- Kelola juri
- Kelola operator
- Monitoring penilaian
- Finalisasi hasil
- Laporan
- Pengaturan sistem

## 👷 Operator
- Dashboard
- Validasi peserta
- Check-in peserta
- Pengaturan nomor gantangan
- Monitoring sesi lomba

## 📊 Laporan
- Rekap nilai
- Ranking peserta
- Export PDF
- Export Excel
- Cetak sertifikat

---

# Role Pengguna

## Admin
Admin memiliki hak akses penuh terhadap seluruh sistem.

Hak akses:
- Mengelola pengguna
- Mengelola event
- Mengelola kategori lomba
- Mengelola sesi
- Mengelola peserta
- Mengelola juri
- Mengelola operator
- Monitoring lomba
- Finalisasi hasil
- Mencetak laporan

---

## Juri

Juri bertugas memberikan penilaian kepada peserta berdasarkan kelas yang telah ditentukan.

Hak akses:
- Login
- Melihat daftar kelas
- Melihat daftar peserta
- Memberikan nilai
- Mengubah nilai sebelum submit
- Submit nilai
- Melihat hasil penilaian

---

## Operator

Operator membantu jalannya perlombaan di lapangan.

Hak akses:
- Validasi peserta
- Check-in peserta
- Pengaturan gantangan
- Monitoring sesi
- Membantu admin

---

## Peserta

Peserta menggunakan aplikasi untuk mengikuti perlombaan.

Hak akses:
- Registrasi
- Login
- Melihat event
- Mendaftar lomba
- Melakukan pembayaran
- Upload bukti pembayaran
- Melihat hasil lomba
- Mengelola profil

---

# Struktur Folder

```text
project/
│
├── admin/
│   ├── dashboard/
│   ├── event/
│   ├── peserta/
│   ├── juri/
│   ├── operator/
│   ├── laporan/
│   └── setting/
│
├── peserta/
│   ├── dashboard/
│   ├── event/
│   ├── sesi/
│   ├── pembayaran/
│   ├── profile/
│   └── history/
│
├── juri/
│   ├── dashboard/
│   ├── kelas/
│   ├── peserta/
│   ├── penilaian/
│   ├── rekap/
│   └── profile/
│
├── operator/
│   ├── dashboard/
│   ├── checkin/
│   ├── gantangan/
│   ├── monitoring/
│   └── profile/
│
├── auth/
│   ├── login/
│   ├── register/
│   ├── verify-email/
│   ├── forgot-password/
│   └── reset-password/
│
├── models/
├── controllers/
├── middleware/
├── routes/
├── config/
├── database/
├── uploads/
├── public/
├── package.json
└── README.md
```

---

# Screen Aplikasi

## Autentikasi
- Login
- Register
- Verifikasi Email
- Lupa Password
- Ganti Password

## Peserta
- Dashboard
- Event Detail
- Sesi Detail
- Instruksi Pembayaran
- Upload Bukti Pembayaran
- Riwayat Pendaftaran
- Profil

## Juri
- Dashboard
- Daftar Kelas
- Detail Peserta
- Penilaian
- Rekap Nilai
- Profil

## Admin
- Dashboard
- Kelola Event
- Kelola Peserta
- Kelola Juri
- Kelola Operator
- Laporan
- Pengaturan

## Operator
- Dashboard
- Validasi Peserta
- Check-in
- Monitoring Lomba

---

# Alur Sistem

1. Peserta membuat akun.
2. Sistem mengirim email verifikasi.
3. Peserta melakukan verifikasi email.
4. Peserta login.
5. Peserta memilih event.
6. Peserta memilih kelas lomba.
7. Sistem menampilkan instruksi pembayaran.
8. Peserta melakukan pembayaran.
9. Peserta mengunggah bukti pembayaran.
10. Admin memverifikasi pembayaran.
11. Operator melakukan check-in peserta.
12. Admin memulai sesi lomba.
13. Juri melakukan penilaian.
14. Sistem menghitung nilai secara otomatis.
15. Admin melakukan finalisasi hasil.
16. Hasil dipublikasikan kepada peserta.

---

# Teknologi yang Digunakan

## Frontend
- HTML5
- CSS3
- JavaScript
- Bootstrap 5

## Backend
- Node.js
- Express.js

## Database
- MongoDB

## Authentication
- JWT (JSON Web Token)
- bcrypt

## Upload File
- Multer

---

# Instalasi

## Clone Repository

```bash
git clone https://github.com/username/sistem-penjurian-burung.git
```

Masuk ke folder project.

```bash
cd sistem-penjurian-burung
```

Install dependency.

```bash
npm install
```

Buat file `.env`.

```env
PORT=5000

MONGODB_URI=mongodb://localhost:27017/penjurian_burung

JWT_SECRET=your_secret_key

EMAIL_USER=your_email@gmail.com

EMAIL_PASS=your_app_password
```

Jalankan server.

```bash
npm run dev
```

atau

```bash
npm start
```

---

# Modul Penilaian

Contoh kriteria penilaian:

- Irama Lagu
- Volume
- Durasi Kerja
- Variasi Lagu
- Gaya
- Mental
- Konsistensi

Sistem akan menghitung nilai dari seluruh juri secara otomatis untuk menghasilkan total nilai, peringkat, dan juara.

---

# Keamanan

- Password dienkripsi menggunakan bcrypt.
- Login menggunakan JWT Authentication.
- Verifikasi email saat registrasi.
- Reset password melalui email.
- Role Based Access Control (RBAC).
- Validasi data pada sisi client dan server.

---

# Pengembangan Selanjutnya

- Live Scoring
- WebSocket
- QR Code Check-in
- Push Notification
- Dashboard Statistik
- QRIS Payment
- Progressive Web App (PWA)
- Mobile Apps (Android & iOS)
- Integrasi AI untuk analisis performa burung

---

# Lisensi

Project ini dibuat untuk keperluan pembelajaran, penelitian, dan pengembangan sistem informasi. Silakan digunakan dan dikembangkan sesuai kebutuhan dengan tetap mencantumkan atribusi kepada pengembang.
