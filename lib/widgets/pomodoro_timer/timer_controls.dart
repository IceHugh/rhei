
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../timer_service.dart';
import '../glass_container.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: context.select<TimerService, double>((s) => s.uiOpacity),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Reset
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<TimerService>().resetTimer();
          },
          child: GlassContainer(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(30),
            blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 15,
            opacity: 0.15,
            color: Color(context.select<TimerService, int>((s) => s.contentColor)),
            alignment: Alignment.center,
            border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.3), width: 1),
            child: Icon(CupertinoIcons.restart, color: Color(context.select<TimerService, int>((s) => s.contentColor)), size: 24),
          ),
        ),
        const SizedBox(width: 30),
        // Play/Pause
        Selector<TimerService, bool>(
          selector: (_, service) => service.isRunning,
          builder: (context, isRunning, child) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                context.read<TimerService>().toggleTimer();
              },
              child: GlassContainer(
                width: 80,
                height: 80,
                borderRadius: BorderRadius.circular(40),
                blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 20,
                opacity: 0.25,
                color: Color(context.select<TimerService, int>((s) => s.contentColor)),
                alignment: Alignment.center,
                border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.6), width: 1),
                child: Icon(
                  isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: Color(context.select<TimerService, int>((s) => s.contentColor)),
                  size: 40,
                ),
              ),
            );
          }
        ),
        const SizedBox(width: 30),
        // Skip
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<TimerService>().skip();
          },
          child: GlassContainer(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(30),
            blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 15,
            opacity: 0.15,
            color: Color(context.select<TimerService, int>((s) => s.contentColor)),
            alignment: Alignment.center,
            border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.3), width: 1),
            child: Icon(CupertinoIcons.forward_end_fill, color: Color(context.select<TimerService, int>((s) => s.contentColor)), size: 24),
          ),
        ),
      ],
      ),
    );
  }
}
