import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_style.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import 'add_edit_screen.dart';

final _fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddEditScreen())),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(p: p)),
              ..._content(context, p),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, ExpenseProvider p) {
    if (p.loading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (p.error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 52, color: Colors.red),
                const SizedBox(height: 10),
                const Text('Something went wrong',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(p.error!,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: p.listen,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final items = p.filtered;
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text('No expenses found',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Tap "Add expense" to create one',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => _ExpenseCard(e: items[i], p: p),
      ),
    ];
  }
}

// ---------------------------------------------------------------- Header

class _Header extends StatelessWidget {
  final ExpenseProvider p;
  const _Header({required this.p});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? cs.surfaceContainerHigh : Colors.white;

    final totals = p.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => p.changeMonth(-1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(DateFormat('MMMM yyyy').format(p.month),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => p.changeMonth(1)),
            ],
          ),
          const SizedBox(height: 14),

          // Gradient total card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, cs.tertiary],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total this month',
                    style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.85),
                        fontSize: 14)),
                const SizedBox(height: 6),
                Text(_fmt.format(p.monthTotal),
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                    '${p.monthCount} ${p.monthCount == 1 ? 'expense' : 'expenses'}',
                    style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.85))),
              ],
            ),
          ),

          // Category breakdown (simple bar chart)
          if (totals.isNotEmpty && p.monthTotal > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('By category',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...totals.map((t) {
                    final s = CategoryStyle.of(t.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(s.icon, size: 18, color: s.color),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 92,
                              child: Text(t.key,
                                  overflow: TextOverflow.ellipsis)),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: t.value / p.monthTotal,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(8),
                              color: s.color,
                              backgroundColor:
                                  s.color.withValues(alpha: 0.15),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(_fmt.format(t.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Search
          TextField(
            onChanged: p.setQuery,
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(context, 'All', null, p.categoryFilter == null,
                    () => p.setCategory(null)),
                ...kCategories.map((c) => _chip(context, c,
                    CategoryStyle.of(c), p.categoryFilter == c,
                    () => p.setCategory(c))),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, CategoryStyle? style,
      bool selected, VoidCallback onTap) {
    final color = style?.color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: style == null
            ? null
            : Icon(style.icon,
                size: 18, color: selected ? Colors.white : style.color),
        label: Text(label),
        selected: selected,
        selectedColor: color,
        labelStyle: TextStyle(color: selected ? Colors.white : null),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

// ---------------------------------------------------------- Expense card

class _ExpenseCard extends StatelessWidget {
  final Expense e;
  final ExpenseProvider p;
  const _ExpenseCard({required this.e, required this.p});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = CategoryStyle.of(e.category);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Dismissible(
        key: ValueKey(e.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          await _confirmDelete(context, p, e);
          return false; // list refreshes from Firestore stream
        },
        child: Material(
          color: isDark ? cs.surfaceContainerHigh : Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddEditScreen(expense: e))),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: style.color.withValues(alpha: 0.15),
                    child: Icon(style.icon, color: style.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                            '${e.category} • ${DateFormat('dd MMM yyyy').format(e.date)}',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 12.5)),
                        if (e.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(e.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_fmt.format(e.amount),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, p, e),
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

Future<void> _confirmDelete(
    BuildContext context, ExpenseProvider p, Expense e) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete expense?'),
      content: Text('"${e.title}" will be removed.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete')),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await p.delete(e.id!);
  } catch (err) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $err')));
    }
  }
}
