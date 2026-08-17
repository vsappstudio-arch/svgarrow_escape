import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../state/settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/premium_button.dart';

class _TutorialPage {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialPage({required this.icon, required this.title, required this.description});
}

const _pages = [
  _TutorialPage(
    icon: Icons.touch_app_rounded,
    title: 'Tap to Escape',
    description: 'Tap an arrow to send it flying off the grid in the direction it points.',
  ),
  _TutorialPage(
    icon: Icons.block_rounded,
    title: 'Clear the Path',
    description: "An arrow can't escape if another arrow blocks its way. Free the path first.",
  ),
  _TutorialPage(
    icon: Icons.star_rounded,
    title: 'Earn Stars & Coins',
    description: 'Solve levels in fewer moves to earn more stars, coins, and unlock the next level.',
  ),
];

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SettingsController>().markTutorialSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(onPressed: _finish, child: const Text('Skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: Icon(page.icon, size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: PremiumButton(
                label: isLast ? "Let's Play!" : 'Next',
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
