part of 'task_cubic.dart';

sealed class TaskState {
  const TaskState();
}

final class TaskInitalState extends TaskState {}

final class TaskLoadingState extends TaskState {}

final class TaskErrorState extends TaskState {
  final String error;
  TaskErrorState(this.error);
}

final class AddTaskSuccessState extends TaskState {
  final TaskModel taskModel;
  const AddTaskSuccessState(this.taskModel);
}

final class GetTaskSuccess extends TaskState {
  final List<TaskModel> getTask;
  const GetTaskSuccess(this.getTask);
}
