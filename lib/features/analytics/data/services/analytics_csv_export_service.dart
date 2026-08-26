import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class AnalyticsCsvExportService {
  Future<String> saveCsvFile({
    required Uint8List bytes,
    required String fileName,
  });

  Future<void> shareCsvFile({
    required String filePath,
    required String title,
  });

  String formatCleanDate(String dateYmd);
  String generateSalesFileName(String start, String end);
  String generateProductFileName(String start, String end);
  String generateCategoryFileName(String start, String end);
  String generateBrandFileName(String start, String end);
  String generateCustomerFileName(String start, String end);
  String generateInventoryFileName();
}

class AnalyticsCsvExportServiceImpl implements AnalyticsCsvExportService {
  @override
  Future<String> saveCsvFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> shareCsvFile({
    required String filePath,
    required String title,
  }) async {
    final xFile = XFile(filePath, mimeType: 'text/csv');
    await Share.shareXFiles(
      [xFile],
      text: title,
      subject: title,
    );
  }

  @override
  String formatCleanDate(String dateYmd) {
    return dateYmd.replaceAll('-', '');
  }

  @override
  String generateSalesFileName(String start, String end) {
    return 'sales_report_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';
  }

  @override
  String generateProductFileName(String start, String end) {
    return 'product_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';
  }

  @override
  String generateCategoryFileName(String start, String end) {
    return 'category_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';
  }

  @override
  String generateBrandFileName(String start, String end) {
    return 'brand_performance_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';
  }

  @override
  String generateCustomerFileName(String start, String end) {
    return 'customer_analytics_${formatCleanDate(start)}_${formatCleanDate(end)}.csv';
  }

  @override
  String generateInventoryFileName() {
    final now = DateTime.now();
    final ymd = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'inventory_report_$ymd.csv';
  }
}
