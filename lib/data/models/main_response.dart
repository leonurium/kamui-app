class MainResponse<T> {
  final bool success;
  final String message;
  final T? data;

  MainResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MainResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return MainResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null && toJsonT != null) {
      data['data'] = toJsonT(this.data as T);
    }
    return data;
  }
}