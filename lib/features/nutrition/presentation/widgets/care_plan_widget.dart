import 'package:flutter/material.dart';

import '../../data/models/care_task_model.dart';
import 'task_tile_widget.dart';

class CarePlanWidget extends StatefulWidget {
  const CarePlanWidget({super.key});

  @override
  State<CarePlanWidget> createState() => _CarePlanWidgetState();
}

class _CarePlanWidgetState extends State<CarePlanWidget> {

  final List<CareTaskModel> tasks = [

    CareTaskModel(title: "DRINK 3L WATER"),
    CareTaskModel(title: "MORNING WALK 20 MINS"),
    CareTaskModel(title: "TAKE MULTIVITAMINS"),
    CareTaskModel(title: "8 HOURS SLEEP"),
  ];

  void toggleTask(int index) {

    setState(() {
      tasks[index].isCompleted =
      !tasks[index].isCompleted;
    });
  }

  int get completedTasks =>
      tasks.where((e) => e.isCompleted).length;

  double get progress =>
      completedTasks / tasks.length;

  @override
  Widget build(BuildContext context) {

    final remaining =
        tasks.length - completedTasks;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),

      child: Column(
        children: [

          Row(
            children: [

              Container(
                height: 42,
                width: 42,

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                  BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.assignment_outlined,
                  color: Color(0xff14532D),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Care Plan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              RichText(
                text: TextSpan(
                  children: [

                    TextSpan(
                      text: "$completedTasks",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),

                    TextSpan(
                      text: "/${tasks.length}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ...List.generate(
            tasks.length,
                (index) => TaskTileWidget(
              task: tasks[index],
              onTap: () => toggleTask(index),
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor:
              Colors.grey.shade200,
              color: const Color(0xff14532D),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "$remaining TASKS REMAINING",

            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}