import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'todo.dart';
import 'todo_item.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Todo> _todos = [];
  List<String> _markedDates = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _loadMarkedDates();
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.instance.readByDate(_fmt(_selectedDay));
    setState(() => _todos = todos);
  }

  Future<void> _loadMarkedDates() async {
    final dates = await DatabaseHelper.instance.readAllDates();
    setState(() => _markedDates = dates);
  }

  Future<void> _openForm({Todo? todo}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(todo: todo, date: _fmt(_selectedDay)),
      ),
    );
    if (result == true) {
      _loadTodos();
      _loadMarkedDates();
    }
  }

  Future<void> _toggleDone(Todo todo) async {
    todo.isDone = !todo.isDone;
    await DatabaseHelper.instance.update(todo);
    _loadTodos();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.delete(id);
      _loadTodos();
      _loadMarkedDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Kalender', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadTodos();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, day, _) {
                if (_markedDates.contains(_fmt(day))) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(' tugas', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _todos.isEmpty
                ? const Center(child: Text('Tidak ada tugas\nTambahkan dengan tombol +', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (_, i) => TodoItem(
                      todo: _todos[i],
                      onToggle: () => _toggleDone(_todos[i]),
                      onEdit: () => _openForm(todo: _todos[i]),
                      onDelete: () => _delete(_todos[i].id!),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
