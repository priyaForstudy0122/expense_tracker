import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _service = FirestoreService();
  StreamSubscription? _sub;

  List<Expense> _all = [];
  bool loading = true;
  String? error;

  String? categoryFilter;
  String query = '';
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  ExpenseProvider() {
    listen();
  }

  void listen() {
    loading = true;
    error = null;
    notifyListeners();
    _sub?.cancel();
    _sub = _service.stream().listen((data) {
      _all = data;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
    });
  }

  List<Expense> get _monthItems => _all
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  List<Expense> get filtered => _monthItems
      .where((e) =>
          (categoryFilter == null || e.category == categoryFilter) &&
          e.title.toLowerCase().contains(query.toLowerCase()))
      .toList();

  double get monthTotal => _monthItems.fold(0.0, (s, e) => s + e.amount);
  int get monthCount => _monthItems.length;

  Map<String, double> get categoryTotals {
    final m = <String, double>{};
    for (final e in _monthItems) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  void changeMonth(int delta) {
    month = DateTime(month.year, month.month + delta);
    notifyListeners();
  }

  void setCategory(String? c) {
    categoryFilter = c;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  Future<void> add(Expense e) => _service.add(e);
  Future<void> update(Expense e) => _service.update(e);
  Future<void> delete(String id) => _service.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
