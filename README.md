# **🐾 Pet Care Companion**

A Flutter application designed to help pet owners manage their animals, schedule daily care tasks with local notifications, and get personalized advice from an AI Assistant (Gemini).

## **Features**

### **Pet Management**

* **Create & Edit Profiles:** Add pets with photos, name, breed, weight, age and notes.  
* **Data Persistence:** All general pet data is saved on Firebase Firestore, besides Tasks that are saved locally using JSON Serialization and Shared Preferences.

### **Task System & Notifications**

* **Scheduled Tasks:** Create tasks for Walks, Food,  Health or any other type of task.  
*  **Multiple tasks** It's possible to create multiple tasks of the same topic for the same day 
* **Local Notifications:** Uses flutter '\_local\_notifications' to ring alarms even when the app is closed.  
* **Timezone Awareness:** Ensures alarms ring at the correct local time regardless of device settings.

### **Context-Aware AI Gemini Chatbot**

* **Gemini Integration:** Powered by Google's Gemini 2.5 Flash model.  
* **Smart Context:** The AI automatically "reads" the list of pets and tasks before a question is asked
* **Auto-Greeting:** The AI initiates the conversation knowing who the pets are.

## **Tech Stack**

* **Framework:** Flutter (Dart)  
* **State Management:** Provider (ChangeNotifier)  
* **Local Database:** Shared Preferences 
* **Cloud Database** Firebase Firestore 
* **Notifications:** Flutter Local Notifications \+ Flutter Timezone  
* **AI:** Firebase AI   
* **Image Handling:** Image Picker

## **Author**

Developed by Rafael Quitério  
Individual Project - December 2025
