import 'package:flutter/cupertino.dart';
import 'package:todo_list/data/source/source.dart';

class Repository<T> extends ChangeNotifier implements DataSource<T> {
  final DataSource<T> _localDataSource;

  Repository(this._localDataSource);
  @override
  Future<T> createOrUpdate(data) async {
    final T _data = await _localDataSource.createOrUpdate(data);
    notifyListeners();
    return _data;
  }

  @override
  Future<void> delete(T data) async {
    _localDataSource.delete(data);
    notifyListeners();
  }

  @override
  Future<void> deleteAll() async {
    await _localDataSource.deleteAll();
    notifyListeners();
  }

  @override
  Future<void> deleteById(id) async {
    _localDataSource.deleteById(id);
    notifyListeners();
  }

  @override
  Future<T> findById(id) {
    return _localDataSource.findById(id);
  }

  @override
  Future<List<T>> getAll({String searchKeyword = ''}) {
    return _localDataSource.getAll(searchKeyword: searchKeyword);
  }
}
