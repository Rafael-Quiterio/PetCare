import 'package:animalapp/models/tasks_model.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeminiProvider with ChangeNotifier {
  GenerativeModel? _model;
  ChatSession? _chat;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Message list for UI
  List<({String sender, String message})> messages = [];
  
  // Local Data
  List<dynamic> _animals = [];
  List<Task> _tasks = [];

  void updateAnimals(List<dynamic> animals) {
    _animals = animals;
  }

  void updateTasks(List<Task> tasks) {
    _tasks = tasks;
  }


  String _buildDynamicContext() {
    String data = "";

    // Add Animals
    if (_animals.isNotEmpty) {
      final animalsText = _animals.map((a) {
        return '- ${a.name} (${a.specie}, ${a.breed}, ${a.weight}, ${a.notes} , Age: ${a.age})';
      }).join('\n');
      data += "\n\n[CURRENT ANIMAL DATA]:\n$animalsText";
    } else {
      data += "\n\n[CURRENT DATA]: The user has no registered animals.";
    }

    // Add Tasks
    if (_tasks.isNotEmpty) {
      final tasksText = _tasks.map((t) {
        final status = t.isCompleted ? "Done" : "Pending";
        return '- ${t.title} at ${t.time.toString()} (Status: $status)';
      }).join('\n');
      data += "\n\n[SCHEDULED TASKS]:\n$tasksText";
    }

    return data;
  }

  Future<void> connectToGemini() async {
    if (_isInitialized) return; // Prevents reconnecting if already ready

    try {
      // Load MD file. It's where the prompt is
      final basePrompt = await rootBundle.loadString('assets/animal_context.md');
      
      // Generate dynamic data
      final dynamicData = _buildDynamicContext();

      // Create Full System Instruction
      final fullSystemInstruction = "$basePrompt\n$dynamicData\n\nIMPORTANT: Use this data to answer.";

      // Configure Model
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash', 
        generationConfig: GenerationConfig(
          temperature: 0.9,
          maxOutputTokens: 700,
        ),
        systemInstruction: Content.text(fullSystemInstruction),
      );
      
      // Where the chat starts
      _chat = _model!.startChat();
      _isInitialized = true;
      notifyListeners();
      
      await _sendAutoGreeting();

    } catch (e) {
      print('Fatal error in Gemini: $e');
      messages.add((sender: 'ai', message: "Error connecting. Check internet."));
      notifyListeners();
    }
  }

  // Private function to force Gemini to speak first before I even say anything. it will collect the data from animals and tasks and use it in the beggining
  Future<void> _sendAutoGreeting() async {
    try {
      String hiddenPrompt = "The user has entered the chat. ";
      
      if (_animals.isNotEmpty) {
        final names = _animals.map((a) => a.name).join(', ');
        hiddenPrompt += "Welcome them and mention their pets ($names) by name. Ask if they need care tips.";
      } else {
        hiddenPrompt += "Welcome them and ask if they want help registering the first pet.";
      }

      print(">> Sending invisible prompt: $hiddenPrompt");

      // Send directly to API 
      final response = await _chat!.sendMessage(Content.text(hiddenPrompt));
      final reply = response.text;

      if (reply != null) {
        // Add ONLY the AI response to the visual list
        messages.add((sender: 'ai', message: reply));
        notifyListeners();
      }
    } catch (e) {
      print("Error in auto greeting: $e");
    }
  }

  Future<void> sendMessage(String text) async {
    if (_chat == null) return;

    // Add User message to UI
    messages.add((sender: 'user', message: text));
    notifyListeners();

    try {
      // Send to Gemini 
      final response = await _chat!.sendMessage(Content.text(text));
      final reply = response.text ?? 'No response.';
      
      // Add AI response to UI
      messages.add((sender: 'ai', message: reply));
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      messages.add((sender: 'ai', message: 'Connection error. Try again.'));
      notifyListeners();
    }
  }
}