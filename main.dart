import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart'; // Çeviri paketi

void main() {
  runApp(const AiNewsApp());
}

class AiNewsApp extends StatelessWidget {
  const AiNewsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI News Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E676), // Neon Yeşil
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const NewsFeedScreen(),
    );
  }
}

// --- 1. VERİ MODELİ ---
class NewsArticle {
  final String titleEn;
  final String descriptionEn;
  String? titleTr; // Çeviri sonrası dolacak
  String? descriptionTr; // Çeviri sonrası dolacak
  final String imageUrl;
  final String source;
  final String url;
  final String publishedAt;
  NewsArticle({
    required this.titleEn,
    required this.descriptionEn,
    this.titleTr,
    this.descriptionTr,
    required this.imageUrl,
    required this.source,
    required this.url,
    required this.publishedAt,
  });
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      titleEn: json['title'] ?? 'Başlık Yok / No Title',
      descriptionEn: json['description'] ?? 'Detay yok / No description.',
      imageUrl:
          json['image'] ?? '', // GNews API: 'image' (NewsAPI: 'urlToImage')
      source: json['source']['name'] ?? 'Unknown',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}

// --- 2. ANA EKRAN ---
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});
  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  // GNews API Key
  final String apiKey = '7de76ad68d4693a25cb2144701f625be';
  bool isTurkish = false; // Dil tercihi
  bool isTranslating = false; // Çeviri yükleniyor mu?
  bool isLoading = true; // Haberler yükleniyor mu?
  String? errorMessage; // Hata mesajı var mı?
  List<NewsArticle> articles = [];
  // Çevirmen nesnesi
  final translator = GoogleTranslator();
  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // Haberleri Çekme Fonksiyonu
  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    // Yapay Zeka sorgusu (GNews formatı)
    const query =
        'artificial intelligence OR machine learning OR OpenAI OR ChatGPT OR Gemini OR AI OR deep learning OR neural networks OR GPT OR LLM';
    final url = Uri.parse(
      'https://gnews.io/api/v4/search?q=$query&lang=en&max=10&apikey=$apiKey',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List articlesJson = jsonResponse['articles'];
        setState(() {
          articles = articlesJson
              .map((json) => NewsArticle.fromJson(json))
              .where(
                (article) => article.titleEn != '[Removed]',
              ) // Silinenleri gizle
              .toList();
          isLoading = false;
        });
        // Eğer uygulama açıldığında Türkçe modundaysa çevir
        if (isTurkish) {
          _translateAllArticles();
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage =
              '🔑 API Key Hatası!\n\nAPI key geçersiz veya süresi dolmuş.\nLütfen gnews.io dashboard\'unuzdan kontrol edin.';
          isLoading = false;
        });
      } else if (response.statusCode == 429) {
        setState(() {
          errorMessage =
              '⏰ Günlük Limit Aşıldı!\n\nGNews ücretsiz planında günlük 100 istek limiti var.\nYarın tekrar deneyin veya ücretli plana geçin.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'API Hatası: ${response.statusCode}\n\nLütfen API key ve internet bağlantınızı kontrol edin.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Bağlantı Hatası:\n$e';
        isLoading = false;
      });
    }
  }

  // Çeviri Fonksiyonu
  Future<void> _translateAllArticles() async {
    if (articles.isEmpty) return;
    setState(() {
      isTranslating = true;
    });
    try {
      // Listeyi tek tek gez ve çevir
      for (var article in articles) {
        // Zaten çevrildiyse tekrar çevirme (Tasarruf)
        if (article.titleTr == null) {
          final tTitle = await translator.translate(article.titleEn, to: 'tr');
          final tDesc = await translator.translate(
            article.descriptionEn,
            to: 'tr',
          );
          article.titleTr = tTitle.text;
          article.descriptionTr = tDesc.text;
        }
      }
    } catch (e) {
      debugPrint("Çeviri hatası: $e");
    } finally {
      if (mounted) {
        setState(() {
          isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch, color: Color(0xFF00E676)),
            SizedBox(width: 10),
            Text("AI News Hub", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // DİL DEĞİŞTİRME BUTONU
          Center(
            child: Text(
              isTurkish ? "TR" : "EN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTurkish ? const Color(0xFF00E676) : Colors.grey,
              ),
            ),
          ),
          Switch(
            value: isTurkish,
            activeThumbColor: const Color(0xFF00E676),
            onChanged: (value) {
              setState(() {
                isTurkish = value;
              });
              if (value == true) {
                _translateAllArticles();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Çeviri yükleme çubuğu
          if (isTranslating)
            const LinearProgressIndicator(
              color: Color(0xFF00E676),
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00E676)),
                  )
                : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: fetchNews,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                            ),
                            child: const Text(
                              "Tekrar Dene",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchNews,
                    color: const Color(0xFF00E676),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return _buildNewsCard(articles[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Kart Tasarımı
  Widget _buildNewsCard(NewsArticle article) {
    // Dile göre metin seçimi
    final title = (isTurkish && article.titleTr != null)
        ? article.titleTr!
        : article.titleEn;
    final desc = (isTurkish && article.descriptionTr != null)
        ? article.descriptionTr!
        : article.descriptionEn;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NewsDetailScreen(article: article, isTurkish: isTurkish),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Haber Resmi
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  article.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 150,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.source,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        article.publishedAt.substring(0, 10),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. DETAY EKRANI ---
class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;
  final bool isTurkish;
  const NewsDetailScreen({
    super.key,
    required this.article,
    required this.isTurkish,
  });
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(article.url);
    if (!await launchUrl(url)) {
      debugPrint("Link açılamadı");
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = (isTurkish && article.titleTr != null)
        ? article.titleTr!
        : article.titleEn;
    final desc = (isTurkish && article.descriptionTr != null)
        ? article.descriptionTr!
        : article.descriptionEn;
    return Scaffold(
      appBar: AppBar(title: Text(isTurkish ? "Haber Detayı" : "Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(height: 250, color: Colors.grey[800]),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(article.source),
                    backgroundColor: const Color(0xFF00E676).withOpacity(0.2),
                    labelStyle: const TextStyle(color: Color(0xFF00E676)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.public),
                      label: Text(
                        isTurkish ? "Kaynağa Git" : "Read Full Story",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
