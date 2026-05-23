import 'package:flutter/material.dart';
import '../../domain/entities/care_task_entity.dart';

class TaskTileWidget extends StatelessWidget {
  final CareTaskEntity task;
  final VoidCallback onTap;

  const TaskTileWidget({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),

        child: Row(
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 28,
              width: 28,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted
                    ? const Color(0xff14532D)
                    : Colors.transparent,

                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xff14532D)
                      : Colors.grey.shade400,
                ),
              ),

              child: task.isCompleted
                  ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                task.title,

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,

                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,

                  color: task.isCompleted
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}