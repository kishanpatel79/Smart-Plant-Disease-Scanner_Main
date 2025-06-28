import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FarmerNotesScreen extends StatefulWidget {
  const FarmerNotesScreen({Key? key}) : super(key: key);

  @override
  State<FarmerNotesScreen> createState() => _FarmerNotesScreenState();
}

class _FarmerNotesScreenState extends State<FarmerNotesScreen> {
  final List<Map<String, String>> _notes = [];
  final TextEditingController _noteController = TextEditingController();

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        _notes.insert(0, {
          "text": _noteController.text,
          "date": DateFormat('MMM d, yyyy').format(DateTime.now()),
        });
      });
      _noteController.clear();
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Write a note...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _addNote,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(_notes[index]["text"] ?? ""),
                      subtitle: Text(_notes[index]["date"] ?? ""),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
