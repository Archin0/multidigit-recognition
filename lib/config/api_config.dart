class ApiConfig {
  const ApiConfig._();

  // Konfigurasi untuk Local Development (Laptop sebagai Server)
  // static const String recognitionBaseUrl = String.fromEnvironment(
  //   'RECOGNITION_BASE_URL',
  //   defaultValue: 'http://192.168.18.62:8000',
  // );

  // Konfigurasi untuk Cloud Deploy (Render.com)
  static const String recognitionBaseUrl = String.fromEnvironment(
    'RECOGNITION_BASE_URL',
    defaultValue:
        'https://multidigit-recognition.onrender.com',
  );
}
