import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class TaxInvoiceDto extends Equatable {
  final String orderId;
  final String orderNumber;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String contentType;
  final Uint8List fileBytes;
  final String htmlContent;

  const TaxInvoiceDto({
    required this.orderId,
    required this.orderNumber,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.contentType,
    required this.fileBytes,
    required this.htmlContent,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        invoiceNumber,
        invoiceDate,
        contentType,
        fileBytes,
        htmlContent,
      ];
}
