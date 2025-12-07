import 'package:flutter/material.dart';
import 'dart:io';

class ResultPage extends StatelessWidget {
  final File? image;
  final String detectedNumber;
  final double accuracy;

  const ResultPage({
    super.key,
    this.image,
    required this.detectedNumber,
    this.accuracy = 90.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Text(
                'Hasil Pengenalan Multidigit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Deskripsi
              const Text(
                'Mengenali angka yang terdiri dari beberapa digit sekaligus langsung dari kamera. Membantu pembacaan angka secara cepat, otomatis, dan konsisten.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Gambar hasil scan
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: image != null
                      ? Image.file(image!, fit: BoxFit.contain)
                      : Center(
                          // Placeholder simulasi angka
                          child: Text(
                            detectedNumber,
                            style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Label Hasil Deteksi
              const Text(
                'Hasil Deteksi:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Angka hasil deteksi
              Text(
                detectedNumber,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Divider(color: Colors.grey[300], thickness: 1),

              const SizedBox(height: 16),

              // Akurasi Deteksi
              const Text(
                'Akurasi Deteksi:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              // Progress bar akurasi
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: accuracy / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accuracy >= 80
                              ? Colors.green
                              : accuracy >= 50
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${accuracy.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Tombol Scan Lagi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    'Scan Lagi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Simpan ke Riwayat
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Simpan ke riwayat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil disimpan ke riwayat'),
                      ),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.save, color: Color(0xFF1E88E5)),
                  label: const Text(
                    'Simpan ke Riwayat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}