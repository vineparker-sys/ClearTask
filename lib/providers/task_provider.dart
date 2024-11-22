import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider extends ChangeNotifier {
  final DatabaseHelper dbHelper;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  TaskProvider({
    required this.dbHelper,
    required this.localNotificationsPlugin,
  });

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  /// Busca todas as tarefas do banco de dados
  Future<void> getTasks() async {
    final data = await dbHelper.getTasks();
    _tasks = data;
    notifyListeners();
  }

  /// Busca tarefas por data
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final tasksByDate = await dbHelper.getTasksByDate(date);
    return tasksByDate;
  }

  /// Adiciona uma nova tarefa e cria notificações
  Future<void> addTask(Task task) async {
    await dbHelper.insertTask(task);
    await _scheduleTaskNotification(task); // Agendar notificação
    await getTasks();
  }

  /// Atualiza uma tarefa existente e reconfigura notificações
  Future<void> updateTask(Task task) async {
    await dbHelper.updateTask(task);
    await _cancelTaskNotification(task.id!); // Cancela a notificação anterior
    await _scheduleTaskNotification(task); // Agenda a nova notificação
    await getTasks();
  }

  /// Deleta uma tarefa pelo ID e cancela suas notificações
  Future<void> deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    await _cancelTaskNotification(id); // Cancela a notificação associada
    await getTasks();
  }

  /// Filtra tarefas concluídas
  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  /// Filtra tarefas pendentes
  List<Task> getPendingTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  /// Filtra tarefas por eventos
  List<Task> getEventTasks() {
    return _tasks.where((task) => task.isEvent).toList();
  }

  /// Filtra tarefas não-eventos
  List<Task> getNonEventTasks() {
    return _tasks.where((task) => !task.isEvent).toList();
  }

  /// Agendar notificação para uma tarefa
  Future<void> _scheduleTaskNotification(Task task) async {
    if (task.date == null || task.title == null) {
      // Evita processar notificações se a data ou título da tarefa for nulo
      print('Erro: A tarefa não possui data ou título válido.');
      return;
    }

    final notificationId = task.id ?? DateTime.now().millisecondsSinceEpoch;
    final notificationTime = tz.TZDateTime.from(task.date!, tz.local)
        .subtract(const Duration(minutes: 30));

    if (notificationTime.isBefore(DateTime.now())) {
      // Evita agendar notificações para o passado
      print('Erro: Tentativa de agendar uma notificação no passado.');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_notifications',
      'Task Notifications',
      channelDescription: 'Notificações para lembrar de tarefas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await localNotificationsPlugin.zonedSchedule(
        notificationId,
        'Lembrete de Tarefa',
        'Tarefa "${task.title}" está agendada para ${task.date!.hour}:${task.date!.minute}',
        notificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notificação agendada com sucesso para a tarefa: ${task.title}');
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }

  /// Cancela uma notificação pelo ID
  Future<void> _cancelTaskNotification(int id) async {
    try {
      await localNotificationsPlugin.cancel(id);
      print('Notificação cancelada com sucesso para o ID: $id');
    } catch (e) {
      print('Erro ao cancelar notificação: $e');
    }
  }
}
