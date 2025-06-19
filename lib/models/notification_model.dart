import 'dart:convert';

// Fungsi helper untuk mengubah JSON string menjadi List<AppNotification>
List<AppNotification> appNotificationFromJson(String str) => List<AppNotification>.from(json.decode(str).map((x) => AppNotification.fromJson(x)));

// Kita beri nama AppNotification untuk menghindari konflik dengan class Notification bawaan Flutter
class AppNotification {
    final int id;
    final String title;
    final String message;
    final bool isRead;
    final DateTime createdAt;

    AppNotification({
        required this.id,
        required this.title,
        required this.message,
        required this.isRead,
        required this.createdAt,
    });

    factory AppNotification.fromJson(Map<String, dynamic> json) {
        return AppNotification(
            id: json["id"],
            title: json["title"] ?? 'Tanpa Judul',
            message: json["message"] ?? 'Tidak ada pesan.',
            // Di database, boolean seringkali disimpan sebagai 0 atau 1
            isRead: json["is_read"] == 1 || json["is_read"] == true,
            // Parsing tanggal dari format string ISO 8601
            createdAt: DateTime.parse(json["created_at"]),
        );
    }
}
