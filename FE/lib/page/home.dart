import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Status bar dengan history button
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
              
              // History button di pojok kanan atas
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to history page
                      Navigator.pushNamed(context, '/history');
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Color(0xFF007AFF),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 2),
              
              // Logo gambar (akan diganti dengan gambar yang Anda upload)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png', // GANTI DENGAN PATH LOGO ANDA
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar tidak ditemukan
                      return Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'M',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Deteksi MultiDigit',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Aplikasi untuk mengenali angka multidigit\nmelalui kamera secara cepat dan akurat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E8E93),
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Let's get started button
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
                    // Navigate to detection/camera page
                    Navigator.pushNamed(context, '/detection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Let\'s get started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Home indicator
              Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(2.5),
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
