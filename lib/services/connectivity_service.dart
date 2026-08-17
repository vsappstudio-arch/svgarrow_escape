import 'dart:io';

/// A minimal connectivity probe using a DNS lookup — no extra
/// package required. Good enough to detect "no internet" for the
/// prototype shop/offline screens.
class ConnectivityService {
  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
