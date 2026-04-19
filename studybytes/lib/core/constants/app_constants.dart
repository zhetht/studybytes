import '../../config/api_config.dart';

class AppConstants {
  static const String appName = 'StudyBytes';


  static String get geminiApiKey => ApiConfig.geminiApiKey;
  

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserPremium = 'user_premium';


  static const String mockEmail = 'ghosty@study.com';
  static const String mockPassword = '123456';
}
