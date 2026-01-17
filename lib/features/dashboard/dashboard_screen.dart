import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/course_model.dart'; // Model dosyanın yolu
import 'widgets/weekly_calendar.dart'; // Takvim widget'ın
import 'widgets/course_card.dart'; // Ders kartı widget'ın
import 'add_course_screen.dart'; // Ders ekleme ekranı
import 'course_detail_screen.dart'; // Detay ekranı
import '../focus_mode/focus_screen.dart'; // Focus ekranı
import '../pet_room/pet_room_screen.dart'; // Pet ekranı

// ---------------------------------------------------------
// 1. ANA EKRAN (DASHBOARD SCREEN)
// Verileri yönetir ve Sayfalar Arası Geçişi Sağlar
// ---------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<CourseModel> _allCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coursesJson = prefs.getString('saved_courses');

    if (coursesJson != null) {
      final List<dynamic> decodedList = jsonDecode(coursesJson);
      setState(() {
        _allCourses = decodedList.map((e) => CourseModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _persistCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      _allCourses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_courses', encodedList);
  }

  void _saveCourse(CourseModel course) {
    setState(() {
      final index = _allCourses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _allCourses[index] = course;
      } else {
        _allCourses.add(course);
      }
    });
    _persistCourses();
  }

  void _deleteCourse(String courseId) {
    setState(() {
      _allCourses.removeWhere((c) => c.id == courseId);
    });
    _persistCourses();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        ),
      );
    }

    // 👇 BURASI DÜZELDİ: Artık kendi içinde DashboardScreen çağırmıyor.
    // Direkt MyWeekTab'ı çağırıyor.
    final List<Widget> pages = [
      MyWeekTab(
        courses: _allCourses,
        onAddClassTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCourseScreen(onSave: _saveCourse),
            ),
          );
        },
        onCourseUpdated: _saveCourse,
        onDeleteCourse: _deleteCourse,
      ),
      const FocusScreen(), // 2. Sayfa: Focus
      const PetRoomScreen(), // 3. Sayfa: Pet
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                "Hello, Student 👋",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            )
          : null,
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: const Color(0xFF6C63FF).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'My Week',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            label: 'My Pet',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. HAFTALIK GÖRÜNÜM (MY WEEK TAB)
// Dersleri ve Ödevleri Listeler
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
    if (code.length > 4) {
      code = code.substring(0, 4).toUpperCase();
    }
    return {'code': code.toUpperCase(), 'number': number};
  }

  @override
  Widget build(BuildContext context) {
    // Bugünkü dersleri filtrele
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

    // Gelecek ödevleri filtrele
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
            // 👇 ÖNEMLİ: Course'un kendisini alıyoruz ki tıklayınca gidelim
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
          // Takvim
          WeeklyCalendar(
            selectedDay: _selectedDayOfWeek,
            onAddPressed: widget.onAddClassTap,
            onDaySelected: (int day) =>
                setState(() => _selectedDayOfWeek = day),
          ),
          const SizedBox(height: 24),

          // Günün Programı Başlığı
          Text(
            "${_dayNamesFull[_selectedDayOfWeek - 1]}'s Schedule",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Günün Dersleri
          if (todaysSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text(
                      "No classes today!",
                      style: const TextStyle(color: Colors.grey),
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

          // --- YAKLAŞAN GÖREVLER (Burada Tıklama Özelliği Var) ---
          if (upcomingTasks.isNotEmpty) ...[
            const Text(
              "Upcoming Deadlines (Next 7 Days) 🚨",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...upcomingTasks.map((item) {
              final task = item['task'] as TaskModel;
              final course = item['course'] as CourseModel;

              final daysLeft = task.dueDate!.difference(DateTime.now()).inDays;
              final hoursLeft = task.dueDate!
                  .difference(DateTime.now())
                  .inHours;

              bool isUrgent =
                  hoursLeft < 72 &&
                  task.dueDate!.isAfter(
                    DateTime.now().subtract(const Duration(hours: 1)),
                  );

              String timeText = "";
              if (daysLeft == 0)
                timeText = "TODAY";
              else if (daysLeft == 1)
                timeText = "TOMORROW";
              else
                timeText = DateFormat("MMM d").format(task.dueDate!);

              // 👇 TIKLANABİLİR ALAN (GestureDetector)
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(
                        course: course,
                        onCourseUpdated: widget.onCourseUpdated,
                        onDeleteCourse: widget.onDeleteCourse,
                      ),
                    ),
                  );
                },
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? Colors.red.withOpacity(0.2)
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
                                color: isUrgent ? Colors.red[900] : Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat("HH:mm").format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUrgent
                                    ? Colors.red[900]
                                    : Colors.black87,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isUrgent
                                    ? Colors.red[900]
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              course.name,
                              style: TextStyle(
                                color: isUrgent
                                    ? Colors.red[300]
                                    : course.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isUrgent ? Colors.red[200] : Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 30),

          // --- TÜM DERSLER (Tıklanabilir) ---
          if (widget.courses.isNotEmpty) ...[
            const Text(
              "All Courses",
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
                  final String displayCode = parts['code']!;
                  final String displayNumber = parts['number']!;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                            course: course,
                            onCourseUpdated: widget.onCourseUpdated,
                            onDeleteCourse: widget.onDeleteCourse,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: course.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: course.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              displayCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (displayNumber.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                displayNumber,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
