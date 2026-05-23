class CareTaskEntity {
  final String title;
  bool isCompleted;

  CareTaskEntity({
    required this.title,
    this.isCompleted = false,
  });
}