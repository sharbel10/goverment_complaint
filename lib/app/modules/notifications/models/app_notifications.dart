class AppNotification {
  final String id; 
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final int createdAtMs;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAtMs,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    data: data,
    createdAtMs: createdAtMs,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'data': data,
    'createdAtMs': createdAtMs,
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    body: (json['body'] ?? '').toString(),
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    createdAtMs: (json['createdAtMs'] ?? 0) as int,
    isRead: (json['isRead'] ?? false) as bool,
  );
}
