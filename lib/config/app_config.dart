enum AppFlavor { dev, prod }

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final String googleWebClientId;

  AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.googleWebClientId,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  static void initialize(AppConfig config) {
    _instance = config;
  }

  // Development configuration
  static AppConfig get dev => AppConfig(
    flavor: AppFlavor.dev,
    appName: 'Job Tracker DEV',
    apiBaseUrl: 'https://dev-api.example.com',
    enableLogging: true,
    // Web Client ID from dev google-services.json (client_type: 3)
    googleWebClientId: '799198238282-21qhhv7d834k4ej2u9dkisqgd5v33n6r.apps.googleusercontent.com',
  );

  // Production configuration
  static AppConfig get prod => AppConfig(
    flavor: AppFlavor.prod,
    appName: 'Job Tracker',
    apiBaseUrl: 'https://api.example.com',
    enableLogging: false,
    // Web Client ID from prod google-services.json (client_type: 3)
    googleWebClientId: '43490462622-ve0n788ga09jifki3qv61imbsmf907pa.apps.googleusercontent.com',
  );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
