
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'widgets/pomodoro_timer/timer_background.dart';
import 'widgets/pomodoro_timer/layouts/default_layout.dart';
import 'widgets/pomodoro_timer/layouts/gallery_layout.dart';
import 'timer_service.dart'; // Ensure TimerService is imported for Selector

class PomodoroTimerPage extends StatelessWidget {
  const PomodoroTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          const TimerBackground(),
          const BackgroundOrbs(),
          SafeArea(
            child: Selector<TimerService, String>(
              selector: (_, service) => service.layoutMode,
              builder: (context, layoutMode, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: layoutMode == 'gallery' 
                      ? const GalleryLayout()
                      : const DefaultLayout(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}