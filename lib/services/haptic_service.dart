import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] so call sites don't depend
/// directly on the platform channel API.
class HapticService {
  void selectionClick() => HapticFeedback.selectionClick();

  void lightImpact() => HapticFeedback.lightImpact();

  void mediumImpact() => HapticFeedback.mediumImpact();
}
