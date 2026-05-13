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
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      diagnosis: json['diagnosis'] as String?,
      diagnosisDate: json['diagnosisDate'] != null
          ? DateTime.parse(json['diagnosisDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
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
    'bristol': bristol, 'blood': blood,
    'urgency': urgency, 'count': count, 'notes': notes,
  };

  StoolEntry copyWith({
    int? bristol, bool? blood, bool? urgency, int? count, String? notes,
  }) {
    return StoolEntry(
      id: id, date: date,
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
  final String id;
  final String name;
  final String dose;
  final String frequency;
  final String nextDose;
  final int takenToday;
  final int? totalToday; // null = "as needed"
  final bool isInjection;
  final MedColor color;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.frequency,
    required this.nextDose,
    required this.takenToday,
    this.totalToday,
    this.isInjection = false,
    required this.color,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dose: json['dose'] as String,
      frequency: json['frequency'] as String,
      nextDose: json['nextDose'] as String,
      takenToday: json['takenToday'] as int,
      totalToday: json['totalToday'] as int?,
      isInjection: json['isInjection'] as bool? ?? false,
      color: MedColor.values.firstWhere(
        (e) => e.name == json['color'],
        orElse: () => MedColor.amber,
      ),
    );
  }
}

enum MedColor { coral, amber, green, blue, purple }

// ─── Appointment ──────────────────────────────────────────────────────────────

class Appointment {
  final String id;
  final DateTime date;
  final String time;
  final String doctor;
  final String location;
  final String type;
  final bool isUpcoming;

  const Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.doctor,
    required this.location,
    required this.type,
    required this.isUpcoming,
  });

  int get daysFromNow => date.difference(DateTime.now()).inDays;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      doctor: json['doctor'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      isUpcoming: json['isUpcoming'] as bool,
    );
  }
}

// ─── Analysis / Lab result ────────────────────────────────────────────────────

class LabResult {
  final String id;
  final String name;
  final DateTime date;
  final String lab;
  final String tag;
  final bool isNormal;
  final LabResultType type;

  const LabResult({
    required this.id,
    required this.name,
    required this.date,
    required this.lab,
    required this.tag,
    required this.isNormal,
    required this.type,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      lab: json['lab'] as String,
      tag: json['tag'] as String,
      isNormal: json['isNormal'] as bool,
      type: LabResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LabResultType.blood,
      ),
    );
  }
}

enum LabResultType { blood, calprotectin }
