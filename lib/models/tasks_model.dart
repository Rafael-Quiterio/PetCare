import 'dart:convert';

class Task {
  final int id;
  final String animalId;
  final String title;
  final DateTime time;
  final String taskType;
  final bool isCompleted;

  Task({
    required this.id,
    required this.animalId,
    required this.title,
    required this.time,
    required this.taskType,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'animalId' : animalId,
      'title' : title,
      'time' : time.toIso8601String(), // Salva data como Texto ISO
      'taskType' : taskType,
      'isCompleted' : isCompleted ? 1 : 0,
    };
  }


  // Transforma Mapa (JSON) -> Objeto
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id : map['id'],
      animalId: map['animalId'],
      title: map['title'],
      time: DateTime.parse(map['time']),
      taskType: map['taskType'] ?? 'general',
      isCompleted: (map['isCompleted'] == 1 || map['isCompleted'] == true),
    );
  }

  String toJson() =>json.encode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

}

