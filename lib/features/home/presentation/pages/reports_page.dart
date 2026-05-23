import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:  Colors.green.shade50,
        elevation: 0,
        leadingWidth: 75,

        leading: const Padding(
          padding: EdgeInsets.only(left: 18,top: 5,bottom: 5),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/300',
            ),
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Hello Yoro!",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Good afternoon",
              style: TextStyle(
                color: Color(0xff5D8B74),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),

        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),

              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xff5D8B74),
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Health Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
