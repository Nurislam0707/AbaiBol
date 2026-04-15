enum ReviewTargetKind { teacher, subject, building, studentLife, club }

extension ReviewTargetKindX on ReviewTargetKind {
  String get value {
    switch (this) {
      case ReviewTargetKind.teacher:
        return 'teacher';
      case ReviewTargetKind.subject:
        return 'subject';
      case ReviewTargetKind.building:
        return 'building';
      case ReviewTargetKind.studentLife:
        return 'studentLife';
      case ReviewTargetKind.club:
        return 'club';
    }
  }

  String get label {
    switch (this) {
      case ReviewTargetKind.teacher:
        return 'Teacher';
      case ReviewTargetKind.subject:
        return 'Subject';
      case ReviewTargetKind.building:
        return 'Building';
      case ReviewTargetKind.studentLife:
        return 'Student Life';
      case ReviewTargetKind.club:
        return 'Club';
    }
  }

  static ReviewTargetKind fromValue(String value) {
    return switch (value) {
      'teacher' => ReviewTargetKind.teacher,
      'subject' => ReviewTargetKind.subject,
      'building' => ReviewTargetKind.building,
      'studentLife' => ReviewTargetKind.studentLife,
      'club' => ReviewTargetKind.club,
      _ => throw ArgumentError.value(value, 'value', 'Unknown review target'),
    };
  }
}
