import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DatePreset {
  today,
  last7Days,
  last30Days,
  monthToDate,
  yearToDate,
}

class DateRangeFilter extends StatefulWidget {
  final String startDate;
  final String endDate;
  final void Function(String startDate, String endDate) onDateRangeChanged;

  const DateRangeFilter({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  DatePreset? _selectedPreset;

  String _formatDisplay(String ymd) {
    try {
      final parts = ymd.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        return DateFormat('MMM dd, yyyy').format(dt);
      }
    } catch (_) {}
    return ymd;
  }

  String _toYmd(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _applyPreset(DatePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime start;
    DateTime end = today;

    switch (preset) {
      case DatePreset.today:
        start = today;
        break;
      case DatePreset.last7Days:
        start = today.subtract(const Duration(days: 6));
        break;
      case DatePreset.last30Days:
        start = today.subtract(const Duration(days: 29));
        break;
      case DatePreset.monthToDate:
        start = DateTime(today.year, today.month, 1);
        break;
      case DatePreset.yearToDate:
        start = DateTime(today.year, 1, 1);
        break;
    }

    setState(() {
      _selectedPreset = preset;
    });

    widget.onDateRangeChanged(_toYmd(start), _toYmd(end));
  }

  Future<void> _openCustomPicker() async {
    DateTime initialStart;
    DateTime initialEnd;

    try {
      final sp = widget.startDate.split('-');
      final ep = widget.endDate.split('-');
      initialStart = DateTime(int.parse(sp[0]), int.parse(sp[1]), int.parse(sp[2]));
      initialEnd = DateTime(int.parse(ep[0]), int.parse(ep[1]), int.parse(ep[2]));
    } catch (_) {
      initialStart = DateTime.now().subtract(const Duration(days: 29));
      initialEnd = DateTime.now();
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = null;
      });
      widget.onDateRangeChanged(_toYmd(picked.start), _toYmd(picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip('Today', DatePreset.today),
              const SizedBox(width: 8),
              _buildPresetChip('Last 7 Days', DatePreset.last7Days),
              const SizedBox(width: 8),
              _buildPresetChip('Last 30 Days', DatePreset.last30Days),
              const SizedBox(width: 8),
              _buildPresetChip('Month to Date', DatePreset.monthToDate),
              const SizedBox(width: 8),
              _buildPresetChip('Year to Date', DatePreset.yearToDate),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Active Date Range Button
        InkWell(
          onTap: _openCustomPicker,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  '${_formatDisplay(widget.startDate)} — ${_formatDisplay(widget.endDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, DatePreset preset) {
    final isSelected = _selectedPreset == preset;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
      ),
      onSelected: (_) => _applyPreset(preset),
    );
  }
}
