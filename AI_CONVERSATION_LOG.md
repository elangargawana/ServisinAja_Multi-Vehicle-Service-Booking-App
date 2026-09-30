# 📜 AI Conversation Log & Command Prompts

> **Repository:** [ServisinAja — Multi-Vehicle Service Booking App](https://github.com/elangargawana/ServisinAja_Multi-Vehicle-Service-Booking-App)
> **Tujuan:** Dokumentasi lengkap riwayat command prompt yang diberikan selama proses perancangan produk, arsitektur, implementasi Flutter, QA, code review, dan finalisasi UX (seluruh prompt iterasi eksklusif di luar prompt _"lanjutkan"_).

---

## Prompt #1

```text
Saya ingin mengerjakan technical assessment untuk posisi Mobile Developer & UI/UX Designer.

Saya akan memberikan brief berikut sebagai source of truth:

* Platform: Mobile Flutter
* Studi kasus: Aplikasi Booking Service Kendaraan
* Referensi industri: aplikasi booking service kendaraan seperti Honda MotorkuX
* Tantangan utama: Multi-Vehicle Booking
* User dapat melakukan booking beberapa kendaraan dalam satu transaksi.
* Setiap kendaraan dapat memiliki jenis service, pilihan spare part, dan keluhan/catatan yang berbeda.
* Booking harus memiliki bengkel, jadwal kedatangan, estimasi biaya, dan estimasi durasi.
* Setelah booking berhasil, user mendapatkan tiket servis multi-unit dan dapat melihat status masing-masing kendaraan.
* Required flow: Home sampai Booking Success.
* Required: Flutter implementation, public GitHub repository, APK, README, dan Figma.
* Bonus: realistic mock data, state management, responsive/safe layout, clean architecture, dokumentasi design system, dan tambahan screen yang relevan.

Untuk tahap ini JANGAN menulis kode.

Saya ingin Anda bertindak sebagai Product Designer sekaligus Mobile Engineer yang melakukan product discovery terlebih dahulu.

Analisis:

1. Apa masalah utama yang sebenarnya ingin diselesaikan?
2. Siapa user utama aplikasi?
3. Apa user goal?
4. Apa pain point yang muncul dari konsep multi-vehicle booking?
5. Apa risiko UX terbesar?
6. Apa informasi yang harus diketahui user pada setiap tahap booking?
7. Apa yang harus dibuat sederhana agar multi-vehicle booking tidak terasa seperti form panjang?
8. Apa constraint teknis dan UX yang perlu diperhatikan di Flutter mobile?
9. Apa acceptance criteria utama yang harus terpenuhi agar assessment ini dianggap selesai?

Jangan langsung membuat solusi final. Pisahkan antara:

* Requirement eksplisit dari brief
* Requirement implisit
* UX problem
* Technical consideration
* Assumption yang perlu dibuat

Berikan hasil dalam format product discovery document yang nantinya bisa menjadi dasar proses desain dan development.
```

---

## Prompt #2

```text
Berdasarkan hasil product discovery sebelumnya, sekarang saya ingin kita merumuskan strategi UX.

Fokus utama tetap pada masalah:
"Bagaimana membuat booking beberapa kendaraan dalam satu transaksi terasa sederhana, meskipun setiap kendaraan memiliki kebutuhan service yang berbeda?"

Jangan coding terlebih dahulu.

Buat beberapa alternatif pendekatan UX untuk multi-vehicle booking.

Contohnya:

* Sequential configuration
* Card-based vehicle configuration
* Stepper/wizard
* Progressive disclosure
* Hybrid approach

Untuk setiap pendekatan jelaskan:

1. Cara kerja user flow.
2. Kelebihan.
3. Kekurangan.
4. Cognitive load.
5. Jumlah screen yang dibutuhkan.
6. Bagaimana user berpindah dari kendaraan satu ke kendaraan lainnya.
7. Bagaimana mencegah user kehilangan konfigurasi kendaraan sebelumnya.
8. Bagaimana menampilkan total estimasi biaya dan durasi.
9. Bagaimana menangani penambahan kendaraan.
10. Bagaimana pendekatan tersebut diterapkan dengan baik pada mobile screen.

Setelah membandingkan beberapa pendekatan, pilih SATU pendekatan yang paling konsisten dengan requirement assessment.

Namun jangan memberikan ranking berdasarkan "bagus/buruk". Berikan alasan berdasarkan usability, complexity, scalability, dan implementability.

Kemudian definisikan user flow final dari Home sampai Booking Success.
```

---

## Prompt #3

```text
Sekarang kita sudah memiliki konsep UX untuk multi-vehicle booking.

Sebelum masuk ke implementation, saya ingin mendefinisikan information architecture aplikasi.

Buat struktur navigasi dan screen inventory untuk MVP assessment.

Minimal mencakup:

* Home
* Vehicle selection
* Add vehicle
* Vehicle configuration
* Service selection
* Spare part/oli selection
* Complaint/notes
* Workshop selection
* Schedule selection
* Booking summary
* Booking success
* Booking/ticket detail
* Service status tracking

Untuk setiap screen jelaskan:

* Tujuan screen
* Primary user action
* Secondary action
* Informasi yang ditampilkan
* Data yang dibutuhkan
* State yang mungkin terjadi
* Navigation masuk
* Navigation keluar

Pastikan flow tidak terasa seperti form panjang.

Selain happy path, identifikasi edge case penting seperti:

* User memiliki satu kendaraan
* User memiliki beberapa kendaraan
* User menambahkan kendaraan baru
* User menghapus kendaraan
* Dua kendaraan memiliki service berbeda
* Service belum dipilih
* Jadwal belum dipilih
* Data booking belum lengkap
* Estimasi biaya berubah
* Booking berhasil
* Booking gagal

Jangan coding.
```

---

## Prompt #4

```text
Sekarang ubah information architecture tersebut menjadi screen specification yang dapat digunakan oleh UI/UX Designer dan Flutter Developer.

Untuk setiap screen buat spesifikasi:

1. Screen name
2. User goal
3. Layout hierarchy
4. App bar
5. Main content
6. Primary CTA
7. Secondary CTA
8. Card/component yang digunakan
9. Information hierarchy
10. Empty state
11. Loading state
12. Error state
13. Validation
14. Navigation behavior
15. Accessibility consideration

Khusus multi-vehicle booking, jelaskan secara detail bagaimana setiap kendaraan direpresentasikan dalam UI.

Saya ingin interface yang:

* mobile-first
* mudah dipahami
* tidak terasa seperti form administrasi
* memiliki visual hierarchy yang jelas
* konsisten antar screen
* mudah diimplementasikan menggunakan Flutter
* aman terhadap berbagai ukuran layar

Jangan tulis Flutter code dulu.

Output harus cukup detail sehingga UI Designer dapat membuat Figma berdasarkan specification ini dan Developer dapat mengimplementasikannya tanpa menebak-nebak behavior.
```

---

## Prompt #5

```text
Sebelum implementasi Flutter, saya ingin membuat UI design system berdasarkan UX specification yang sudah dibuat.

Gunakan brand identity Servisin Aja sebagai referensi visual, terutama karakter visual dan penggunaan warna oranye, tetapi jangan sekadar meniru website atau aplikasi lain.

Tentukan:

* Color system
* Primary color
* Secondary color
* Background
* Surface
* Text colors
* Success
* Warning
* Error
* Border
* Typography hierarchy
* Font sizes
* Font weights
* Spacing scale
* Border radius
* Elevation/shadow
* Icon style
* Button variants
* Input variants
* Card variants
* Chip/badge
* Bottom navigation jika diperlukan
* App bar
* Bottom sheet
* Dialog
* Loading component
* Empty state
* Error state

Buat design token yang konsisten dan mudah diterjemahkan menjadi Flutter constants/theme.

Fokus pada prinsip:

* consistency
* accessibility
* readability
* touch target
* responsive layout
* visual hierarchy

Jangan coding screen dulu.
```

---

## Prompt #6

```text
UX flow sudah ditentukan. Sekarang saya ingin menerjemahkan product requirement menjadi domain model.

Jangan membuat UI terlebih dahulu.

Identifikasi entity yang diperlukan untuk aplikasi booking service multi-vehicle.

Minimal pertimbangkan:

* User
* Vehicle
* VehicleBrand
* VehicleModel
* Service
* SparePart/Oil
* Complaint
* Workshop
* Schedule
* Booking
* BookingVehicle
* BookingStatus
* ServiceStatus
* PriceEstimate

Jelaskan relationship antar entity.

Kemudian buat:

1. Domain model
2. Mock JSON structure
3. Example realistic data
4. Booking state
5. Vehicle configuration state
6. Service status state

Pastikan model mendukung satu booking dengan banyak kendaraan, di mana masing-masing kendaraan dapat memiliki service, spare part, complaint, estimasi harga, dan status pengerjaan yang berbeda.

Data harus realistic dan cukup kaya untuk mendemonstrasikan UI.
```

---

## Prompt #7

```text
Berdasarkan domain model dan user flow yang sudah dibuat, tentukan strategi state management untuk aplikasi Flutter.

Saya ingin solusi yang:

* mudah dipahami
* scalable untuk assessment
* tidak over-engineered
* mudah dites
* memisahkan UI state dan business state
* mendukung multi-vehicle booking

Evaluasi secara singkat:

* Provider
* Riverpod
* BLoC

Kemudian pilih satu pendekatan berdasarkan kebutuhan aplikasi.

Definisikan state yang diperlukan untuk:

* Home
* Vehicle selection
* Vehicle configuration
* Service selection
* Schedule
* Booking summary
* Booking submission
* Booking success
* Tracking/status

Jelaskan event/action dan state transition yang diperlukan.

Belum perlu implementasi kode.
```

---

## Prompt #8

```text
Sekarang saya ingin menentukan architecture Flutter berdasarkan requirement, UX flow, domain model, dan state management yang sudah disepakati.

Gunakan pendekatan clean architecture yang proporsional untuk technical assessment ini.

Buat struktur folder Flutter yang jelas.

Pisahkan concern seperti:

* core
* shared
* features
* data
* domain
* presentation

Tentukan responsibility setiap layer.

Buat juga:

* naming convention
* model convention
* repository convention
* state management placement
* routing strategy
* theme placement
* asset management
* mock data placement

Pastikan architecture tidak over-engineered.

Tujuan utama:

1. mudah dikembangkan
2. mudah dipahami reviewer
3. scalable
4. maintainable
5. konsisten dengan requirement assessment

Jangan membuat seluruh source code.
Berikan architecture blueprint terlebih dahulu.
```

---

## Prompt #9

```text
Kita sudah menyelesaikan product discovery, UX strategy, information architecture, screen specification, design system, domain model, state management, dan technical architecture.

Sekarang mulai implementasi Flutter secara incremental.

Jangan langsung membuat seluruh aplikasi.

Tahap pertama hanya implementasikan project foundation:

1. Flutter project structure
2. Dependencies
3. Theme
4. Design tokens
5. Typography
6. Color system
7. Spacing
8. Common components
9. Routing foundation
10. Mock data foundation
11. State management foundation

Jangan implementasikan seluruh screen sekaligus.

Setelah selesai, lakukan self-review terhadap:

* architecture
* naming
* dependency choice
* maintainability
* responsive behavior

Kemudian tampilkan file yang dibuat/diubah dan alasan setiap perubahan.
```

---

## Prompt #10

```text
Jika prompt sebelumnya sudah, Sekarang implementasikan feature pertama berdasarkan specification yang sudah kita sepakati:

HOME → VEHICLE SELECTION → ADD VEHICLE.

Scope:

* Home screen
* Vehicle list/selection
* Add vehicle
* Vehicle card
* Empty state
* Validation
* Navigation

Jangan mengimplementasikan screen berikutnya terlebih dahulu.

Prioritaskan:

* pixel consistency terhadap design specification
* responsive layout
* reusable components
* accessibility
* clean code
* realistic mock data
* proper state management

Setelah implementasi:

1. Review UI hierarchy.
2. Review interaction flow.
3. Review responsive behavior.
4. Review state management.
5. Identifikasi potential UX issues.

Jika menemukan masalah, jangan langsung melakukan perubahan besar. Jelaskan masalah dan solusi yang disarankan terlebih dahulu.
```

---

## Prompt #11

```text
Sekarang implementasikan inti product challenge: Multi-Vehicle Booking.

User harus dapat:

* memilih beberapa kendaraan
* menambahkan kendaraan
* mengkonfigurasi kendaraan satu per satu
* memilih service berbeda
* memilih spare part/oli
* memasukkan keluhan/catatan
* kembali ke kendaraan sebelumnya
* melihat status konfigurasi masing-masing kendaraan
* melihat ringkasan seluruh kendaraan

Pastikan konfigurasi Vehicle A tidak hilang ketika user berpindah ke Vehicle B.

Gunakan progressive disclosure agar form tidak terasa terlalu kompleks.

UI harus memberikan indikasi:

* kendaraan mana yang sedang dikonfigurasi
* kendaraan mana yang sudah selesai
* kendaraan mana yang belum lengkap
* total kendaraan
* estimasi biaya
* estimasi durasi

Implementasikan secara incremental.

Jangan membuat seluruh booking flow sekaligus.

Setelah implementasi, lakukan review khusus terhadap cognitive load dan kemungkinan user confusion.
```

---

## Prompt #12

```text
Sekarang implementasikan tahap akhir user journey:

BOOKING SUBMISSION → BOOKING SUCCESS → SERVICE TICKET → SERVICE STATUS.

Booking Success harus terasa sebagai confirmation state yang jelas.

Tampilkan:

* booking number
* workshop
* schedule
* daftar kendaraan
* service masing-masing kendaraan
* estimated cost
* status masing-masing kendaraan

Kemudian buat service tracking yang memungkinkan setiap kendaraan mempunyai status berbeda.

Contoh:
Vehicle A:
Booking Confirmed → Vehicle Received → Inspection → Service → Completed

Vehicle B:
Booking Confirmed → Vehicle Received → Inspection

Jangan membuat tracking hanya sebagai satu status global karena product requirement membutuhkan status pengerjaan masing-masing unit.

Setelah implementasi, review apakah user dapat memahami kondisi setiap kendaraan hanya dengan melihat screen.
```

---

## Prompt #13

```text
Sekarang anggap implementasi MVP sudah selesai.

Jangan menambahkan feature baru terlebih dahulu.

Lakukan design review terhadap seluruh flow:

Home
→ Vehicle Selection
→ Add Vehicle
→ Vehicle Configuration
→ Service
→ Spare Part/Oil
→ Complaint
→ Workshop
→ Schedule
→ Summary
→ Booking Success
→ Ticket
→ Tracking

Evaluasi dari perspektif:

1. User experience
2. Information hierarchy
3. Cognitive load
4. Navigation clarity
5. Consistency
6. Visual hierarchy
7. Error prevention
8. Feedback
9. Accessibility
10. Mobile usability

Identifikasi maksimal 10 improvement dengan impact paling jelas.

Untuk setiap improvement:

* masalah
* penyebab
* solusi
* screen terdampak
* perubahan UI
* perubahan state/logic jika ada

Jangan langsung mengubah code.

Setelah saya menyetujui arah refinement, baru implementasikan perubahan secara bertahap.
```

---

## Prompt #14

```text
Sekarang lakukan QA terhadap aplikasi Flutter yang sudah dibuat.

Fokus pada:

### UI

* overflow
* yellow/black overflow warning
* clipping
* text wrapping
* keyboard behavior
* safe area
* bottom navigation/button
* different Android screen sizes
* portrait layout

### UX

* navigation
* back behavior
* validation
* loading
* empty state
* error state
* success feedback
* data persistence antar step

### Multi-vehicle

* add vehicle
* remove vehicle
* edit vehicle
* switching vehicle
* different service per vehicle
* different complaint per vehicle
* different parts per vehicle
* different status per vehicle
* total price calculation
* total duration calculation

### Architecture

* duplicated code
* unnecessary dependencies
* state management issues
* naming
* component reusability
* clean architecture violations

Jangan hanya mengatakan "sudah bagus".

Temukan potential bugs dan UX problems yang realistis.

Prioritaskan issue berdasarkan:

* functional impact
* user impact
* implementation complexity

Kemudian implementasikan fix satu per satu.
```

---

## Prompt #15

```text
Anggap aplikasi ini akan direview oleh recruiter dan technical reviewer berdasarkan technical assessment yang diberikan.

Lakukan final audit terhadap project.

Gunakan assessment brief sebagai source of truth.

Checklist:

### Product

* [ ] Multi-vehicle booking
* [ ] Different service per vehicle
* [ ] Different spare part/oli per vehicle
* [ ] Different complaint per vehicle
* [ ] Integrated workshop selection
* [ ] Integrated schedule
* [ ] Total estimated cost
* [ ] Total estimated duration
* [ ] Multi-unit booking ticket
* [ ] Individual service status

### UI/UX

* [ ] Home → Booking Success flow
* [ ] Clear information hierarchy
* [ ] Consistent components
* [ ] Mobile-first
* [ ] Responsive
* [ ] Safe layout
* [ ] Loading state
* [ ] Empty state
* [ ] Error state
* [ ] Validation
* [ ] Accessibility consideration

### Engineering

* [ ] Clean architecture
* [ ] Structured folder
* [ ] State management
* [ ] Realistic mock data
* [ ] Reusable components
* [ ] No unnecessary duplication
* [ ] Proper navigation
* [ ] README
* [ ] Build configuration

### Submission

* [ ] Figma
* [ ] GitHub
* [ ] APK
* [ ] README
* [ ] AI conversation log

Untuk setiap item berikan:
STATUS: PASS / NEED IMPROVEMENT

Jika NEED IMPROVEMENT:

* jelaskan masalah
* file/screen terdampak
* solusi
* prioritas

Jangan mengubah code pada tahap audit. Berikan audit report terlebih dahulu.
```

---

## Prompt #16

```text
Bertindak sebagai Senior Flutter Engineer yang melakukan code review terhadap project ini.

Jangan menilai hanya dari apakah aplikasi dapat berjalan.

Review:

* architecture
* separation of concerns
* state management
* widget composition
* reusable components
* naming
* error handling
* async handling
* model structure
* mock repository
* navigation
* performance
* accessibility
* responsive layout
* maintainability

Cari technical debt yang mungkin tidak terlihat dari UI.

Untuk setiap finding berikan:

* severity
* problem
* why it matters
* recommended solution
* apakah perlu diperbaiki untuk assessment atau dapat ditunda

Jangan melakukan perubahan code sebelum memberikan review.
```

---

## Prompt #17

````text
Sebelum melakukan perubahan kode, saya ingin memverifikasi terlebih dahulu temuan dari code review sebelumnya.

Jangan mengubah kode apa pun terlebih dahulu.

Untuk setiap temuan yang diberi status **"PERLU DIPERBAIKI"**, verifikasi apakah masalah tersebut benar-benar terjadi pada implementasi saat ini, bukan hanya berdasarkan pola kode secara teoritis.

Khususnya, verifikasi tiga hal berikut:

### 1. Equatable dan Reaktivitas Riverpod

Telusuri alur state secara aktual:

perubahan state
→ pembuatan state baru
→ notifikasi provider
→ rebuild pada Consumer/Widget

Tentukan apakah penggunaan:

```dart
props => [id]
````

pada `Booking` dan `BookingVehicle` benar-benar dapat menyebabkan UI tidak memperbarui data pada implementasi saat ini.

Jangan langsung berasumsi bahwa `Equatable` secara langsung menentukan apakah Riverpod melakukan rebuild.

Jika implementasi saat ini sudah membuat state/provider value baru dengan cara yang tetap memicu rebuild dengan benar, jelaskan hal tersebut dan sesuaikan severity temuannya.

Jika memang terdapat risiko atau bug nyata, tunjukkan alur kode yang membuktikannya.

---

### 2. Preload Mock Data Source

Verifikasi apakah `addBooking()` atau method mutation lainnya memang dapat dipanggil sebelum mock data awal selesai dimuat.

Telusuri:

- lifecycle provider
- urutan pemanggilan method
- navigation flow
- proses loading mock JSON
- kemungkinan user mencapai kondisi tersebut melalui UI yang tersedia saat ini

Tentukan apakah skenario kehilangan data yang disebutkan pada review sebelumnya benar-benar dapat terjadi.

Jika masalah tersebut hanya mungkin terjadi secara teoritis tetapi tidak dapat dicapai melalui flow aplikasi saat ini, kategorikan sebagai:

**defensive hardening / potential edge case**

dan bukan sebagai bug yang sedang terjadi.

---

### 3. Accessibility

Verifikasi elemen interaktif yang disebutkan pada review sebelumnya.

Periksa secara spesifik:

- apakah IconButton sudah memiliki tooltip atau semantics
- apakah vehicle switcher memiliki label yang dapat dibaca screen reader
- apakah terdapat interactive element lain yang memiliki masalah serupa

Bedakan antara:

- accessibility issue yang benar-benar perlu diperbaiki
- improvement yang sifatnya opsional

---

### Format Hasil

Buat laporan verifikasi dengan format:

| Temuan | Severity Awal | Status Verifikasi | Bukti dari Implementasi | Dampak Aktual | Rekomendasi |
| ------ | ------------- | ----------------- | ----------------------- | ------------- | ----------- |

Gunakan status:

- **TERKONFIRMASI**
- **SEBAGIAN TERKONFIRMASI**
- **TIDAK TERBUKTI / TIDAK DAPAT DIREPRODUKSI**

Untuk setiap temuan, jelaskan alasan berdasarkan implementasi yang benar-benar ada.

Jangan melakukan perubahan kode pada tahap ini.

Tujuan tahap ini adalah memastikan kita memperbaiki masalah yang benar-benar relevan, bukan melakukan refactoring hanya karena sebuah pola kode secara teori dianggap kurang ideal.

Setelah laporan verifikasi selesai, berhenti dan tunggu instruksi saya sebelum melakukan perubahan.

````

---

## Prompt #18

```text
Berdasarkan hasil verifikasi teknis terakhir, tentukan prioritas perbaikan yang benar-benar layak dilakukan sebelum final submission assessment.

Konteks:

* Assessment memiliki waktu pengerjaan terbatas.
* Fokus utama adalah kualitas produk, UX, kesesuaian dengan requirement, stabilitas aplikasi, dan kualitas implementasi Flutter.
* Jangan melakukan refactoring besar hanya untuk mengejar prinsip Clean Architecture jika tidak memberikan dampak nyata terhadap aplikasi saat ini.
* Perubahan yang berisiko merusak flow yang sudah berjalan harus dihindari.

Dari hasil verifikasi sebelumnya, saat ini tidak ditemukan blocking bug. Temuan yang tersisa adalah:

1. Equatable `props => [id]` → tidak terbukti menyebabkan bug pada flow saat ini.
2. Mock Data Source preload race → tidak dapat direproduksi melalui user flow saat ini dan dikategorikan defensive hardening.
3. Accessibility → 3 IconButton belum memiliki tooltip.
4. Terdapat technical debt arsitektur dari review sebelumnya, tetapi belum terbukti mengganggu behavior aplikasi.

Buat prioritas menggunakan kategori:

### P0 — Wajib diperbaiki

Masalah yang dapat menyebabkan aplikasi gagal, data salah/hilang, crash, atau requirement utama tidak terpenuhi.

### P1 — Sebaiknya diperbaiki

Masalah yang memiliki dampak nyata terhadap UX, accessibility, maintainability, atau kualitas submission dan relatif aman untuk diperbaiki.

### P2 — Dapat ditunda

Technical debt atau improvement yang tidak memberikan dampak signifikan terhadap assessment saat ini.

Untuk setiap item jelaskan:

* masalah
* bukti
* dampak
* risiko jika diperbaiki
* estimasi kompleksitas
* rekomendasi prioritas

Setelah itu buat keputusan akhir mengenai perubahan apa saja yang paling rasional untuk dilakukan sebelum submission.

Jangan mengubah kode terlebih dahulu. Tunggu instruksi saya setelah prioritas selesai.
````

---

## Prompt #19

```text
Baik, lanjutkan implementasi 3 perbaikan P1 yang sudah kita sepakati:

1. Tambahkan tooltip pada 3 IconButton:

   * Home notification → `Notifikasi`
   * Service selection sheet close → `Tutup`
   * Spare part selection sheet close → `Tutup`

2. Tambahkan defensive hardening pada `addBooking()` dan `addUserVehicle()` agar data mock dipastikan sudah ter-load sebelum mutation dilakukan. Pastikan tidak menyebabkan duplicate loading atau mengubah flow normal aplikasi.

3. Lengkapi `Equatable props` pada `Booking` dan `BookingVehicle` sesuai field yang memang relevan dengan equality model saat ini. Jangan mengubah behavior lain yang tidak diperlukan.

Setelah selesai:

* Jalankan `flutter analyze`
* Jalankan seluruh unit test
* Pastikan tidak ada error atau regression
* Berikan ringkasan file yang diubah dan hasil verifikasi.

Jangan melakukan refactoring besar seperti repository layer, pemecahan file monolitik, atau migrasi StateNotifier karena item tersebut sudah diputuskan untuk ditunda.
```

---

## Prompt #20

```text
Saya ingin melakukan validasi terakhir terhadap solusi product yang telah dibuat.

Pertanyaan utama:

"Apakah solusi ini benar-benar membuat multi-vehicle booking lebih sederhana dibandingkan jika setiap kendaraan dibuat sebagai transaksi terpisah?"

Analisis:

1. Jumlah interaction yang diperlukan.
2. Jumlah context switching.
3. Kemungkinan user kehilangan data.
4. Kemudahan melihat konfigurasi kendaraan.
5. Kemudahan melakukan perubahan.
6. Kemudahan memahami total biaya.
7. Kemudahan memahami total durasi.
8. Kemudahan memahami status setiap kendaraan.

Identifikasi bagian UX yang masih berpotensi membingungkan.

Berikan rekomendasi improvement tanpa menambahkan complexity yang tidak diperlukan.
```

---

## Prompt #21

```text
Berdasarkan hasil Product Validation & Comparative UX Analysis, sekarang lakukan finalisasi UX.

Jangan membuat analisis panjang atau mencari improvement baru.

Dari 3 potensi friction yang ditemukan:

1. Ekspektasi durasi pengerjaan
2. Navigasi Garage → Vehicle Configuration
3. Kompatibilitas kategori workshop

Terapkan hanya improvement yang memberikan nilai UX nyata dengan kompleksitas rendah dan tidak mengganggu flow multi-vehicle booking yang sudah berjalan.

Implementasikan:

1. Ekspektasi Durasi

Tambahkan penjelasan singkat pada bagian estimasi durasi agar user memahami konteks waktu pengerjaan.

Gunakan wording yang natural dan ringkas. Jangan membuat UI menjadi penuh.

**2. Kompatibilitas Workshop**

Pada workshop selection, berikan informasi visual yang membantu user memahami apakah workshop dapat melayani seluruh kategori kendaraan yang sedang dipilih.

Jika struktur data saat ini memungkinkan, gunakan badge/chip atau informasi singkat seperti:

> "Melayani Mobil & Motor"

Pastikan informasi hanya muncul ketika relevan.

3. Navigasi Garage → Configuration

Jangan membuat perubahan besar.

Pertahankan CTA "Simpan & Lanjut ke Unit Berikutnya" yang sudah ada karena pola tersebut sudah membantu konfigurasi beberapa kendaraan secara berurutan.

Jika flow saat ini sudah dapat digunakan tanpa masalah, cukup pertahankan.

Setelah Implementasi

Lakukan validasi singkat:

* Jalankan `flutter analyze`
* Jalankan unit test
* Pastikan multi-vehicle booking tetap berjalan
* Pastikan konfigurasi setiap kendaraan tetap independen
* Pastikan workshop compatibility tidak menyebabkan error
* Pastikan perubahan UI tidak mengganggu layout atau navigation

Kemudian berikan laporan akhir secara singkat:

1. Perubahan UX yang diterapkan
2. Perubahan yang sengaja tidak dilakukan
3. Hasil validasi
4. Known limitation, jika masih ada

Jangan membuat improvement tambahan setelah tahap ini kecuali ditemukan bug atau requirement utama yang belum terpenuhi.

Anggap tahap ini sebagai **final UX refinement sebelum submission**.
```

---
