import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'package:timezone/timezone.dart' as tz;

class AddEditTaskScreen extends StatefulWidget {
  static const routeName = '/add_edit_task';

  const AddEditTaskScreen({super.key});

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _selectedDate;
  bool _isEvent = false;
  List<String> _selectedCategories = [];

  Task? _editedTask;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final task = ModalRoute.of(context)!.settings.arguments as Task?;
    if (task != null && _editedTask == null) {
      _editedTask = task;
      _title = task.title;
      _description = task.description;
      _selectedDate = task.date;
      _isEvent = task.isEvent ?? false;
      _selectedCategories = task.categories ?? [];
    } else if (_editedTask == null) {
      _title = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          _editedTask == null ? 'Criar nova tarefa' : 'Editar tarefa',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: theme.iconTheme.color),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de título
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: theme.textTheme.bodyLarge,
                    hintText: 'Digite o título da tarefa',
                    hintStyle: theme.textTheme.bodyMedium,
                    suffixIcon: Icon(Icons.edit, color: theme.iconTheme.color),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de descrição
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: theme.textTheme.bodyLarge,
                    hintText: 'Insira a descrição da tarefa',
                    hintStyle: theme.textTheme.bodyMedium,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                const SizedBox(height: 20),

                // Data e hora
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Selecione a data e hora'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} às ${_selectedDate!.hour}:${_selectedDate!.minute}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Categorias
                Text(
                  'Categoria',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: ['Trabalho', 'Pessoal'].map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: _selectedCategories.contains(category),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: theme.cardColor,
                      selectedColor: theme.primaryColor,
                      labelStyle: theme.textTheme.bodyMedium,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Marcar como Evento
                Row(
                  children: [
                    Text(
                      'Marcar como evento?',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Checkbox(
                      value: _isEvent,
                      onChanged: (value) {
                        setState(() {
                          _isEvent = value!;
                        });
                      },
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Botões de ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Voltar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          if (_selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, selecione uma data'),
                              ),
                            );
                            return;
                          }

                          final newTask = Task(
                            id: _editedTask?.id,
                            title: _title,
                            description: _description,
                            date: _selectedDate,
                            isCompleted: _editedTask?.isCompleted ?? false,
                            isEvent: _isEvent,
                            categories: _selectedCategories,
                          );

                          if (_editedTask == null) {
                            await taskProvider.addTask(newTask);
                          } else {
                            await taskProvider.updateTask(newTask);
                          }

                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: const Text('Criar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }
}
