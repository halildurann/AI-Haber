🚀 AI News Hub: Yapay Zeka Haber Kaynağınız
Yapay Zeka (AI) dünyasındaki en son gelişmeleri takip edin! AI News Hub, Flutter kullanılarak geliştirilmiş, popüler haber kaynaklarından yapay zeka ve makine öğrenimi ile ilgili haberleri toplayan, listelerken anında Türkçe çeviri yapabilme özelliğine sahip modern bir mobil uygulamadır.

✨ Temel Özellikler
Güncel Yapay Zeka Haberleri: GNews API'ı kullanarak "artificial intelligence", "ChatGPT", "Gemini" gibi anahtar kelimelerle ilgili en güncel 10 haberi çeker.

Anlık Türkçe Çeviri: Yerleşik translator paketi sayesinde tek bir düğme ile haber başlıklarını ve açıklamalarını İngilizce'den Türkçe'ye çevirir.

Koyu (Dark) Tema: Neon yeşil vurgularla göze hoş gelen, modern ve koyu tema tasarımı.

Hata Yönetimi: API Anahtarı, kota aşımı ve bağlantı sorunları gibi durumlar için detaylı hata mesajları ve yeniden deneme seçeneği sunar.

Detay Ekranı: Haber özeti, kaynak ve orijinal makaleye kolay erişim (URL Launcher) sunan detaylı okuma ekranı.

Yenileme: Aşağı çekerek yenileme (Pull-to-refresh) özelliği.

⚙️ Kurulum ve Çalıştırma
Bu projeyi yerel cihazınızda çalıştırmak için aşağıdaki adımları izleyin.

1. Ön Gereksinimler
Flutter SDK kurulu olmalıdır.

Bir IDE (VS Code veya Android Studio) ve Flutter/Dart eklentileri.

Bir GNews API Anahtarı. (Aşağıdaki adıma bakın)

2. Projeyi Klonlayın
Bash

git clone https://github.com/KULLANICI_ADINIZ/ai-news-hub.git
cd ai-news-hub
3. Bağımlılıkları Yükleyin
Bash

flutter pub get
4. API Anahtarını Ayarlayın
Uygulama, haberleri çekmek için bir GNews API anahtarı gerektirir.

GNews web sitesine gidin ve ücretsiz bir API Anahtarı alın.

lib/main.dart dosyasını açın.

_NewsFeedScreenState sınıfında bulunan aşağıdaki satırı kendi anahtarınızla değiştirin:

Dart

// lib/main.dart içinde
final String apiKey = '7de76ad68d4693a25cb2144701f625be'; // <-- BURAYI DEĞİŞTİRİN
5. Uygulamayı Çalıştırın
Bir emülatör veya fiziksel cihaz bağlıyken uygulamayı çalıştırın:

Bash

flutter run
🛠️ Kullanılan Teknolojiler
Dart & Flutter: Mobil uygulama geliştirme çerçevesi.

http: Harici API'lara HTTP istekleri yapmak için.

url_launcher: Haberlerin orijinal kaynağını web tarayıcısında açmak için.

translator: Google Çeviri hizmetini kullanarak metin çevirisi yapmak için. (Not: Üçüncü taraf bu paketler, Google'ın sunduğu gerçek zamanlı çeviri hizmetlerinden farklı çalışabilir ve kotası/güvenilirliği değişebilir.)

💡 Geliştirme Notları
Tema: Uygulama, 0xFF00E676 (Neon Yeşil) rengini birincil vurgu rengi olarak kullanır.

Veri Modeli: NewsArticle sınıfı, hem İngilizce (kaynak) hem de Türkçe (çeviri) başlık/açıklama alanlarını tutacak şekilde tasarlanmıştır.

Çeviri Mantığı: Çeviri işlemi ( _translateAllArticles ) sadece kullanıcı dil düğmesine (Switch) bastığında veya uygulama Türkçe modunda açıldığında tetiklenir ve zaten çevrilmiş olan haberleri tekrar çevirmeyerek çeviri API isteklerini azaltmaya çalışır.

✍️ Katkıda Bulunma
Geri bildirimler ve katkılar her zaman kabul edilir! Herhangi bir öneriniz veya hata düzeltmeniz varsa, lütfen bir Pull Request veya Issue açmaktan çekinmeyin.

📄 Lisans
Bu proje MIT Lisansı altında lisanslanmıştır.
