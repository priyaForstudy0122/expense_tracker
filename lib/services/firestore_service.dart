import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final _col = FirebaseFirestore.instance.collection('expenses');

  Stream<List<Expense>> stream() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Expense.fromDoc).toList());

  Future<void> add(Expense e) => _col.add(e.toMap());
  Future<void> update(Expense e) => _col.doc(e.id).update(e.toMap());
  Future<void> delete(String id) => _col.doc(id).delete();
}
