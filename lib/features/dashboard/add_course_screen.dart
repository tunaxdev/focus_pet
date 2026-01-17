import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  final CourseModel? courseToEdit;
  final Function(CourseModel) onSave;
  final VoidCallback? onDelete; // 👇 YENİ: Silme fonksiyonu

  const AddCourseScreen({
    super.key,
    this.courseToEdit,
    required this.onSave,
    this.onDelete, // Constructor'a eklendi
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final List<Color> _palette = [
    const Color(0xFFFF8A65),
    const Color(0xFF64B5F6),
    const Color(0xFF9575CD),
    const Color(0xFFE57373),
    const Color(0xFF81C784),
    const Color(0xFFFFD54F),
    const Color(0xFF4DB6AC),
    const Color(0xFFA1887F),
    const Color(0xFF90A4AE),
    const Color(0xFFF06292),
  ];

  late Color _selectedColor;
  late List<CourseSchedule> _schedules;
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _nameController = TextEditingController(text: widget.courseToEdit!.name);
      _selectedColor = widget.courseToEdit!.color;
      _schedules = List.from(widget.courseToEdit!.schedules);
    } else {
      _nameController = TextEditingController();
      _selectedColor = _palette[0];
      _schedules = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.courseToEdit == null ? "Create Course" : "Edit Course",
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: "Course Name",
                  hintText: "e.g., Mathematics",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.book_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) => value!.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 24),

              const Text(
                "Color Tag",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _palette.length,
                  itemBuilder: (context, index) {
                    final color = _palette[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Schedule",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: () => _showSessionDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Session"),
                  ),
                ],
              ),

              if (_schedules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "No sessions added yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _days[schedule.dayOfWeek - 1].substring(0, 3),
                            style: TextStyle(
                              color: _selectedColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          schedule.timeRange,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(schedule.location),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueGrey,
                              ),
                              onPressed: () => _showSessionDialog(
                                existingSession: schedule,
                                index: index,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _schedules.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),

              // UPDATE / CREATE BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: _selectedColor.withOpacity(0.4),
                  ),
                  child: Text(
                    widget.courseToEdit == null
                        ? "Create Course"
                        : "Update Course",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 👇 YENİ: DELETE COURSE BUTONU (Sadece düzenleme modundaysa görünür)
              if (widget.courseToEdit != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Emin misin diye soralım
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Course?"),
                          content: const Text(
                            "This will delete the course and all its tasks permanently.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialogu kapat
                                if (widget.onDelete != null)
                                  widget
                                      .onDelete!(); // Silme fonksiyonunu çağır
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ), // Kırmızı Şerit
                      foregroundColor: Colors.red, // Kırmızı Yazı
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white, // İçi Beyaz
                    ),
                    child: const Text(
                      "Delete Course",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
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

  void _showSessionDialog({CourseSchedule? existingSession, int? index}) {
    int selectedDay = existingSession?.dayOfWeek ?? 1;
    TimeOfDay start =
        existingSession?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end =
        existingSession?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    String loc = existingSession?.location ?? "";
    TextEditingController locController = TextEditingController(text: loc);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingSession == null ? "Add Session" : "Edit Session",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: const InputDecoration(
                      labelText: "Day",
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      7,
                      (i) =>
                          DropdownMenuItem(value: i + 1, child: Text(_days[i])),
                    ),
                    onChanged: (val) =>
                        setDialogState(() => selectedDay = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => loc = val,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showScrollableTimePicker(
                            context,
                            start,
                            (t) => setDialogState(() => start = t),
                          ),
                          child: Text(start.format(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showScrollableTimePicker(
                            context,
                            end,
                            (t) => setDialogState(() => end = t),
                          ),
                          child: Text(end.format(context)),
                        ),
                      ),
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
                    if (loc.isNotEmpty) {
                      setState(() {
                        final newSession = CourseSchedule(
                          dayOfWeek: selectedDay,
                          startTime: start,
                          endTime: end,
                          location: loc,
                        );
                        if (index != null) {
                          _schedules[index] = newSession;
                        } else {
                          _schedules.add(newSession);
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(existingSession == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      if (_schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add at least one session!")),
        );
        return;
      }
      final String id = widget.courseToEdit?.id ?? DateTime.now().toString();
      final course = CourseModel(
        id: id,
        name: _nameController.text,
        color: _selectedColor,
        schedules: List.from(_schedules),
        relatedTasks: List.from(
          widget.courseToEdit?.relatedTasks ?? [],
          growable: true,
        ),
      );
      widget.onSave(course);
      Navigator.pop(context);
    }
  }
}
