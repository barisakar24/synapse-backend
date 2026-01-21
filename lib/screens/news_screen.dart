import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // --- AYARLAR ---
  // GitHub RAW linkin (Kullanıcı adın doğru)
  final String apiUrl = "https://raw.githubusercontent.com/barisakar24/synapse-backend/master/backend/news_data.json";

  // Tasarım Renklerin (Birebir korundu)
  final Color _accentColor = const Color(0xFFFFD233);
  final Color _darkCardColor = const Color(0xFF1E1E1E);
  final Color _backgroundColor = const Color(0xFF0F1115);

  Map<String, dynamic>? _newsData;
  bool _isLoading = true;
  String _errorMessage = "";
  
  String _selectedCategory = "Tümü";
  final List<String> _categories = ["Tümü", "Nöroloji", "Psikoloji", "Yapay Zeka", "Genetik"];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _newsData = decodedData;
          _isLoading = false;
        });
      } else {
        throw Exception("Hata: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Bağlantı hatası. İnternetini kontrol et.";
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getFilteredNews() {
    if (_newsData == null) return [];
    List<dynamic> allNews = _newsData!['news_list'];
    if (_selectedCategory == "Tümü") return allNews;
    return allNews.where((news) => news['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _accentColor))
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white)))
                : RefreshIndicator(
                    onRefresh: _fetchNews,
                    color: _accentColor,
                    backgroundColor: _darkCardColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. HEADER
                          _buildHeader(),
                          const SizedBox(height: 20),

                          // 2. ARAMA ÇUBUĞU
                          _buildSearchBar(),
                          const SizedBox(height: 25),

                          // 3. MANŞET (HERO) - Sadece 'Tümü'ndeyken gösterelim
                          if (_selectedCategory == "Tümü" && _newsData!['daily_news'] != null) ...[
                            _buildHeroNewsCard(context, _newsData!['daily_news']),
                            const SizedBox(height: 25),
                          ],

                          // 4. KATEGORİLER
                          _buildCategories(),
                          const SizedBox(height: 25),

                          // 5. YATAY LİSTE (Trendler gibi dursun diye ilk 5 haberi buraya koyalım)
                          if (_newsData!['news_list'] != null && (_newsData!['news_list'] as List).isNotEmpty)
                             _buildHorizontalNewsList(),
                          
                          const SizedBox(height: 20),

                          // 6. DİKEY LİSTE BAŞLIĞI
                          Text(
                            _selectedCategory == "Tümü" ? "Son Gelişmeler" : "$_selectedCategory Haberleri",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 7. DİKEY LİSTE
                          _buildVerticalNewsList(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // --- TASARIM WIDGETLARI (SENİN KODLARIN) ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: _accentColor, size: 28),
            const SizedBox(width: 8),
            Text(
              "Synapse News",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        Row(
          children: [
            _iconButton(CupertinoIcons.bookmark),
            const SizedBox(width: 10),
            _iconButton(CupertinoIcons.globe),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _darkCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Haberlerde ara...",
          hintStyle: TextStyle(color: Colors.grey),
          icon: Icon(CupertinoIcons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.tune, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildHeroNewsCard(BuildContext context, Map<String, dynamic> news) {
    return GestureDetector(
      onTap: () => _openDetail(context, news),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(news['image'] ?? "https://raw.githubusercontent.com/barisakar24/synapse-backend/master/backend/placeholder.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text("Günün Haberi", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    news['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(radius: 10, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 12, color: Colors.white)), // Sabit avatar şimdilik
                      const SizedBox(width: 8),
                      Text("Synapse AI • ${_formatDate(news['date'])}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _accentColor : _darkCardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                cat,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- SENİN İSTEDİĞİN O YATAY KÜÇÜK KARTLAR ---
  Widget _buildHorizontalNewsList() {
    // İlk 5 haberi alalım
    final trendingNews = (_newsData!['news_list'] as List).take(5).toList();

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trendingNews.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final news = trendingNews[index];
          return GestureDetector(
            onTap: () => _openDetail(context, news),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: _darkCardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        news['image'] ?? "https://picsum.photos/300",
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timeAgo(news['date']),
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalNewsList() {
    final newsList = _getFilteredNews();
    if (newsList.isEmpty) return const Text("Haber bulunamadı.", style: TextStyle(color: Colors.white54));

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return GestureDetector(
          onTap: () => _openDetail(context, news),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _darkCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    news['image'] ?? "https://picsum.photos/200",
                    width: 80, height: 80, fit: BoxFit.cover,
                    errorBuilder: (c,o,s) => Container(width:80, height:80, color:Colors.grey[800]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news['category'] ?? "Genel",
                          style: TextStyle(color: Colors.blueAccent[100], fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        news['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(_timeAgo(news['date']), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- YARDIMCI FONKSİYONLAR ---
  
  void _openDetail(BuildContext context, Map<String, dynamic> news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsDetailScreen(newsData: news)),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) { return ""; }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return "${diff.inDays} gün önce";
      if (diff.inHours > 0) return "${diff.inHours} sa önce";
      return "${diff.inMinutes} dk önce";
    } catch (e) { return ""; }
  }
}