import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../models/course_model.dart';
import 'add_course_screen.dart';
import '../../services/notification_service.dart'; // 👇 Bildirim servisi eklendi

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;
  final Function(CourseModel) onCourseUpdated;
  final Function(String) onDeleteCourse;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.onCourseUpdated,
    required this.onDeleteCourse,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  late CourseModel _currentCourse;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
  }

  void _openEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourseScreen(
          courseToEdit: _currentCourse,
          onSave: (updatedCourse) {
            setState(() => _currentCourse = updatedCourse);
            widget.onCourseUpdated(updatedCourse);
          },
          onDelete: () {
            widget.onDeleteCourse(_currentCourse.id);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _editTask(TaskModel task, int index) {
    String editTitle = task.title;
    DateTime? editDate = task.dueDate;
    TimeOfDay editTime = task.dueDate != null
        ? TimeOfDay.fromDateTime(task.dueDate!)
        : const TimeOfDay(hour: 23, minute: 59);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: editTitle),
                    decoration: const InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => editTitle = val,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event),
                          label: Text(
                            editDate == null
                                ? "Set Date"
                                : DateFormat("MMM d").format(editDate!),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: editDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null)
                              setDialogState(() => editDate = picked);
                          },
                        ),
                      ),
                      if (editDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () {
                            _showScrollableTimePicker(
                              context,
                              editTime,
                              (t) => setDialogState(() => editTime = t),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editTitle.isNotEmpty) {
                      DateTime? finalDate;
                      if (editDate != null) {
                        finalDate = DateTime(
                          editDate!.year,
                          editDate!.month,
                          editDate!.day,
                          editTime.hour,
                          editTime.minute,
                        );
                      }
                      setState(() {
                        _currentCourse.relatedTasks[index] = TaskModel(
                          id: task.id,
                          title: editTitle,
                          isCompleted: task.isCompleted,
                          dueDate: finalDate,
                        );
                      });
                      widget.onCourseUpdated(_currentCourse);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task?"),
        content: const Text("Are you sure you want to remove this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentCourse.relatedTasks.removeAt(index);
              });
              widget.onCourseUpdated(_currentCourse);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalTasks = _currentCourse.relatedTasks.length;
    int completedTasks = _currentCourse.relatedTasks
        .where((t) => t.isCompleted)
        .length;
    double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;
    final ongoingTasks = _currentCourse.relatedTasks
        .where((t) => !t.isCompleted)
        .toList();
    final completedTasksList = _currentCourse.relatedTasks
        .where((t) => t.isCompleted)
        .toList();
    ongoingTasks.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _currentCourse.color,
        foregroundColor: Colors.white,
        title: Text(
          _currentCourse.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openEditScreen,
            icon: const Icon(Icons.edit),
            tooltip: "Edit Course",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _currentCourse.color,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Class Schedule",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_currentCourse.schedules.isEmpty)
                    const Text(
                      "No schedule set.",
                      style: TextStyle(color: Colors.white),
                    )
                  else
                    ..._currentCourse.schedules.map(
                      (schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_days[schedule.dayOfWeek - 1]}  •  ${schedule.timeRange}  •  ${schedule.location}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tasks Progress",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "$completedTasks / $totalTasks",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (ongoingTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upcoming Deadlines",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...ongoingTasks.map((task) => _buildTaskItem(task)),
            ],
            if (completedTasksList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Completed",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              ...completedTasksList.map((task) => _buildTaskItem(task)),
            ],
            if (_currentCourse.relatedTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No tasks yet!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: _currentCourse.color,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Task", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    final int realIndex = _currentCourse.relatedTasks.indexOf(task);
    bool isUrgent = false;
    String dateText = "";
    if (task.dueDate != null) {
      dateText = DateFormat("MMM d, HH:mm").format(task.dueDate!);
      final now = DateTime.now();
      final difference = task.dueDate!.difference(now).inHours;
      if (!task.isCompleted &&
          difference < 72 &&
          task.dueDate!.isAfter(now.subtract(const Duration(hours: 1)))) {
        isUrgent = true;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.shade50
            : (task.isCompleted ? Colors.grey[50] : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? Colors.red.shade200
              : (task.isCompleted ? Colors.transparent : Colors.grey.shade200),
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 8),
        leading: Checkbox(
          activeColor: _currentCourse.color,
          value: task.isCompleted,
          onChanged: (bool? val) {
            setState(() => task.isCompleted = val ?? false);
            widget.onCourseUpdated(_currentCourse);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Colors.grey
                : (isUrgent ? Colors.red[900] : Colors.black87),
            fontWeight: isUrgent ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: task.dueDate != null && !task.isCompleted
            ? Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: isUrgent ? Colors.red : _currentCourse.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateText + (isUrgent ? " (Soon!)" : ""),
                    style: TextStyle(
                      color: isUrgent ? Colors.red : _currentCourse.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: () => _editTask(task, realIndex),
              tooltip: "Edit",
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.grey,
              ),
              onPressed: () => _deleteTask(realIndex),
              tooltip: "Delete",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showScrollableTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeChanged,
  ) async {
    Duration initialTimer = Duration(
      hours: initialTime.hour,
      minutes: initialTime.minute,
    );
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: initialTimer,
                  onTimerDurationChanged: (Duration changedTimer) {
                    onTimeChanged(
                      TimeOfDay(
                        hour: changedTimer.inHours,
                        minute: changedTimer.inMinutes % 60,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    String newTaskTitle = "";
    DateTime? selectedDate;
    TimeOfDay selectedTime = const TimeOfDay(hour: 23, minute: 59);
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Title (e.g. Homework 1)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => newTaskTitle = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event),
                          label: Text(
                            selectedDate == null
                                ? "Set Due Date"
                                : DateFormat("MMM d").format(selectedDate!),
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null)
                              setDialogState(() => selectedDate = pickedDate);
                          },
                        ),
                      ),
                      if (selectedDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () {
                            _showScrollableTimePicker(context, selectedTime, (
                              newTime,
                            ) {
                              setDialogState(() => selectedTime = newTime);
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  if (selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Due: ${DateFormat("MMM d").format(selectedDate!)} at ${selectedTime.format(context)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newTaskTitle.isNotEmpty) {
                      DateTime? finalDueDate;
                      if (selectedDate != null) {
                        finalDueDate = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      }

                      // 👇 BİLDİRİM ID OLUŞTURUYORUZ
                      int notificationId =
                          DateTime.now().millisecondsSinceEpoch ~/ 1000;

                      setState(() {
                        _currentCourse.relatedTasks.add(
                          TaskModel(
                            id: notificationId.toString(),
                            title: newTaskTitle,
                            dueDate: finalDueDate,
                          ),
                        );
                      });

                      // 👇 BİLDİRİMİ TETİKLİYORUZ
                      if (finalDueDate != null) {
                        NotificationService().scheduleTaskNotification(
                          notificationId,
                          newTaskTitle,
                          finalDueDate,
                        );
                      }

                      widget.onCourseUpdated(_currentCourse);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentCourse.color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
