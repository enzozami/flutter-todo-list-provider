import 'package:todo_list_provider/app/models/task_model.dart';
import 'package:todo_list_provider/app/models/week_task_model.dart';
import 'package:todo_list_provider/app/repositories/tasks/tasks_repository.dart';
import 'package:todo_list_provider/app/services/tasks/tasks_service.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class TasksServiceImpl implements TasksService {
  final TasksRepository _tasksRepository;
  final UserService _userService;

  TasksServiceImpl({
    required TasksRepository tasksRepository,
    required UserService userService,
  })  : _tasksRepository = tasksRepository,
        _userService = userService;

  @override
  Future<void> save(DateTime date, String description) async {
    final uid = _userService.uid;
    if (uid == null) throw Exception("Usuário não autenticado");

    await _tasksRepository.save(date, description, uid);
  }

  @override
  Future<List<TaskModel>> getToday() async {
    final uid = _userService.uid;
    if (uid == null) throw Exception("Usuário não autenticado");

    return await _tasksRepository.findByPeriod(DateTime.now(), DateTime.now(), uid);
  }

  @override
  Future<List<TaskModel>> getTomorrow() async {
    final uid = _userService.uid;
    if (uid == null) throw Exception("Usuário não autenticado");

    var tomorrowDate = DateTime.now().add(const Duration(days: 1));
    return await _tasksRepository.findByPeriod(tomorrowDate, tomorrowDate, uid);
  }

  @override
  Future<WeekTaskModel> getWeek() async {
    final uid = _userService.uid;
    if (uid == null) throw Exception("Usuário não autenticado");

    final today = DateTime.now();
    var startFilter = DateTime(today.year, today.month, today.day, 0, 0, 0);

    if (startFilter.weekday != DateTime.monday) {
      startFilter = startFilter.subtract(
        Duration(days: (startFilter.weekday - 1)),
      );
    }

    final endFilter = startFilter.add(const Duration(days: 7));

    final tasks = await _tasksRepository.findByPeriod(startFilter, endFilter, uid);
    return WeekTaskModel(
      startDate: startFilter,
      endDate: endFilter,
      tasks: tasks,
    );
  }

  @override
  Future<void> checkOrUncheckTask(TaskModel task) => _tasksRepository.checkOrUncheckTask(task);

  @override
  Future<void> delete(int id) async {
    final uid = _userService.uid;
    if (uid == null) throw Exception("Usuário não autenticado");

    await _tasksRepository.delete(id);
  }
}
