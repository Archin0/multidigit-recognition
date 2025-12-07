import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isDetected = false;
  final String _detectedNumber = "567";
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    // Simulasi deteksi setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDetected = true;
        });
      }
    });
  }

  // Navigasi ke halaman hasil
  void _navigateToResult() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          image: _selectedImage,
          detectedNumber: _detectedNumber,
          accuracy: 90.0,
        ),
      ),
    );
  }

  // Ambil foto dari kamera
  Future<void> _onCaptureFromCamera() async {
    if (!_isMobile) {
      // Di desktop, langsung ke hasil
      _navigateToResult();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
        _navigateToResult();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengakses kamera: $e')));
    }
  }

  // Ambil foto dari galeri
  Future<void> _onPickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _navigateToResult();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengakses galeri: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Multidigit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'From your camera or a picture',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Area Kamera / Preview Gambar
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Preview gambar atau placeholder
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Center(
                              child: Text(
                                _detectedNumber,
                                style: const TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Scanner Frame (hijau jika terdeteksi, abu jika belum)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      child: CustomPaint(
                        painter: ScannerFramePainter(
                          color: _isDetected ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hasil Deteksi - Muncul jika terdeteksi
          if (_isDetected)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Deteksi!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Teks "Ambil Foto"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ambil Foto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tombol Galeri dan Kamera - Selalu bisa diklik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Galeri (kiri)
                GestureDetector(
                  onTap: _onPickFromGallery,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white54, width: 2),
                      color: Colors.grey[800],
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                // Tombol Capture (tengah - bulat)
                GestureDetector(
                  onTap: _onCaptureFromCamera,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                // Placeholder untuk simetri
                const SizedBox(width: 50, height: 50),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Custom painter untuk scanner frame
class ScannerFramePainter extends CustomPainter {
  final Color color;

  ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;
    const radius = 8.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - cornerLength,
        )
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}