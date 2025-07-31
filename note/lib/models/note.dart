class Note {
  int? id;  // Made nullable since it might not exist for new notes
  int date;
  String title;
  String content;

  // Constructor for new notes
  Note({
    this.id,
    required this.title,
    required this.content,
  }) : date = _generateDate();

  // Constructor from database map
  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        date = map['date'],
        title = map['title'] ?? '',  // Provide default if null
        content = map['content'] ?? '';  // Provide default if null

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'title': title,
      'content': content,
    };
  }

  // Helper method to generate date
  static int _generateDate() {
    final now = DateTime.now();
    return int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}',
    );
  }

  // Update date method
  void setDate() {
    date = _generateDate();
  }
}