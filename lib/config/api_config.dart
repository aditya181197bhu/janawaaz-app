class ApiConfig {
  // Default 10.0.2.2 is how the Android emulator reaches the Mac it runs on, and it
  // never changes. For a real phone, build with the Mac's current Wi-Fi IP:
  //   tools/build_phone_apk.sh   (or --dart-define=API_URL=http://<ip>:8081)
  static const String serverUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8081');
  static const String baseUrl = '$serverUrl/api';

  /// The sample volunteer the backend seeds (Amit Kumar, SV-0101, Ward 1).
  static const int demoVolunteerId = 1;

  static String fileUrl(String path) => path.startsWith('http') ? path : '$serverUrl$path';
}
