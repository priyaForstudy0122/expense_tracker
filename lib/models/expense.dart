import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kCategories = [
  'Food', 'Travel', 'Bills', 'Shopping', 'Health', 'Entertainment', 'Other'
];

class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  factory Expense.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Expense(
      id: doc.id,
      title: d['title'] ?? '',
      amount: (d['amount'] as num).toDouble(),
      category: d['category'] ?? 'Other',
      date: (d['date'] as Timestamp).toDate(),
      note: d['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'category': category,
        'date': Timestamp.fromDate(date),
        'note': note,
      };
}
