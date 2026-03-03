import 'package:offline_app/model/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalTaskRemoteRepository {
  String tablename = "tasks";
  Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dpPath = await getDatabasesPath();
    final path = join(dpPath, "tasks.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE $tablename(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        discription TEXT NOT NULL,
        uid TEXT NOT NULL,
        dueAt TEXT NOT NULL,
        hexColor TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL
        )
       ''');
      },
    );
  }

  Future<void> insertTask(TaskModel tasks) async {
    final db = await database;
    await db.delete(tablename, where: 'id = ?', whereArgs: [tasks.id]);
    await db.insert(tablename, tasks.toMap());
  }

  Future<void> insertTasks(List<TaskModel> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (var task in tasks) {
      batch.insert(tablename, task.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<TaskModel>> getTask() async {
    final db = await database;
    final result = await db.query(
      tablename,
    );
    if (result.isNotEmpty) {
      List<TaskModel> taskModelList = [];
      for (final element in result) {
        taskModelList.add(TaskModel.fromMap(element));
      }
      return taskModelList;
    }
    return [];
  }

  Future<List<TaskModel>> getUnSyncedTasks() async {
    final db = await database;
    final result =
        await db.query(tablename, where: 'isSynced = ?', whereArgs: [0]);
    if (result.isNotEmpty) {
      List<TaskModel> taskModelList = [];
      for (final element in result) {
        taskModelList.add(TaskModel.fromMap(element));
      }
      return taskModelList;
    }
    return [];
  }

  Future<void> updatedSynced(String id, int newValue) async {
    final db = await database;
    await db.update(tablename, {'isSynced': newValue},
        where: 'id = ?', whereArgs: [id]);
  }
}
