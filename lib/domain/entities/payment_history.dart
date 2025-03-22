class PaymentHistory {
  final int id;
  final int packageId;
  final String packageName;
  final double price;
  final String currency;
  final String paymentMethod;
  final String status;
  final String createdAt;

  PaymentHistory({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      packageId: json['package_id'],
      packageName: json['package_name'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}