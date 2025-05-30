import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime weekStartDate;
  final List<int> datesWithLogs;
  final Function(DateTime) onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  const DaySelector({
    super.key,
    required this.selectedDate,
    required this.weekStartDate,
    required this.datesWithLogs,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onToday,
  });

  List<String> get _daysOfWeek => [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  List<String> get _months => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<WeekDay> _generateWeekDays() {
    final result = <WeekDay>[];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = weekStartDate.add(Duration(days: i));
      final hasEntries =
          datesWithLogs.contains(date.day) &&
          date.month == weekStartDate.month &&
          date.year == weekStartDate.year;

      result.add(
        WeekDay(
          date: date.day,
          month: date.month,
          year: date.year,
          day: _daysOfWeek[date.weekday % 7],
          isToday:
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
          hasEntries: hasEntries,
          dateObj: DateTime(date.year, date.month, date.day),
        ),
      );
    }

    return result;
  }

  String _getWeekRangeText() {
    final weekEndDate = weekStartDate.add(const Duration(days: 6));

    final startMonth = _months[weekStartDate.month - 1].substring(0, 3);
    final endMonth = _months[weekEndDate.month - 1].substring(0, 3);

    if (weekStartDate.month == weekEndDate.month) {
      return '$startMonth ${weekStartDate.day}-${weekEndDate.day}, ${weekStartDate.year}';
    } else {
      return '$startMonth ${weekStartDate.day} - $endMonth ${weekEndDate.day}, ${weekStartDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weekDays = _generateWeekDays();

    return Column(
      children: [
        // Week view header with Today button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                ),
              ),

              GestureDetector(
                onTap: onToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getWeekRangeText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                ),
              ),
            ],
          ),
        ),

        // Week view
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                weekDays.map((item) {
                  final isSelected =
                      selectedDate.year == item.dateObj.year &&
                      selectedDate.month == item.dateObj.month &&
                      selectedDate.day == item.dateObj.day;

                  return GestureDetector(
                    onTap: () => onDateSelected(item.dateObj),
                    child: Container(
                      width: 40,
                      height: 70,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : item.isToday
                                ? colorScheme.primaryContainer
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.day,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : item.isToday
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.date.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : item.isToday
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.hasEntries && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class WeekDay {
  final int date;
  final int month;
  final int year;
  final String day;
  final bool isToday;
  final bool hasEntries;
  final DateTime dateObj;

  WeekDay({
    required this.date,
    required this.month,
    required this.year,
    required this.day,
    required this.isToday,
    required this.hasEntries,
    required this.dateObj,
  });
}
