import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/UI/theme.dart';
import 'package:animalapp/Views/Create/Create_Task_Screen.dart';
import 'package:animalapp/models/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/UI/styled_text.dart';

//So I changed it to stateful bc of the bubbles bc it will have to change the UI depending on who I click.
//It was stateless before since it was just data being shown
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {

String? _tasksPetFilter;

  @override
  Widget build(BuildContext context) {
   final animalStore = Provider.of<AnimalStore>(context);
    final taskStore = Provider.of<TasksStore>(context);

    // Filter logic
    final allTasks = taskStore.tasks;
    final filteredTasks = _tasksPetFilter == null
        ? allTasks
        : allTasks.where((t) => t.animalId == _tasksPetFilter).toList();

    return Column(
      children: [
        // Headline
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StyledHeading('Daily Tasks'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTaskScreen(),
                    ),
                  );
                },
                child: const ButtonStyledHeading("+ Add Task"),
              ),
            ],
          ),
        ),



        // Filter bar
        // Only shows if there's any pet available
        if (animalStore.animals.isNotEmpty)
          Container(
            height: 90, 
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                // Global bubble
                _buildFilterBubble(
                  label: "All", 
                  isSelected: _tasksPetFilter == null,
                  onTap: () => setState(() => _tasksPetFilter = null),
                  icon: Icons.grid_view_rounded,
                ),
                
                // Bubbles
                ...animalStore.animals.map((animal) {
                  return _buildFilterBubble(
                    label: animal.name,
                    isSelected: _tasksPetFilter == animal.id,
                    onTap: () => setState(() => _tasksPetFilter= animal.id),
                    icon: Icons.pets, 
                  );
                }),
              ],
            ),
          ),

        // List of the tasks already filtrated
        Expanded(
          child: filteredTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        size: 60,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 15),
                      Text(
                       _tasksPetFilter == null 
                            ? 'No tasks scheduled yet.' 
                            : 'No tasks for this pet.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskItem(context, task, taskStore);
                  },
                ),
        ),
      ],
    );
  }

  // Widget for the bubbles
  Widget _buildFilterBubble({
    required String label, 
    required bool isSelected, 
    required VoidCallback onTap,
    IconData? icon
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: AppColors.primaryColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Icon(
                icon ?? Icons.pets, 
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTaskItem(BuildContext context, Task task, TasksStore store) {
    // Date Logic for today or tomorrow
    final now = DateTime.now();
    final isToday =
        task.time.year == now.year &&
        task.time.month == now.month &&
        task.time.day == now.day;

    final datePrefix = isToday ? "Today" : "Tomorrow";
    final timeString = DateFormat('HH:mm').format(task.time);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Dismissible(
          key: ValueKey(task.id),

          direction: DismissDirection.endToStart,

          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          onDismissed: (direction) {
            store.deleteTask(task.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${task.title} deleted"),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: "UNDO",
                  onPressed: () {
                    store.addTask(task);
                  },
                ),
              ),
            );
          },

          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
                child: Icon(
                  _getIconForType(task.taskType),
                  color: AppColors.primaryAccent,
                ),
              ),

              title: Text(
                task.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? AppColors.titleColor.withValues(alpha: 0.5)
                      : null,
                  fontSize: 16,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$datePrefix, $timeString",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: isToday ? AppColors.textColor : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              trailing: Checkbox(
                value: task.isCompleted,
                activeColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryAccent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (bool? value) {
                  store.toggleTaskStatus(task.id);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'food':
        return Icons.restaurant; // Osso ou Comida
      case 'activity':
        return Icons.directions_walk; // Passeio
      case 'health':
        return Icons.local_hospital; // Veterinário
      default:
        return Icons.notifications_active;
    }
  }
}
