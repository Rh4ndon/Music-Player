import 'package:flutter/material.dart';
import 'package:music_player/core/theme/colors.dart';

class SleepTimerDialog extends StatefulWidget {
  final void Function(Duration duration) onSet;

  const SleepTimerDialog({super.key, required this.onSet});

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  int _selectedMinutes = 30;

  @override
  Widget build(BuildContext context) {
    final options = [5, 10, 15, 30, 45, 60, 90, 120, 180, 240, 300];

    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      title: const Text(
        'Sleep Timer',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((minutes) {
          final isSelected = _selectedMinutes == minutes;
          final hours = minutes ~/ 60;
          final rem = minutes % 60;
          String label;
          if (hours > 0 && rem > 0) {
            label = '${hours}h ${rem}m';
          } else if (hours > 0) {
            label = '$hours hour${hours > 1 ? 's' : ''}';
          } else {
            label = '$minutes minutes';
          }
          return RadioListTile<int>(
            title: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            value: minutes,
            groupValue: _selectedMinutes,
            activeColor: AppColors.primary,
            onChanged: (val) {
              if (val != null) setState(() => _selectedMinutes = val);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            widget.onSet(Duration(minutes: _selectedMinutes));
            Navigator.pop(context);
          },
          child: const Text('Set', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
}
