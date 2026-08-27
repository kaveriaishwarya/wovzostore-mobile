import 'package:equatable/equatable.dart';

class OrderStatusTransitionRequestModel extends Equatable {
  final String? comment;
  final String? adminId;

  const OrderStatusTransitionRequestModel({
    this.comment,
    this.adminId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (comment != null) 'comment': comment,
      if (adminId != null) 'adminId': adminId,
    };
  }

  @override
  List<Object?> get props => [comment, adminId];
}

class CancelOrderRequestModel extends Equatable {
  final String reason;

  const CancelOrderRequestModel({
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [reason];
}
