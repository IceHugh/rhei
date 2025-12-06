
import 'package:flutter/cupertino.dart';
import '../../timer_service.dart';

void showTimerPickerSheet(BuildContext context, TimerService timerService) {
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
