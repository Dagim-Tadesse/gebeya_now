import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Working hours section widget for provider registration
/// Handles weekly schedule with day toggles and time pickers
class WorkingHoursSection extends StatelessWidget {
  final Map<String, bool> workingDays;
  final Map<String, TimeOfDay> startTimes;
  final Map<String, TimeOfDay> endTimes;
  final Function(String, bool) onDayToggle;
  final Function(String, TimeOfDay) onStartTimeChanged;
  final Function(String, TimeOfDay) onEndTimeChanged;

  const WorkingHoursSection({
    super.key,
    required this.workingDays,
    required this.startTimes,
    required this.endTimes,
    required this.onDayToggle,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Hours',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Weekly Schedule Grid
          ...daysOfWeek.map((day) {
            final isWorking = workingDays[day] ?? false;
            final startTime =
                startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0);
            final endTime =
                endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Switch(
                            value: isWorking,
                            onChanged: (value) => onDayToggle(day, value),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            day,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isWorking
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWorking) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (time != null) {
                              onStartTimeChanged(day, time);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startTime.format(context),
                                  style: theme.textTheme.bodySmall,
                                ),
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  size: 4.w,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text('to', style: theme.textTheme.bodySmall),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (time != null) {
                              onEndTimeChanged(day, time);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endTime.format(context),
                                  style: theme.textTheme.bodySmall,
                                ),
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  size: 4.w,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (day != daysOfWeek.last) SizedBox(height: 1.5.h),
              ],
            );
          }),
        ],
      ),
    );
  }
}
