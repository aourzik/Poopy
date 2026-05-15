class Stool {
  final String? id;
  final String userId;
  final int bristol;
  final int count;
  final bool blood;
  final bool urgency;
  final DateTime? date;

  Stool({
    this.id,
    required this.userId,
    required this.bristol,
    required this.count,
    required this.blood,
    required this.urgency,
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "userId": userId,
      "bristol": bristol,
      "count": count,
      "blood": blood,
      "urgency": urgency,
    };
  }

  factory Stool.fromJson(Map<String, dynamic> json) {
    return Stool(
      id: json['id'],
      userId: json['userId'],
      bristol: json['bristol'],
      count: json['count'],
      blood: json['blood'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      urgency: json['urgency'] ?? false,
    );
  }
}