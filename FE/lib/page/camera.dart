import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  dynamic _selectedImage; // Bisa File atau XFile
  bool isDetecting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image; // Simpan sebagai XFile untuk web
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _detectNumber() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih gambar terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isDetecting = true;
    });

    // Simulasi proses deteksi (2 detik)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isDetecting = false;
      });

      // Navigate ke result dengan data dummy
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'detected_number': '567',
          'confidence': 0.95,
          'image_file': _selectedImage,
        },
      );
    });
  }

  // Widget untuk menampilkan gambar (support web & mobile)
  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Ambil atau pilih gambar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Untuk Web
    if (kIsWeb) {
      return Center(
        child: Image.network(
          _selectedImage.path,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Error loading image',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      );
    }
    
    // Untuk Mobile (Android/iOS)
    return Center(
      child: Image.file(
        File(_selectedImage.path),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  // Widget untuk thumbnail gallery
  Widget _buildGalleryThumbnail() {
    if (_selectedImage == null) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(
          Icons.photo_library,
          color: Colors.white,
          size: 24,
        ),
      );
    }

    if (kIsWeb) {
      return Image.network(
        _selectedImage.path,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(_selectedImage.path),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2C2C2E),
                    const Color(0xFF2C2C2E).withOpacity(0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Scan Multidigit',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Point your camera at a picture',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Camera/Image Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1C1C1E),
                child: Stack(
                  children: [
                    // Background atau gambar yang dipilih
                    _buildImagePreview(),
                    
                    // Detection Frame (kotak hijau dengan corner)
                    Center(
                      child: Container(
                        width: 320,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00FF00),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            // Corner indicators (4 sudut)
                            Positioned(
                              top: -3,
                              left: -3,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -3,
                              left: -3,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -3,
                              right: -3,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FF00),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Deteksi Button
                    if (_selectedImage != null)
                      Positioned(
                        bottom: 180,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: isDetecting ? null : _detectNumber,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                isDetecting ? 'Detecting...' : 'Deteksi !',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Loading overlay
                    if (isDetecting)
                      Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(
                                color: Color(0xFF00FF00),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Mendeteksi angka...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Bottom Section
            Container(
              color: const Color(0xFF000000),
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Column(
                children: [
                  const Text(
                    'Ambil Foto',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery thumbnail
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _buildGalleryThumbnail(),
                          ),
                        ),
                      ),
                      
                      // Camera capture button
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            // Di web, camera tidak tersedia, gunakan gallery
                            _pickImage(ImageSource.gallery);
                          } else {
                            _pickImage(ImageSource.camera);
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 56),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
