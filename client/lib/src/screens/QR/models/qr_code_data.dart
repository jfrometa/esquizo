// QR Code data model
import 'dart:convert';

class QRCodeData {
  final String tableId;
  final String tableName;
  final String restaurantId;
  final DateTime generatedAt;

  QRCodeData({
    required this.tableId,
    required this.tableName,
    required this.restaurantId,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'tableName': tableName,
      'restaurantId': restaurantId,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      tableId: json['tableId'],
      tableName: json['tableName'],
      restaurantId: json['restaurantId'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  String toQRString() {
    return jsonEncode(toJson());
  }

  static QRCodeData? fromQRString(String qrString) {
    try {
      final Map<String, dynamic> json = jsonDecode(qrString);
      return QRCodeData.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
