import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({Key? key}) : super(key: key);

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<String>> _tasksByDate = {};
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasksByDate.putIfAbsent(dateKey, () => []);
        _tasksByDate[dateKey]!.add(task);
        _taskController.clear();
      });
    }
  }

  void _deleteTask(String task) {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _tasksByDate[dateKey]!.remove(task);
      if (_tasksByDate[dateKey]!.isEmpty) {
        _tasksByDate.remove(dateKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<String> tasks = _tasksByDate[dateKey] ?? [];

    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onDateChanged: (date) {
            setState(() => _selectedDate = date);
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _taskController,
          decoration: InputDecoration(
            hintText:
                "Enter task for ${DateFormat('MMM d').format(_selectedDate)}",
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTask,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Tasks for selected date:",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text("No tasks added yet."))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(tasks[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(tasks[index]),
                        ),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}
