class ApiConfig {
  const ApiConfig._();

  // Base URL konfigurasi
  // Default ke Production (Render.com).
  // Untuk menggunakan Local Backend saat build, gunakan perintah:
  // flutter build apk --release --dart-define=RECOGNITION_BASE_URL=http://YOUR_IP:8000
  static const String recognitionBaseUrl = String.fromEnvironment(
    'RECOGNITION_BASE_URL',
    defaultValue: 'https://multidigit-recognition.onrender.com',
  );
}
