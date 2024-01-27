class Review {
  String id;
  String username;
  String location;
  double rating;
  String comment;
  DateTime date;
  String imagePath;

  Review({
    required this.id,
    required this.username,
    required this.location,
    required this.rating,
    required this.comment,
    required this.date,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'location': location,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}