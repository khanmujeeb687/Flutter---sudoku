import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsUtil {
  static String NEWS_CLICKED = 'NEWS_CLICKED';

  static Future<void> log(String name,[String value]) async {
    await FirebaseAnalytics().logEvent(
      name: name,
      parameters: <String, dynamic>{'string': value ?? ''},
    );
  }
}
