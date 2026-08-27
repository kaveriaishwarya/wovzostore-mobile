import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final int status;
  final String statusName;

  const OrderStatusBadge({
    super.key,
    required this.status,
    required this.statusName,
  });

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 7:
        return Colors.indigo;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.deepPurple;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.green;
      case 10:
        return Colors.red;
      case 20:
      case 21:
      case 22:
      case 30:
      case 31:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusName.isEmpty ? 'Status $status' : statusName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
