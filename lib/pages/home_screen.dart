import 'package:flutter/material.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: const Text(
          'Deteksi Multidigit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Mengenali angka yang terdiri dari beberapa digit sekaligus langsung dari kamera. Membantu pembacaan angka secara cepat, otomatis, dan konsisten.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Corner brackets
                      Positioned(
                        top: 35,
                        left: 35,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFF0066FF), width: 4),
                              left: BorderSide(color: const Color(0xFF0066FF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 35,
                        right: 35,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: const Color(0xFF0066FF), width: 4),
                              right: BorderSide(color: const Color(0xFF0066FF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 35,
                        left: 35,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFF0066FF), width: 4),
                              left: BorderSide(color: const Color(0xFF0066FF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 35,
                        right: 35,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: const Color(0xFF0066FF), width: 4),
                              right: BorderSide(color: const Color(0xFF0066FF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      // Camera icon
                      const Icon(
                        Icons.camera_alt_rounded,
                        size: 70,
                        color: Color(0xFF0066FF),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CameraScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Mulai Deteksi multidigit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}