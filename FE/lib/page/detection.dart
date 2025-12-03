import 'package:flutter/material.dart';

class Detection extends StatelessWidget {
  const Detection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_4_bar, size: 17, color: Color(0xFF1C1C1E)),
                      const SizedBox(width: 5),
                      Icon(Icons.wifi, size: 17, color: Color(0xFF1C1C1E)),
                      const SizedBox(width: 5),
                      Container(
                        width: 24,
                        height: 11,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF1C1C1E), width: 1),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Deteksi Multidigit',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Description
              const Text(
                'Mengenali angka yang terdiri dari beberapa digit sekaligus langsung dari kamera. Membantu pembacaan angka secara cepat, otomatis, dan konsisten.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Camera Icon dengan frame
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Corner frames
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFF007AFF), width: 4),
                              left: BorderSide(color: Color(0xFF007AFF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFF007AFF), width: 4),
                              right: BorderSide(color: Color(0xFF007AFF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF007AFF), width: 4),
                              left: BorderSide(color: Color(0xFF007AFF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF007AFF), width: 4),
                              right: BorderSide(color: Color(0xFF007AFF), width: 4),
                            ),
                          ),
                        ),
                      ),
                      
                      // Camera icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Start Detection Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to camera page atau buka kamera
                    Navigator.pushNamed(context, '/camera');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mulai Deteksi multidigit',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Home indicator
              Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
