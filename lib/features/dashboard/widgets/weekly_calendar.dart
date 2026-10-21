import 'package:flutter/material.dart';

class WeeklyCalendar extends StatelessWidget {
  final VoidCallback? onAddPressed;
  final int selectedDay;
  final Function(int) onDaySelected;

  const WeeklyCalendar({
    super.key,
    this.onAddPressed,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekDays = ["M", "T", "W", "T", "F", "S", "S"];
    // Monday of the current week, used to show the real day numbers.
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Schedule",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: onAddPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 16, color: Color(0xFF6C63FF)),
                      SizedBox(width: 4),
                      Text(
                        "Add Class",
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = dayNum == selectedDay;
              return GestureDetector(
                onTap: () => onDaySelected(dayNum),
                child: Column(
                  children: [
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey.shade200),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              "${monday.add(Duration(days: index)).day}",
                              style: const TextStyle(color: Colors.black87),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
