import '../../domain/entities/care_task_entity.dart';

class CareTaskModel extends CareTaskEntity {
  CareTaskModel({
    required super.title,
    super.isCompleted,
  });
}