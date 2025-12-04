import 'package:flutter/material.dart';
import 'history_page.dart';
import 'detection_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _showHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void _onStartPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              // Icon riwayat (kanan atas)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => _showHistory(context),
                  icon: const Icon(
                    Icons.access_time,
                    size: 28,
                    color: Colors.black54,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Logo dari file gambar lokal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png', // Ganti dengan path logo Anda
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar tidak ditemukan
                      return const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Judul
              const Text(
                'Deteksi MultiDigit',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Deskripsi
              Text(
                'Aplikasi untuk mengenali angka multidigit\nmelalui kamera secara cepat dan akurat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),

              // Tombol Mulai
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _onStartPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lest get started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}