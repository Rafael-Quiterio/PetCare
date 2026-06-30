# **🐾 Pet Care Companion**

A complete Flutter application designed to help pet owners manage their animals, schedule daily care tasks with local notifications, and get personalized advice from an AI Assistant (Gemini).

## **📱 Features**

### **🐶 Pet Management**

* **Create & Edit Profiles:** Add pets with photos (Gallery integration), name, breed, weight, age and notes.  
* **Data Persistence:** All general pet data is saved on Firebase Firestore, besides Tasks that are saved locally using JSON Serialization and Shared Preferences.

### **📅 Task System & Notifications**

* **Scheduled Tasks:** Create tasks for Walks, Food,  Health or any other type of task.  
*  **Multiple tasks** It's possible to create multiple tasks of th same topic for the same day
* **Smart Logic:** Automatically detects if a time has passed (e.g., 5:00 PM vs 5:00 AM) and schedules for the next day if necessary.  
* **Local Notifications:** Uses flutter '\_local\_notifications' to ring alarms even when the app is closed.  
* **Timezone Awareness:** Uses Java 8 Desugaring and the timezone package to ensure alarms ring at the correct local time regardless of device settings.

### **🤖 Context-Aware AI Gemini Chatbot**

* **Gemini Integration:** Powered by Google's Gemini 2.5 Flash model.  
* **Smart Context:** The AI automatically "reads" the list of pets and tasks before a question is asked
* **Auto-Greeting:** The AI initiates the conversation knowing who the pets are.
* **To Use** Needed AI Logic from firebase, which had the gemini API and it's integration in the project

## **🛠️ Tech Stack**

* **Framework:** Flutter (Dart)  
* **State Management:** Provider (ChangeNotifier)  
* **Local Database:** Shared Preferences 
* **Cloud Database** Firebase Firestore 
* **Notifications:** Flutter Local Notifications \+ Flutter Timezone  
* **AI:** Firebase AI   
* **Image Handling:** Image Picker


## **⚙️ Installation & Setup (Cross-Platform)**

This app is built with **Flutter**. To run it, the Flutter SDK needs to be installed.  
**Prerequisites:**

* Flutter SDK (3.0 or higher)  
* Android Studio / VS Code  
* Android Device or Emulator (API 34 recommended)

**Step-by-Step Instructions:**

1. Unzip the Source Code:  
   Extract the project folder to your desired location.  
2. Open VScode or Android Studio  
   Open the folder

3. Install Dependencies:  
   This downloads all cross-platform packages (Provider, AI, Notifications):  
   flutter pub get

4. Android Configuration:  
   This project uses flutter\_local\_notifications which requires Java 8 Desugaring.  
   Note: This is already configured in android/app/build.gradle.  
5. Run the App:  
   Connect your device and run:  
   flutter run


## **👤 Author**

Developed by Rafael Quitério  
Individual Project - December 2025