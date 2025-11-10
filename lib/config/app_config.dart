enum AppFlavor { dev, prod }

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;

  AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
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
  );

  // Production configuration
  static AppConfig get prod => AppConfig(
    flavor: AppFlavor.prod,
    appName: 'Job Tracker',
    apiBaseUrl: 'https://api.example.com',
    enableLogging: false,
  );

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
