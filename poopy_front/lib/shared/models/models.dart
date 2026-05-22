enum MedColor { coral, amber, green, blue, purple }

// ─── User ─────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? diagnosis;
  final DateTime? diagnosisDate;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.diagnosis,
    this.diagnosisDate,
    required this.createdAt,
  });

  String get firstName => name.split(' ').first;
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'A';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '', // Sécurité si l'ID est manquant
      name: json['name']?.toString() ?? 'Utilisateur Anonyme',
      email: json['email']?.toString() ?? '',
      diagnosis: json['diagnosis'] as String?,
      diagnosisDate: json['diagnosisDate'] != null
          ? DateTime.parse(json['diagnosisDate'] as String)
          : null,
      // Pour createdAt, Prisma renvoie souvent une String ISO8601, le parse est bon
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
        'diagnosisDate': diagnosisDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

// ─── Stool Entry ──────────────────────────────────────────────────────────────

class StoolEntry {
  final String id;
  final DateTime date;
  final int bristol; // 1-5
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
    // CORRECTION ICI : On utilise 'logs' avec un S
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

  // Calcul dynamique pour l'affichage
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

// ─── Medical Lab Types ────────────────────────────────────────────────────────

enum LabType { blood, calprotectin }

// ─── Medical Lab Model ────────────────────────────────────────────────────────

class MedicalLab {
  final String id;
  final DateTime date;
  final double? calprotectin;
  final double? crp;
  final String? notes;
  final String userId;
  final LabType type; // Ajout du type pour faciliter le filtrage

  const MedicalLab({
    required this.id,
    required this.date,
    this.calprotectin,
    this.crp,
    this.notes,
    required this.userId,
    required this.type,
  });

  factory MedicalLab.fromJson(Map<String, dynamic> json) {
    return MedicalLab(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      calprotectin: json['calprotectin'] != null ? (json['calprotectin'] as num).toDouble() : null,
      crp: json['crp'] != null ? (json['crp'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
      // Conversion automatique du type via le nom
      type: LabType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LabType.blood,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'calprotectin': calprotectin,
    'crp': crp,
    'notes': notes,
    'date': date.toIso8601String(),
    'type': type.name,
  };
}

// ─── Weight Model ────────────────────────────────────────────────────

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

  // Pour convertir les données de ta base Neon (JSON) en objet Flutter
  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      id: json['id']?.toString(),
      userId: json['user_id'] ?? '',
      value: (json['value'] is int)
          ? (json['value'] as int).toDouble()
          : (json['value'] as double? ?? 0.0),
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
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
