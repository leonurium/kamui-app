class MainResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;

  MainResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
  });

  factory MainResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return MainResponse(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (message != null) data['message'] = message;
    if (error != null) data['error'] = error;
    if (this.data != null && toJsonT != null) {
      data['data'] = toJsonT(this.data as T);
    }
    return data;
  }
}