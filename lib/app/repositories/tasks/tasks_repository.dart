import 'package:todo_list_provider/app/models/task_model.dart';

abstract class TasksRepository {
  Future<void> save(DateTime date, String description, String uid);
  Future<List<TaskModel>> findByPeriod(DateTime start, DateTime end, String uid);
  Future<void> checkOrUncheckTask(TaskModel task);
}
