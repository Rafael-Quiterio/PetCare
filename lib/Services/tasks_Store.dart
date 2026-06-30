import 'dart:convert';

import 'package:animalapp/Services/notification_service.dart';
import 'package:animalapp/models/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksStore extends ChangeNotifier{
  List<Task> _tasks = [];


  //This is for the UI to read so it can show the list
  List<Task> get tasks => _tasks;

  //This is to load the info when the app is opened
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('saved_tasks');

    if(tasksJson != null) {
      // Decodes: String -> List JSON -> Object List Task
      final List<dynamic> decodedList = jsonDecode(tasksJson);
      _tasks = decodedList.map((item) => Task.fromMap(item)).toList();
      notifyListeners();
    }
  }

  //Add tasks
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveToDisk();
    notifyListeners();
  }

  //Delete tasks
  Future<void> deleteTask(int taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    //This cancels de Notification when I swipe to delete the task. if this isn't used the notification will still be alive even with the task being deleted
    await NotificationService().cancelNotification(taskId);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> removeTasksForPet(String animalId) async {

    final tasksToDelete = _tasks.where((t) => t.animalId == animalId).toList();

    if (tasksToDelete.isEmpty) return; 

    // Loop through them to cancel alarms and remove
    for (var task in tasksToDelete) {
      // Cancels the notification 
      await NotificationService().cancelNotification(task.id);
      
      // Remove from the local memory list
      _tasks.remove(task);
    }

    await _saveToDisk();
    
    // Update UI
    notifyListeners();
    
  }


  Future<void> toggleTaskStatus(int taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    
    if(index != -1) {
      final oldTask = _tasks[index];

      //Creates a copy of a task only changing the field "isCompleted"
      final newTask = Task(
        id: oldTask.id,
        animalId: oldTask.animalId,
        title: oldTask.title,
        time: oldTask.time,
        taskType: oldTask.taskType,
        isCompleted: !oldTask.isCompleted,
      );

      _tasks[index] = newTask;
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();

    //Transform a tasks list in Json Text bc the phone can't read objects???? 
    final String encodedList = jsonEncode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('saved_tasks', encodedList);
  }
}