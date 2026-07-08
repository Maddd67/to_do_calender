class Todo {
  int? id;
  String title;
  String? description;
  String date;
  bool isDone;

  Todo({
    this.id,
    required this.title,
    this.description,
    required this.date,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      isDone: map['isDone'] == 1,
    );
  }
}
