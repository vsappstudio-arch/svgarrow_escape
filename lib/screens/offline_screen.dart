import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/offline_state_content.dart';
import '../widgets/premium_button.dart';

enum _ConnectionState { checking, online, offline }

/// A standalone connection-test screen, also reachable from Settings.
/// Doubles as the reference implementation the Shop tab reuses.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  final _connectivity = ConnectivityService();
  _ConnectionState _state = _ConnectionState.checking;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _state = _ConnectionState.checking);
    final online = await _connectivity.hasConnection();
    if (!mounted) return;
    setState(() => _state = online ? _ConnectionState.online : _ConnectionState.offline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Connection')),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: switch (_state) {
            _ConnectionState.checking => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            _ConnectionState.online => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: const Icon(Icons.wifi_rounded, color: AppColors.success, size: 40),
                      ),
                      const SizedBox(height: 24),
                      Text("You're Connected", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      const Text(
                        'Everything that needs the internet will work normally.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      PremiumButton(label: 'Check Again', icon: Icons.refresh_rounded, expand: false, onPressed: _check),
                    ],
                  ),
                ),
              ),
            _ConnectionState.offline => OfflineStateContent(onRetry: _check),
          },
        ),
      ),
    );
  }
}
