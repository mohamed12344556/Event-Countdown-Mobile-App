class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
    );
  }
}