import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/current_user.dart'; // Classe para obter o usuário atual
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  static const routeName = '/tasks';

  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = false; // Simplesmente carregando os dados do provedor
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = CurrentUser.name ?? "Usuário"; // Nome do usuário logado
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage('assets/images/user.png'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Olá, $userName!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              // Exibir notificações
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Notificações",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    content: Text(
                      "Nenhuma notificação pendente.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "OK",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = provider.tasks;

                // Filtrar tarefas por data
                final todayTasks = tasks
                    .where((task) =>
                        task.date?.toLocal().day == _selectedDate.day &&
                        task.date?.toLocal().month == _selectedDate.month &&
                        task.date?.toLocal().year == _selectedDate.year)
                    .toList();
                final upcomingTasks = tasks
                    .where((task) =>
                        task.date?.isAfter(_selectedDate) ?? false)
                    .toList();

                return Column(
                  children: [
                    // Calendário de datas
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Theme.of(context).cardColor
                            : const Color(0xFFEEF7F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          7,
                          (index) {
                            final date = _selectedDate.add(Duration(days: index - 3));
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                });
                              },
                              child: Column(
                                children: [
                                  Text(
                                    ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                                        [date.weekday % 7],
                                    style: TextStyle(
                                      color: date.day == _selectedDate.day
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  CircleAvatar(
                                    backgroundColor: date.day == _selectedDate.day
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    radius: 15,
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: date.day == _selectedDate.day
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Tarefas de Hoje
                    if (todayTasks.isNotEmpty)
                      _buildTaskCategory(
                        title: "Hoje",
                        tasks: todayTasks,
                        provider: provider,
                        isDarkMode: isDarkMode,
                      ),
                    // Próximas tarefas
                    if (upcomingTasks.isNotEmpty)
                      _buildTaskCategory(
                        title: "Próximas",
                        tasks: upcomingTasks,
                        provider: provider,
                        isDarkMode: isDarkMode,
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddEditTaskScreen.routeName);
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa ou Compromisso'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        onTap: (index) {
          if (index == 0) {
            // Ação para botão de lista
          } else if (index == 2) {
            Navigator.pushNamed(context, SettingsScreen.routeName);
          }
        },
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCategory({
    required String title,
    required List<Task> tasks,
    required TaskProvider provider,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      task.isEvent ? Icons.event : Icons.task,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.description ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.isCompleted ? 'Concluído' : 'Pendente',
                          style: TextStyle(
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        provider.updateTask(
                          Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            date: task.date,
                            isCompleted: value ?? false,
                            isEvent: task.isEvent,
                          ),
                        );
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AddEditTaskScreen.routeName,
                        arguments: task,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
