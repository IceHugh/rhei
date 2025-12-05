import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'timer_service.dart';
import 'settings_page.dart';
import 'package:window_manager/window_manager.dart';
import 'widgets/glass_container.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> with TickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  void _showTimerPicker(BuildContext context, TimerService timerService) {
    int initialValue;
    String title;
    Function(int) onChanged;

    switch (timerService.currentMode) {
      case TimerMode.focus:
        initialValue = timerService.focusMinutes;
        title = 'Focus Duration';
        onChanged = (val) => timerService.updateSettings(focus: val);
        break;
      case TimerMode.shortBreak:
        initialValue = timerService.shortBreakMinutes;
        title = 'Short Break Duration';
        onChanged = (val) => timerService.updateSettings(shortBreak: val);
        break;
      case TimerMode.longBreak:
        initialValue = timerService.longBreakMinutes;
        title = 'Long Break Duration';
        onChanged = (val) => timerService.updateSettings(longBreak: val);
        break;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialValue - 1,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    onChanged(selectedItem + 1);
                  },
                  children: List<Widget>.generate(60, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1} min',
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    // Dynamic background colors based on mode
    Color bgTop, bgBottom;
    if (timerService.currentMode == TimerMode.focus) {
      bgTop = isDarkMode ? const Color(0xFF2E3192) : const Color(0xFFA1C4FD);
      bgBottom = isDarkMode ? const Color(0xFF1BFFFF) : const Color(0xFFC2E9FB);
    } else {
      // Break mode
      bgTop = isDarkMode ? const Color(0xFF0ba360) : const Color(0xFF84fab0);
      bgBottom = isDarkMode ? const Color(0xFF3cba92) : const Color(0xFF8fd3f4);
    }

    return CupertinoPageScaffold(
      // We use a Stack to layer the background, the animated orbs, and the glass UI
      child: Stack(
        children: [
          // 1. Animated Gradient Background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bgTop, bgBottom],
                ),
              ),
            ),
          ),

          // 2. Floating Orbs (for depth and refraction through glass)
          Positioned(
            top: -50,
            right: -50,
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * _breathingController.value),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.purpleAccent.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -30 * _breathingController.value),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                // Custom App Bar (Draggable & Traffic Light Safe)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: SizedBox(
                    height: 40,
                    child: DragToMoveArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Settings Button
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(50),
                              blur: 15,
                              opacity: 0.1,
                              child: const Padding(
                                padding: EdgeInsets.all(8), // Slightly smaller padding
                                child: Icon(CupertinoIcons.settings, size: 20, color: CupertinoColors.label),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(builder: (context) => const SettingsPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final shortSide = min(constraints.maxWidth, constraints.maxHeight);
                      final circleSize = shortSide * 0.50; // Reduced from 0.55

                      return Center(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10), // Reduced from 30

                                // Central Glass Timer
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Background Glow
                                    Container(
                                      width: circleSize,
                                      height: circleSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.15),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Progress Indicator
                                    SizedBox(
                                      width: circleSize + 20,
                                      height: circleSize + 20,
                                      child: CustomPaint(
                                        painter: ProgressPainter(
                                          progress: timerService.progress,
                                          color: Colors.white.withOpacity(0.9),
                                          trackColor: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                    // Main Glass Circle
                                    GlassContainer(
                                      width: circleSize,
                                      height: circleSize,
                                      borderRadius: BorderRadius.circular(circleSize),
                                      blur: 25,
                                      opacity: 0.12,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Time
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                _showTimerPicker(context, timerService);
                                              },
                                              child: Text(
                                                timerService.formattedTime,
                                                style: TextStyle(
                                                  fontSize: circleSize * 0.28, // Slightly larger relative font
                                                  fontWeight: FontWeight.w200,
                                                  fontFamily: '.SF Pro Display',
                                                  letterSpacing: -2.0,
                                                  color: CupertinoColors.white,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 10,
                                                      color: Colors.black.withOpacity(0.1),
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Status Label
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                timerService.isRunning ? 'RUNNING' : 'PAUSED',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30), // Reduced from 40

                                // Control Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Reset
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        timerService.resetTimer();
                                      },
                                      child: GlassContainer(
                                        width: 60, // Reduced from 65
                                        height: 60,
                                        borderRadius: BorderRadius.circular(30),
                                        blur: 15,
                                        opacity: 0.15,
                                        alignment: Alignment.center,
                                        child: const Icon(CupertinoIcons.restart, color: Colors.white, size: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 30), // Reduced from 40
                                    // Play/Pause
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        timerService.toggleTimer();
                                      },
                                      child: GlassContainer(
                                        width: 80, // Reduced from 90
                                        height: 80,
                                        borderRadius: BorderRadius.circular(40),
                                        blur: 20,
                                        opacity: 0.25,
                                        alignment: Alignment.center,
                                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                                        child: Icon(
                                          timerService.isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30), // Reduced from 40
                                    // Skip (Placeholder logic)
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        // Future: Skip logic
                                        HapticFeedback.mediumImpact();
                                      },
                                      child: GlassContainer(
                                        width: 60, // Reduced from 65
                                        height: 60,
                                        borderRadius: BorderRadius.circular(30),
                                        blur: 15,
                                        opacity: 0.15,
                                        alignment: Alignment.center,
                                        child: const Icon(CupertinoIcons.forward_end_fill, color: Colors.white, size: 24),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20), // Reduced from 40
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

}

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  ProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 5.0;

    // Background Circle
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.trackColor != trackColor;
  }
}