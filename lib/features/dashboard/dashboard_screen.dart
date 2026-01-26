import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- CORE ---
import '../../core/constants/app_strings.dart';
import '../../providers/course_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/course_model.dart';

// --- EKRANLAR ---
import '../focus_mode/focus_screen.dart';
import '../pet_room/pet_room_screen.dart';
import 'add_course_screen.dart';
import 'course_detail_screen.dart';

// --- WIDGETS ---
import 'widgets/weekly_calendar.dart';
import 'widgets/course_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/settings_icon.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final settings = context.watch<SettingsProvider>();

    if (courseProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      MyWeekTab(
        courses: courseProvider.courses,
        onAddClassTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCourseScreen(
                onSave: (course) =>
                    context.read<CourseProvider>().saveCourse(course),
              ),
            ),
          );
        },
        onCourseUpdated: (course) =>
            context.read<CourseProvider>().saveCourse(course),
        onDeleteCourse: (id) => context.read<CourseProvider>().deleteCourse(id),
      ),
      const FocusScreen(),
      const PetRoomScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ✅ APPBAR: Focus ekranıyla tam hizalı
      appBar: _selectedIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleSpacing: 16,
              title: Text(
                "Hi, ${settings.username}! 👋",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: const [
                StreakBadge(),
                SizedBox(width: 4),
                SettingsIcon(),
                SizedBox(width: 12),
              ],
            )
          : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: AppStrings.navMyWeek,
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: AppStrings.navFocus,
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            label: AppStrings.navPet,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// MY WEEK TAB
// ---------------------------------------------------------
class MyWeekTab extends StatefulWidget {
  final List<CourseModel> courses;
  final VoidCallback onAddClassTap;
  final Function(CourseModel) onCourseUpdated;
  final Function(String) onDeleteCourse;

  const MyWeekTab({
    super.key,
    required this.courses,
    required this.onAddClassTap,
    required this.onCourseUpdated,
    required this.onDeleteCourse,
  });

  @override
  State<MyWeekTab> createState() => _MyWeekTabState();
}

class _MyWeekTabState extends State<MyWeekTab> {
  int _selectedDayOfWeek = DateTime.now().weekday;
  final List<String> _dayNamesFull = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  Map<String, String> _smartSplit(String name) {
    String code = "";
    String number = "";
    String trimmed = name.trim();
    if (trimmed.contains(' ')) {
      final parts = trimmed.split(' ');
      code = parts[0];
      number = parts.sublist(1).join(' ');
    } else {
      int? firstDigitIndex;
      for (int i = 0; i < trimmed.length; i++) {
        if (int.tryParse(trimmed[i]) != null) {
          firstDigitIndex = i;
          break;
        }
      }
      if (firstDigitIndex != null && firstDigitIndex > 0) {
        code = trimmed.substring(0, firstDigitIndex);
        number = trimmed.substring(firstDigitIndex);
      } else {
        code = trimmed;
      }
    }
    if (code.length > 4) code = code.substring(0, 4).toUpperCase();
    return {'code': code.toUpperCase(), 'number': number};
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> todaysSessions = [];
    for (var course in widget.courses) {
      for (var schedule in course.schedules) {
        if (schedule.dayOfWeek == _selectedDayOfWeek) {
          todaysSessions.add({'course': course, 'schedule': schedule});
        }
      }
    }
    todaysSessions.sort(
      (a, b) => (a['schedule'] as CourseSchedule).startTime.hour.compareTo(
        (b['schedule'] as CourseSchedule).startTime.hour,
      ),
    );

    final List<Map<String, dynamic>> upcomingTasks = [];
    final now = DateTime.now();
    final oneWeekLater = now.add(const Duration(days: 7));

    for (var course in widget.courses) {
      for (var task in course.relatedTasks) {
        if (!task.isCompleted && task.dueDate != null) {
          bool isFuture = task.dueDate!.isAfter(
            now.subtract(const Duration(days: 1)),
          );
          bool isWithinWeek = task.dueDate!.isBefore(oneWeekLater);
          if (isFuture && isWithinWeek) {
            upcomingTasks.add({'task': task, 'course': course});
          }
        }
      }
    }
    upcomingTasks.sort(
      (a, b) => (a['task'] as TaskModel).dueDate!.compareTo(
        (b['task'] as TaskModel).dueDate!,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeeklyCalendar(
            selectedDay: _selectedDayOfWeek,
            onAddPressed: widget.onAddClassTap,
            onDaySelected: (int day) =>
                setState(() => _selectedDayOfWeek = day),
          ),
          const SizedBox(height: 24),
          Text(
            "${_dayNamesFull[_selectedDayOfWeek - 1]}${AppStrings.scheduleTitleSuffix}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (todaysSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text(
                      AppStrings.noClassesToday,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...todaysSessions.map(
              (item) => CourseCard(
                course: item['course'] as CourseModel,
                schedule: item['schedule'] as CourseSchedule,
                onCourseUpdated: widget.onCourseUpdated,
                onDeleteCourse: widget.onDeleteCourse,
              ),
            ),

          const SizedBox(height: 30),

          if (upcomingTasks.isNotEmpty) ...[
            const Text(
              AppStrings.upcomingDeadlines,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...upcomingTasks.map((item) {
              final task = item['task'] as TaskModel;
              final course = item['course'] as CourseModel;
              final daysLeft = task.dueDate!.difference(DateTime.now()).inDays;
              String timeText = daysLeft == 0
                  ? AppStrings.today
                  : (daysLeft == 1
                        ? AppStrings.tomorrow
                        : DateFormat("MMM d").format(task.dueDate!));
              bool isUrgent =
                  task.dueDate!.difference(DateTime.now()).inHours < 72;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(
                      course: course,
                      onCourseUpdated: widget.onCourseUpdated,
                      onDeleteCourse: widget.onDeleteCourse,
                    ),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUrgent
                          ? Colors.red.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUrgent ? Colors.red : Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat("HH:mm").format(task.dueDate!),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              course.name,
                              style: TextStyle(
                                color: course.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 30),
          if (widget.courses.isNotEmpty) ...[
            const Text(
              AppStrings.allCourses,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.courses.length,
                itemBuilder: (context, index) {
                  final course = widget.courses[index];
                  final parts = _smartSplit(course.name);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(
                          course: course,
                          onCourseUpdated: widget.onCourseUpdated,
                          onDeleteCourse: widget.onDeleteCourse,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: course.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            parts['code']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            parts['number']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
