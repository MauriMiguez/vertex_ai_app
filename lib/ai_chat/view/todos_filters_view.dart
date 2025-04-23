import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vertex_ai_app/l10n/l10n.dart';
import 'package:vertex_ai_app/todos/todos.dart';

class TodosFiltersView extends StatelessWidget {
  const TodosFiltersView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final filters = context.select((TodosBloc bloc) => bloc.state.filters);

    return Column(
      children: [
        Row(
          children: [
            Text(l10n.todosFilterAll),
            const Spacer(),
            Radio(
              value: TodoStatus.all,
              groupValue: filters.todoStatus,
              onChanged: (value) {
                context.read<TodosBloc>().add(
                  TodosFilterChanged(
                    filters.copyWith(todoStatus: () => TodoStatus.all),
                  ),
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(l10n.todosFilterActiveOnly),
            const Spacer(),
            Radio(
              value: TodoStatus.activeOnly,
              groupValue: filters.todoStatus,
              onChanged: (value) {
                context.read<TodosBloc>().add(
                  TodosFilterChanged(
                    filters.copyWith(todoStatus: () => TodoStatus.activeOnly),
                  ),
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(l10n.todosFilterCompletedOnly),
            const Spacer(),
            Radio(
              value: TodoStatus.completedOnly,
              groupValue: filters.todoStatus,
              onChanged: (value) {
                context.read<TodosBloc>().add(
                  TodosFilterChanged(
                    filters.copyWith(
                      todoStatus: () => TodoStatus.completedOnly,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _DateFilterField(
          selectedDate: filters.from,
          label: 'From date',
          onChanged:
              (date) => context.read<TodosBloc>().add(
                TodosFilterChanged(filters.copyWith(from: () => date)),
              ),
        ),
        _DateFilterField(
          selectedDate: filters.to,
          label: 'To date',
          onChanged:
              (date) => context.read<TodosBloc>().add(
                TodosFilterChanged(filters.copyWith(to: () => date)),
              ),
        ),
      ],
    );
  }
}

class _DateFilterField extends StatefulWidget {
  const _DateFilterField({
    required this.selectedDate,
    required this.onChanged,
    required this.label,
  });

  final DateTime? selectedDate;
  final void Function(DateTime?) onChanged;
  final String label;

  @override
  State<_DateFilterField> createState() => _DateFilterFieldState();
}

class _DateFilterFieldState extends State<_DateFilterField> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text:
          widget.selectedDate != null
              ? DateFormat.yMMMd().format(widget.selectedDate!)
              : null,
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DateFilterField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _textEditingController.text =
        widget.selectedDate != null
            ? DateFormat.yMMMd().format(widget.selectedDate!)
            : '';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textEditingController,
      decoration: InputDecoration(labelText: widget.label),
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () async {
        final date = await _selectDate(context, widget.selectedDate);
        if (date != null) {
          widget.onChanged(date);
        }
      },
    );
  }

  Future<DateTime?> _selectDate(
    BuildContext context,
    DateTime? selectedDate,
  ) async {
    final newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );

    return newSelectedDate;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
