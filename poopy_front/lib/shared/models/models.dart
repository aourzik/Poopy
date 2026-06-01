import 'dart:convert';

enum MedColor { coral, amber, green, blue, purple }

// ─── User ─────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? diagnosis;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.diagnosis,
    this.avatarUrl,
    required this.createdAt,
  });

  String get firstName => name.split(' ').first;
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'A';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Utilisateur Anonyme',
      email: json['email']?.toString() ?? '',
      diagnosis: json['diagnosis'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'diagnosis': diagnosis,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}

// ─── Stool Entry ──────────────────────────────────────────────────────────────

class StoolEntry {
  final String id;
  final DateTime date;
  final int bristol;
  final bool blood;
  final bool urgency;
  final int count;
  final String? notes;

  const StoolEntry({
    required this.id,
    required this.date,
    required this.bristol,
    required this.blood,
    required this.urgency,
    required this.count,
    this.notes,
  });

  StoolEntryStatus get status {
    if (blood) return StoolEntryStatus.blood;
    if (bristol >= 5 || urgency) return StoolEntryStatus.alert;
    if (bristol == 3 || bristol == 4) return StoolEntryStatus.ok;
    return StoolEntryStatus.watch;
  }

  factory StoolEntry.fromJson(Map<String, dynamic> json) {
    return StoolEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      bristol: json['bristol'] as int,
      blood: json['blood'] as bool,
      urgency: json['urgency'] as bool,
      count: json['count'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'bristol': bristol,
        'blood': blood,
        'urgency': urgency,
        'count': count,
        'notes': notes,
      };

  StoolEntry copyWith({
    int? bristol,
    bool? blood,
    bool? urgency,
    int? count,
    String? notes,
  }) {
    return StoolEntry(
      id: id,
      date: date,
      bristol: bristol ?? this.bristol,
      blood: blood ?? this.blood,
      urgency: urgency ?? this.urgency,
      count: count ?? this.count,
      notes: notes ?? this.notes,
    );
  }
}

enum StoolEntryStatus { ok, watch, alert, blood }

// ─── Medication ───────────────────────────────────────────────────────────────

class Medication {
  final String? id;
  final String name;
  final String dose;
  final String frequency;
  final int? totalToday;
  final int takenToday;
  final bool isInjection;
  final MedColor color;

  Medication({
    this.id,
    required this.name,
    required this.dose,
    required this.frequency,
    this.totalToday,
    this.takenToday = 0,
    required this.isInjection,
    required this.color,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final List logs = json['logs'] ?? [];
    return Medication(
      id: json['id'],
      name: json['name'] ?? '',
      dose: json['dose'] ?? '',
      frequency: json['frequency'] ?? '',
      totalToday: json['totalToday'],
      takenToday: logs.length,
      isInjection: json['isInjection'] ?? false,
      color: _parseColor(json['color']),
    );
  }

  Map<String, dynamic> toJson(String userId) => {
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'totalToday': totalToday,
        'isInjection': isInjection,
        'color': color.name,
        'userId': userId,
      };

  static MedColor _parseColor(String? colorName) {
    return MedColor.values.firstWhere(
      (e) => e.name == colorName,
      orElse: () => MedColor.amber,
    );
  }
}

// ─── Appointment ──────────────────────────────────────────────────────────────

class Appointment {
  final String id;
  final DateTime date;
  final String doctor;
  final String location;
  final String type;
  final String? notes;
  final String? preparation;

  const Appointment({
    required this.id,
    required this.date,
    required this.doctor,
    required this.location,
    required this.type,
    this.notes,
    this.preparation,
  });

  int get daysFromNow => date.difference(DateTime.now()).inDays;
  bool get isUpcoming => date.isAfter(DateTime.now());

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      doctor: json['doctor'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      notes: json['notes'] as String?,
      preparation: json['preparation'] as String?,
    );
  }

  Map<String, dynamic> toJson(String userId) => {
        'date': date.toIso8601String(),
        'doctor': doctor,
        'location': location,
        'type': type,
        'notes': notes ?? "",
        'preparation': preparation ?? "",
        'userId': userId,
      };
}

// ─── Medical Lab ──────────────────────────────────────────────────────────────

enum LabType { blood, calprotectin }

class MedicalLab {
  final String id;
  final DateTime date;
  final LabType type;
  final double? calprotectin;
  final double? crp;
  final double? b12;
  final double? b9;
  final double? ferritin;
  final double? iron;
  final String? notes;
  final String userId;

  const MedicalLab({
    required this.id,
    required this.date,
    required this.type,
    this.calprotectin,
    this.crp,
    this.b12,
    this.b9,
    this.ferritin,
    this.iron,
    this.notes,
    required this.userId,
  });

  factory MedicalLab.fromJson(Map<String, dynamic> json) {
    return MedicalLab(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: LabType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'blood'),
        orElse: () => LabType.blood,
      ),
      calprotectin: json['calprotectin'] != null
          ? (json['calprotectin'] as num).toDouble()
          : null,
      crp: json['crp'] != null ? (json['crp'] as num).toDouble() : null,
      b12: json['b12'] != null ? (json['b12'] as num).toDouble() : null,
      b9: json['b9'] != null ? (json['b9'] as num).toDouble() : null,
      ferritin: json['ferritin'] != null
          ? (json['ferritin'] as num).toDouble()
          : null,
      iron: json['iron'] != null ? (json['iron'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'type': type.name,
        'calprotectin': calprotectin,
        'crp': crp,
        'b12': b12,
        'b9': b9,
        'ferritin': ferritin,
        'iron': iron,
        'notes': notes,
        'date': date.toIso8601String(),
      };
}

// ─── Weight Model ─────────────────────────────────────────────────────────────

class Weight {
  final String? id;
  final String userId;
  final double value;
  final DateTime date;

  Weight({
    this.id,
    required this.userId,
    required this.value,
    required this.date,
  });

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      id: json['id']?.toString(),
      userId: json['userId'] ?? json['user_id'] ?? '',
      value: (json['value'] is int)
          ? (json['value'] as int).toDouble()
          : (json['value'] as double? ?? 0.0),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}

// ─── Friend Request ───────────────────────────────────────────────────────────

class FriendRequest {
  final String id;
  final String senderId;
  final String senderName;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? '',
    );
  }
}
