# DevamsızlıkKOU 🎓

**DevamsızlıkKOU**, Kocaeli Üniversitesi ve üniversite öğrencileri için tasarlanmış modern, sade, kişiselleştirilmiş ve akıllı bir **Devamsızlık ve Akademik Takip** mobil uygulamasıdır.

---

## 🚀 Öne Çıkan Özellikler

### 1. Kişiselleştirilmiş Karşılama & Onboarding
- İlk açılışta minimalist bir onboarding ekranı ile kullanıcı karşılanır.
- Kullanıcı ismi yerel hafızaya (`SharedPreferences`) kaydedilir.
- Günün saatine göre dinamik selamlama (*"Günaydın, İbrahim!"*, *"İyi akşamlar, İbrahim!"*) ve kişisel durum özeti sunulur.
- Ayarlar sekmesinden isim istenildiği an güncellenebilir.

### 2. Modern Tema Yönetimi (Light / OLED Dark / System)
- **Sistem Teması (System):** Cihaz ayarına göre otomatik geçiş.
- **Aydınlık Mod (Light):** Ferah ve minimalist Material 3 renk paleti.
- **Karanlık Mod (OLED Dark):** Pil tasarrufu sağlayan gerçek derin siyahlar (`#090D12`).

### 3. Akıllı Devamsızlık Sayacı & Geriye Dönük Düzeltme Mantığı ⚡
- **Otomatik Sayım:** Ders günü ve saati geçtiğinde kullanıcı işlem yapmazsa sistem dersi varsayılan olarak *"Girildi"* kabul eder.
- **Akıllı 18:00 Penceresi:** Akşam saat 18:00'e kadar kullanıcıya *"Derse Gitmedim"* aksiyonu belirgin bir rozetle aktif sunulur.
- **Geriye Dönük Düzeltme (Correction Logic):** Kullanıcı 18:00'e kadar gelip butona basarsa:
  - `Girilen Ders Sayısı` otomatik olarak **-1** azaltılır.
  - `Girilmeyen Ders (Devamsızlık) Sayısı` **+1** artırılır.
  - `Toplam İşlenen Ders Sayısı` **sabit kalır**.
- **Hatalı Dokunuş Koruması:** Kullanıcı yanlışlıkla bastıysa tek tıkla *"Derse Girdim Olarak Düzelt"* seçeneği bulunur.
- **Manuel İnce Ayar:** Geçmiş dersleri telafi etmek için hızlı `+1 Girilen` ve `+1 Devamsız` kontrolleri.

### 4. Manuel Sınav ve Not Modülü
- Sınav Adı (Vize 1, Final, Quiz, Proje vb.)
- **0-100 Puan** veya **Harf Notu** (AA, BA, BB... FF) seçeneği
- Dönem sonu etki ağırlığı (%40, %60 vb.)
- Otomatik ağırlıklı not ortalaması hesaplama
- Sınavları düzenleme ve silme desteği

### 5. Dönemi Sıfırla & Arşivle (History/Archive)
- Dönem sonunda canlı ders verileri tek dokunuşla sıfırlanabilir.
- Sıfırlanan dönemin tüm istatistikleri (Devamsızlık sayıları, katılım yüzdesi, sınav notları ve tarih) otomatik olarak **Geçmiş (Arşiv)** sekmesine taşınır.
- Kullanıcı adı ve tema tercihleri **korunur**, yeni dönem sıfırdan başlar.

---

## 📂 Proje Dizin Yapısı (Folder Structure)

```text
devamsizlik_kou/
├── pubspec.yaml
├── README.md
└── lib/
    ├── main.dart                                # Uygulama giriş noktası ve Provider enjeksiyonu
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart                  # Renk paleti (KOU Yeşili, OLED Dark, Light)
    │   │   └── app_theme.dart                   # Material 3 Açık ve Koyu Tema yapılandırması
    │   └── utils/
    │       └── date_time_utils.dart             # Türkçe tarih, selamlama ve 18:00 pencere kontrolü
    ├── data/
    │   ├── models/
    │   │   ├── course_model.dart                # Ders, sayaçlar, devamsızlık hesaplama modeli
    │   │   ├── exam_model.dart                  # Sınav notu ve ağırlık modeli
    │   │   ├── attendance_log_model.dart        # Günlük oturum logu (Akıllı pencere & düzeltme)
    │   │   └── archived_term_model.dart         # Sıfırlanan geçmiş dönem arşiv modeli
    │   └── services/
    │       └── storage_service.dart             # SharedPreferences tabanlı yerel kalıcı depolama
    ├── providers/
    │   ├── app_provider.dart                    # Profil, Tema ve Onboarding state yönetimi
    │   └── attendance_provider.dart             # Devamsızlık, akıllı sayaç, geriye dönük düzeltme & arşiv mantığı
    └── views/
        ├── onboarding/
        │   └── onboarding_screen.dart           # İlk açılış isim alma ve karşılama ekranı
        ├── home/
        │   ├── home_screen.dart                 # Ana takip ekranı
        │   └── widgets/
        │       ├── attendance_summary_card.dart # 3 sayaç, kalan hak ve ilerleme çubuğu
        │       ├── quick_action_section.dart    # 18:00 penceresi, "Derse Gitmedim" & Geri alma
        │       ├── course_schedule_info.dart    # Ders gün ve saat detayları
        │       └── exam_list_card.dart          # Sınav notları ve ortalama özeti
        ├── exams/
        │   ├── exams_tab.dart                   # Tüm sınavların listelendiği sekme
        │   └── add_edit_exam_dialog.dart        # Not ekleme / düzenleme modal diyalogu
        ├── history/
        │   └── history_archive_screen.dart      # Arşivlenmiş eski dönemlerin listesi
        ├── settings/
        │   └── settings_screen.dart             # İsim, Tema, Ders ayarları ve Sıfırlama
        └── main_nav_scaffold.dart               # Modern alt sekme gezinti çubuğu
```

---

## 🛠️ Kurulum ve Çalıştırma

1. Proje dizinine geçin:
   ```bash
   cd devamsizlik_kou
   ```

2. Gerekli paketleri indirin:
   ```bash
   flutter pub get
   ```

3. Uygulamayı bir emülatörde veya bağlı fiziksel cihazda çalıştırın:
   ```bash
   flutter run
   ```

