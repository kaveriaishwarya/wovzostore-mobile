class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, List<String>>? errors;

  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.errors,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? parsedErrors;

    if (json['errors'] is Map<String, dynamic>) {
      parsedErrors = {};
      final rawErrors = json['errors'] as Map<String, dynamic>;
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors![key] = value.map((e) => e.toString()).toList();
        } else if (value != null) {
          parsedErrors![key] = [value.toString()];
        }
      });
    }

    return ProblemDetails(
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? ''),
      detail: json['detail']?.toString(),
      instance: json['instance']?.toString(),
      errors: parsedErrors,
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (title != null) 'title': title,
        if (status != null) 'status': status,
        if (detail != null) 'detail': detail,
        if (instance != null) 'instance': instance,
        if (errors != null) 'errors': errors,
      };

  /// User-friendly summary message extracted from detail, title, or first validation error.
  String get displayMessage {
    if (detail != null && detail!.isNotEmpty) {
      return detail!;
    }
    if (errors != null && errors!.isNotEmpty) {
      final firstKey = errors!.keys.first;
      final firstList = errors![firstKey];
      if (firstList != null && firstList.isNotEmpty) {
        return firstList.first;
      }
    }
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return 'An unexpected server error occurred.';
  }

  @override
  String toString() => 'ProblemDetails(status: $status, title: $title, detail: $detail)';
}
