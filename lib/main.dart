import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/Services/notification_service.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/Views/MainMenu.dart';
import 'package:animalapp/UI/theme.dart';
import 'package:animalapp/providers/gemini_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//firebase
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initNotifcations();
  // inicializa o firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              AnimalStore(), //Provides the entire app with the animalStore change notifier
        ),
        ChangeNotifierProvider<GeminiProvider>(create: (_) => GeminiProvider()),
        ChangeNotifierProvider(create: (context) => TasksStore()..loadTasks()),
      ],

      child: MaterialApp(theme: primaryTheme, home: MainMenu()),
    ),
  );
}
