
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../timer_service.dart';
import '../../glass_container.dart';

class GalleryControls extends StatelessWidget {
  const GalleryControls({super.key});

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
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(22),
            blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 15,
            opacity: 0.1,
            color: Color(context.select<TimerService, int>((s) => s.contentColor)),
            alignment: Alignment.center,
            border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.2), width: 0.5),
            child: Icon(CupertinoIcons.restart, color: Color(context.select<TimerService, int>((s) => s.contentColor)), size: 18),
          ),
        ),
        const SizedBox(width: 40),
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
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(32),
                blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 20,
                opacity: 0.2,
                color: Color(context.select<TimerService, int>((s) => s.contentColor)),
                alignment: Alignment.center,
                border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.5), width: 0.5),
                child: Icon(
                  isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: Color(context.select<TimerService, int>((s) => s.contentColor)),
                  size: 28,
                ),
              ),
            );
          }
        ),
        const SizedBox(width: 40),
        // Skip
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.read<TimerService>().skip();
          },
          child: GlassContainer(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(22),
            blur: context.select<TimerService, String>((s) => s.backgroundType) == 'image' ? 0 : 15,
            opacity: 0.1,
            color: Color(context.select<TimerService, int>((s) => s.contentColor)),
            alignment: Alignment.center,
            border: Border.all(color: Color(context.select<TimerService, int>((s) => s.contentColor)).withValues(alpha: 0.2), width: 0.5),
            child: Icon(CupertinoIcons.forward_end_fill, color: Color(context.select<TimerService, int>((s) => s.contentColor)), size: 18),
          ),
        ),
      ],
      ),
    );
  }
}
