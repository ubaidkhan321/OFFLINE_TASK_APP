import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as htpp;
import 'package:offline_app/core/constants/global.url.dart';
import 'package:offline_app/core/constants/utils.dart';
import 'package:offline_app/future/home/repository/local_task_remote_repository.dart';
import 'package:offline_app/model/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final String createTaskUrl = Globals.CREATE_TASK;
  final String syncTaskUrl = Globals.SYNCS_TASK;
  final String getTaskUrl = Globals.GET_TASK;
  final localtaskRepo = LocalTaskRemoteRepository();
  Future<TaskModel> createTask({
    required String title,
    required String discription,
    required String hexColor,
    required DateTime dueAt,
    required String uid,
    required String token,
  }) async {
    try {
      final response = await htpp.post(Uri.parse(createTaskUrl),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
          body: jsonEncode({
            'title': title,
            'discription': discription,
            'hexColor': hexColor,
            'dueAt': dueAt.toIso8601String(),
          }));
      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['error'];
      }
      return TaskModel.fromJson(response.body);
    } catch (e) {
      try {
        if (kDebugMode) {
          print(e.toString());
        }
        final task = TaskModel(
            id: const Uuid().v4(),
            uid: uid,
            title: title,
            discription: discription,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            dueAt: dueAt,
            color: hexTorgb(hexColor),
            isSynced: 0);
        await localtaskRepo.insertTask(task);
        return task;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTasks({required String tokan}) async {
    try {
      final response = await htpp
          .get(Uri.parse(getTaskUrl), headers: {"x-auth-token": tokan});
      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['error'];
      }
      final taskList = jsonDecode(response.body);
      List<TaskModel> listofTask = [];
      for (var elem in taskList) {
        listofTask.add(TaskModel.fromMap(elem));
      }

      await localtaskRepo.insertTasks(listofTask);
      return listofTask;
    } catch (e) {
      final task = await localtaskRepo.getTask();
      return task;
    }
  }

  Future<bool> syncTask({
    required List<TaskModel> task,
    required String token,
  }) async {
    try {
      final taskListIntoMap = [];
      for (final tasks in task) {
        taskListIntoMap.add(tasks.toMap());
      }
      final response = await htpp.post(Uri.parse(syncTaskUrl),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
          body: jsonEncode(taskListIntoMap));
      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['error'];
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
