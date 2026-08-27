import 'package:flutter/material.dart';

class StaffRoleBadge extends StatelessWidget {
  final String role;
  final bool isCompact;

  const StaffRoleBadge({
    super.key,
    required this.role,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    String label;

    switch (role.toLowerCase()) {
      case 'superadmin':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        label = 'Super Admin';
        break;
      case 'admin':
        backgroundColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        label = 'Admin';
        break;
      case 'storemanager':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        label = 'Store Manager';
        break;
      case 'support':
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        label = 'Support';
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        label = role;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6.0 : 10.0,
        vertical: isCompact ? 2.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: isCompact ? 11.0 : 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
