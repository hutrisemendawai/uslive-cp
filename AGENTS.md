# Arsitektur & Desain Agents (System & AI)

Untuk membuat aplikasi komunikasi internal yang scalable dan cerdas (setara MS Teams dengan fitur AI), arsitektur perlu dilengkapi dengan sistem **Agents**. Agents ini berjalan di backend (sebagai microservices atau background workers) terpisah dari API utama agar tidak membebani jalur *signaling* dan *chat*.

Berikut adalah rancangan agen-agen yang terintegrasi dengan arsitektur LiveKit, Redis, dan PostgreSQL Anda.

---

## 1. AI Agents (Produktivitas & Cerdas)

Agen ini berinteraksi langsung dengan data pengguna (audio/teks) untuk memberikan nilai tambah berbasis Artificial Intelligence (NLP/LLM).

### A. Meeting Assistant & Summarizer Agent
*   **Peran:** Mengikuti *video/voice meeting* untuk membuat notulensi otomatis, transkripsi, dan daftar *Action Items*.
*   **Cara Kerja (Integrasi LiveKit):** 
    1. Saat meeting dimulai, agen ini bergabung ke LiveKit Room sebagai *hidden participant* (peserta tanpa video).
    2. Agen menerima *audio stream* dari LiveKit SFU.
    3. Audio diproses menggunakan model *Speech-to-Text* (STT) seperti Whisper secara *real-time* atau *post-processing*.
    4. Teks transkripsi dikirim ke LLM (Large Language Model) untuk dirangkum.
    5. Hasil rangkuman disimpan ke tabel `messages` di PostgreSQL (dengan `type: 'FILE'` atau teks panjang) di dalam *conversation_id* meeting tersebut.
*   **Tech Stack:** Python, LiveKit Python SDK, OpenAI API / Local LLM (Ollama), Redis (untuk antrean tugas).

### B. Internal Knowledge Chatbot (RAG Agent)
*   **Peran:** Menjawab pertanyaan karyawan terkait HR, IT Support, atau SOP perusahaan langsung di dalam ruang *Direct Message*.
*   **Cara Kerja:**
    1. Agen memiliki akun di tabel `users` (misal: "IT Support Bot").
    2. Mendengarkan (subscribe) ke Redis Pub/Sub untuk pesan yang masuk ke *conversation_id* miliknya, atau yang me-*mention* namanya (misal: `@HRBot`).
    3. Menggunakan teknik RAG (*Retrieval-Augmented Generation*) untuk mencari dokumen SOP di *Vector Database* (bisa menggunakan pgvector di PostgreSQL).
    4. Mengirimkan balasan via WebSocket API layaknya pengguna biasa.

### C. Smart Triage / Catch-up Agent
*   **Peran:** Merangkum percakapan grup jika pengguna sudah *offline* terlalu lama dan melewatkan ratusan pesan.
*   **Cara Kerja:**
    1. Saat Flutter client mengirim sinyal *online*, sistem mengecek `last_read_message_id`.
    2. Jika selisih pesan > 50, klien memicu REST API untuk meminta rangkuman.
    3. Agen membaca riwayat teks dari PostgreSQL, merangkumnya dengan LLM, dan mengembalikannya ke klien tanpa menyimpannya secara permanen ke database utama.

---

## 2. System Agents (Background Workers)

Agen infrastruktur ini bertugas menjaga performa, melakukan pembersihan, dan memproses *heavy-lifting tasks* secara asinkron.

### A. Media Processing & Transcoding Agent
*   **Peran:** Mengelola rekaman meeting (Recording) dan lampiran file berukuran besar.
*   **Cara Kerja:**
    1. LiveKit Egress diinstruksikan untuk merekam *composite video* dan menyimpannya ke MinIO (S3).
    2. Setelah rekaman selesai, webhook LiveKit memicu agen ini.
    3. Agen melakukan kompresi video tambahan (menggunakan FFmpeg) atau men-generate *thumbnail*.
    4. Memperbarui tabel `meetings` di PostgreSQL dengan URL MinIO hasil rekaman dan mengirim notifikasi ke chat grup bahwa rekaman siap.

### B. Presence & Notification Router Agent
*   **Peran:** Mengelola sinkronisasi status *Online/Offline* dan rute notifikasi Push.
*   **Cara Kerja:**
    1. Mendengarkan *heartbeat* WebSocket dari Redis. Jika user terputus tanpa sinyal *logout* (misal: koneksi putus), agen ini menunggu *grace period* (misal: 10 detik).
    2. Jika tetap putus, agen memperbarui status user di Redis menjadi `offline` dan mengupdate `last_seen_at` di PostgreSQL.
    3. Mengambil alih pengiriman pesan tertunda: Jika ada pesan masuk ke pengguna `offline`, agen memformat *payload* FCM (Android) atau APNs (iOS), menambahkan badge count, dan memanggil API Firebase/Apple.

### C. Data Archiving & Cleanup Agent
*   **Peran:** Menjaga agar database PostgreSQL (tabel `messages`) tidak membengkak dan memakan terlalu banyak memori.
*   **Cara Kerja:**
    1. Berjalan sebagai *Cron Job* (misal: setiap jam 2 pagi).
    2. Memindahkan pesan *chat* yang berusia lebih dari 1 tahun ke *Cold Storage* (tabel arsip atau file log di MinIO), tergantung kebijakan retensi data perusahaan.
    3. Membersihkan cache sesi yang *stale* atau token LiveKit yang sudah kedaluwarsa di Redis.

---

## 3. Alur Komunikasi Agents dengan Core System

Agar tidak terjadi *bottleneck*, Agents menggunakan pola **Event-Driven**:

```text
[Flutter Client] 
   └─> (WebSocket/REST) 
          └─> [Backend (Spring/Go)] 
                 ├─> [PostgreSQL] (Simpan Data)
                 └─> [Redis Pub/Sub atau Message Queue (RabbitMQ/Kafka)]
                          │
                          ├─> Mengkonsumsi Event ──> [AI RAG Bot] 
                          ├─> Mengkonsumsi Event ──> [Notification Agent]
                          └─> Mengkonsumsi Event ──> [Media Processing Agent]
```
*   **Keuntungan:** Backend utama (Go/Spring Boot) akan merespons pesan pengguna dalam hitungan milidetik karena tugas berat diserahkan ke *Message Broker* (Redis/RabbitMQ) untuk dieksekusi oleh Agents secara terpisah.