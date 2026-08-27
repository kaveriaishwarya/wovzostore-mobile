import 'package:flutter/material.dart';

class OrderStatusActionDialog extends StatefulWidget {
  final String title;
  final String inputLabel;
  final bool isCancellation;
  final Function(String input) onConfirm;

  const OrderStatusActionDialog({
    super.key,
    required this.title,
    this.inputLabel = 'Comment (Optional)',
    this.isCancellation = false,
    required this.onConfirm,
  });

  @override
  State<OrderStatusActionDialog> createState() => _OrderStatusActionDialogState();
}

class _OrderStatusActionDialogState extends State<OrderStatusActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.isCancellation && !_formKey.currentState!.validate()) return;
    widget.onConfirm(_controller.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.inputLabel,
            border: const OutlineInputBorder(),
          ),
          validator: widget.isCancellation
              ? (val) => val == null || val.trim().isEmpty ? 'Cancellation reason is required' : null
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
