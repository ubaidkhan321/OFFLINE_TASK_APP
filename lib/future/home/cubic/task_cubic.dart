import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_app/core/constants/utils.dart';
import 'package:offline_app/future/home/repository/local_task_remote_repository.dart';
import 'package:offline_app/future/home/repository/task_remote_repository.dart';
import 'package:offline_app/model/task_model.dart';
part 'task_state.dart';

class TaskCubic extends Cubit<TaskState> {
  TaskCubic() : super(TaskInitalState());
  final addRemoteTaskRepo = TaskRemoteRepository();
  final tasklocalRepo = LocalTaskRemoteRepository();

  Future<void> createTask({
    required String title,
    required String discription,
    required Color color,
    required DateTime dueAt,
    required String token,
    required String uid,
  }) async {
    try {
      emit(TaskLoadingState());
      final taskModel = await addRemoteTaskRepo.createTask(
        title: title,
        discription: discription,
        hexColor: rgbToHex(color),
        dueAt: dueAt,
        token: token,
        uid: uid,
      );
      await tasklocalRepo.insertTask(taskModel);
      emit(AddTaskSuccessState(taskModel));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> getTask({required String token}) async {
    emit(TaskLoadingState());
    final tasks = await addRemoteTaskRepo.getTasks(tokan: token);
    emit(GetTaskSuccess(tasks));
  }

  Future<void> synscTask(String token) async {
    final unsyncedTasks = await tasklocalRepo.getUnSyncedTasks();
    if (kDebugMode) {
      print("error $unsyncedTasks");
    }
    if (unsyncedTasks.isEmpty) {
      return;
    }
    final isSynced =
        await addRemoteTaskRepo.syncTask(task: unsyncedTasks, token: token);
    if (kDebugMode) {
      print("Async Done");
    }
    if (isSynced) {
      for (final task in unsyncedTasks) {
        tasklocalRepo.updatedSynced(task.id, 1);
      }
    }
  }
}
