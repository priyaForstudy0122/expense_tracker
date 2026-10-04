import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_style.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Expense? expense;
  const AddEditScreen({super.key, this.expense});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _category;
  late DateTime _date;
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(
        text: e == null
            ? ''
            : (e.amount % 1 == 0
                ? e.amount.toStringAsFixed(0)
                : e.amount.toString()));
    _note = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? kCategories.first;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? prefix, Widget? suffix}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? cs.surfaceContainerHigh : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<ExpenseProvider>();
    final expense = Expense(
      id: widget.expense?.id,
      title: _title.text.trim(),
      amount: double.parse(_amount.text.trim()),
      category: _category,
      date: _date,
      note: _note.text.trim(),
    );
    try {
      _isEdit ? await p.update(expense) : await p.add(expense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec('Title'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                    decoration: _dec('Amount', prefix: '₹ '),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      if (n == null) return 'Enter a valid number';
                      if (n <= 0) return 'Amount must be greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Category',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kCategories.map((c) {
                      final s = CategoryStyle.of(c);
                      final selected = _category == c;
                      return ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(s.icon,
                            size: 18,
                            color: selected ? Colors.white : s.color),
                        label: Text(c),
                        selected: selected,
                        selectedColor: s.color,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : null),
                        onSelected: (_) => setState(() => _category = c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _dec('Date',
                          suffix: const Icon(Icons.calendar_today)),
                      child: Text(DateFormat('dd MMM yyyy').format(_date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _note,
                    maxLines: 3,
                    decoration: _dec('Note (optional)'),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5))
                          : Text(_isEdit ? 'Update expense' : 'Save expense',
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
