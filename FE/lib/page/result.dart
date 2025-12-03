import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class Result extends StatelessWidget {
  const Result({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String detectedNumber = args?['detected_number'] ?? '000';
    final double confidence = args?['confidence'] ?? 0.0;
    final dynamic imageFile = args?['image_file'];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('Hasil Deteksi'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Captured Image Preview
            if (imageFile != null)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? Image.network(
                          imageFile.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imageFile.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),

            // Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00FF00),
                    size: 64,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Deteksi Berhasil!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Angka yang terdeteksi:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detectedNumber,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.analytics,
                          color: Color(0xFF007AFF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan Lagi',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
