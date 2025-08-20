class MedicalNote {
  final int? id;
  final int? measurementId;
  final String noteType;
  final String? title;
  final String content;

  MedicalNote({
    this.id,
    this.measurementId,
    this.noteType = 'general',
    this.title,
    required this.content,
  });

  factory MedicalNote.fromMap(Map<String, dynamic> map) {
    return MedicalNote(
      id: map['id'],
      measurementId: map['measurement_id'],
      noteType: map['note_type'] ?? 'general',
      title: map['title'],
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'measurement_id': measurementId,
      'note_type': noteType,
      'title': title,
      'content': content,
    };
  }
}
