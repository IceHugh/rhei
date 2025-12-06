
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../timer_service.dart';

class TimerBackground extends StatelessWidget {
  const TimerBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Selector<TimerService, TimerMode>(
      selector: (_, service) => service.currentMode,
      builder: (context, currentMode, child) {
        final timerService = Provider.of<TimerService>(context);
        
        if (timerService.backgroundType == 'color') {
          return Container(
            color: Color(timerService.backgroundColor),
          );
        } else if (timerService.backgroundType == 'image' && timerService.backgroundImagePath.isNotEmpty) {
           return Stack(
             fit: StackFit.expand,
             children: [
               // Fallback Gradient while loading
               Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                     colors: isDarkMode 
                        ? [const Color(0xFF2E3192), const Color(0xFF1BFFFF)]
                        : [const Color(0xFFA1C4FD), const Color(0xFFC2E9FB)],
                   ),
                 ),
               ),
               // The Image with fade-in
               Image.file(
                 File(timerService.backgroundImagePath),
                 fit: BoxFit.cover,
                 width: double.infinity,
                 height: double.infinity,
                 errorBuilder: (ctx, err, stack) => Container(color: Colors.black),
                 frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                   if (wasSynchronouslyLoaded) return child;
                   return AnimatedOpacity(
                     opacity: frame == null ? 0 : 1,
                     duration: const Duration(milliseconds: 500),
                     curve: Curves.easeOut,
                     child: child,
                   );
                 },
               ),
             ],
           );
        }

        Color bgTop, bgBottom;
        if (currentMode == TimerMode.focus) {
          bgTop = isDarkMode ? const Color(0xFF2E3192) : const Color(0xFFA1C4FD);
          bgBottom = isDarkMode ? const Color(0xFF1BFFFF) : const Color(0xFFC2E9FB);
        } else {
          bgTop = isDarkMode ? const Color(0xFF0ba360) : const Color(0xFF84fab0);
          bgBottom = isDarkMode ? const Color(0xFF3cba92) : const Color(0xFF8fd3f4);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgTop, bgBottom],
            ),
          ),
        );
      },
    );
  }
}

class BackgroundOrbs extends StatelessWidget {
  const BackgroundOrbs({super.key});

  @override

  Widget build(BuildContext context) {
    final backgroundType = context.select<TimerService, String>((s) => s.backgroundType);
    if (backgroundType != 'default') {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purpleAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blueAccent.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
