# 🦜 Sistem Penjurian Burung

Aplikasi berbasis web untuk mengelola perlombaan burung berkicau secara digital, mulai dari pendaftaran peserta, pembayaran, penjurian, hingga pengumuman hasil lomba.

---

## 📱 Fitur Utama

### 🔐 Autentikasi
- Login
- Register
- Verifikasi Email
- Lupa Password
- Ganti Password

### 👤 Peserta
- Dashboard
- Daftar Event
- Detail Event
- Detail Sesi
- Instruksi Pembayaran
- Upload Bukti Pembayaran
- Riwayat Pendaftaran
- Profil

### 👨‍⚖️ Juri
- Dashboard
- Daftar Kelas
- Daftar Peserta
- Penilaian
- Rekap Nilai
- Profil

### 👨‍💼 Admin
- Dashboard
- Kelola Event
- Kelola Peserta
- Kelola Juri
- Kelola Operator
- Laporan
- Pengaturan

### 👷 Operator
- Dashboard
- Validasi Peserta
- Check-in
- Monitoring Lomba

---

## 👥 Role

### 👨‍💼 Admin
- Kelola Event
- Kelola Peserta
- Kelola Juri
- Kelola Operator
- Monitoring Penilaian
- Finalisasi Hasil
- Laporan

### 👨‍⚖️ Juri
- Melihat Kelas
- Input Nilai
- Edit Nilai
- Submit Nilai
- Rekap Nilai

### 👷 Operator
- Validasi Peserta
- Check-in
- Monitoring Sesi

### 👤 Peserta
- Daftar Event
- Pembayaran
- Upload Bukti
- Lihat Hasil

---

## 📂 Struktur Folder

```
project/
├── admin/
├── peserta/
├── juri/
├── operator/
├── auth/
├── models/
├── controllers/
├── middleware/
├── routes/
├── database/
├── config/
├── uploads/
├── public/
└── README.md
```

---

## 📱 Screen

### 🔐 Auth
- Login
- Register
- Verify Email
- Forgot Password
- Reset Password

### 👤 Peserta
- Dashboard
- Event Detail
- Session Detail
- Payment
- Upload Payment
- History
- Profile

### 👨‍⚖️ Juri
- Dashboard
- Kelas
- Peserta
- Penilaian
- Rekap

### 👨‍💼 Admin
- Dashboard
- Event
- Peserta
- Juri
- Operator
- Laporan

### 👷 Operator
- Dashboard
- Check-in
- Monitoring

---

## 🔄 Alur Sistem

```
Register
    ↓
Verifikasi Email
    ↓
Login
    ↓
Pilih Event
    ↓
Pilih Kelas
    ↓
Pembayaran
    ↓
Upload Bukti
    ↓
Verifikasi Admin
    ↓
Check-in
    ↓
Penjurian
    ↓
Perhitungan Nilai
    ↓
Finalisasi
    ↓
Hasil Lomba
```

---

## 🛠️ Teknologi

**Frontend**
- HTML
- CSS
- JavaScript
- Bootstrap 5

**Backend**
- Node.js
- Express.js

**Database**
- MongoDB

**Authentication**
- JWT
- bcrypt

---

## 🚀 Instalasi

Clone repository

```bash
git clone https://github.com/username/sistem-penjurian-burung.git
```

Masuk ke folder

```bash
cd sistem-penjurian-burung
```

Install dependency

```bash
npm install
```

Jalankan aplikasi

```bash
npm run dev
```

---

## 🔒 Keamanan

- JWT Authentication
- Password Hashing (bcrypt)
- Email Verification
- Reset Password
- Role Based Access Control

---

## 📄 Lisensi

Project ini dibuat untuk keperluan pembelajaran dan pengembangan sistem informasi.
