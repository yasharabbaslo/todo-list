import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/source/source.dart';

class HiveTaskDataSource implements DataSource<TaskData> {
  final Box<TaskData> _box;

  HiveTaskDataSource(this._box);
  @override
  Future<TaskData> createOrUpdate(data) async {
    if (data.isInBox) {
      data.save();
    } else {
      data.id = await _box.add(data);
    }
    return data;
  }

  @override
  Future<void> delete(data) async {
    return data.delete();
  }

  @override
  Future<void> deleteAll() {
    return _box.clear();
  }

  @override
  Future<void> deleteById(id) {
    return _box.delete(id);
  }

  @override
  Future<TaskData> findById(id) async {
    return _box.values.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<TaskData>> getAll({String searchKeyword = ''}) async {
    return _box.values
        .where((task) => task.title.contains(searchKeyword))
        .toList();
  }
}
