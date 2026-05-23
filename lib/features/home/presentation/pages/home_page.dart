import 'package:flutter/material.dart';
import 'package:classroom_app/features/home/presentation/widgets/today_diet_container.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onViewFullPlan;
  const HomePage({super.key, this.onViewFullPlan});

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [

            /// SEARCH BAR
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),

              child: Row(
                children: [

                  Container(
                    height: 32,
                    width: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xff5D8B74),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "What should I eat for dinner?",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xff5D8B74),
                    size: 18,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// OPTIMIZE HEALTH CONTAINER
            Container(
              height: 185,
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438",
                  ),
                  fit: BoxFit.cover,
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white24,
                            ),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.health_and_safety_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Row(
                                children: [

                                  const Expanded(
                                    child: Text(
                                      "Optimize Your Health",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),

                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                "Add details and lab reports to unlock wellness insights.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 40,

                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white24,
                              ),
                              borderRadius:
                              BorderRadius.circular(14),
                            ),

                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                SizedBox(width: 5),

                                Text(
                                  "Complete profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Container(
                            height: 40,

                            decoration: BoxDecoration(
                              color: const Color(0xff6BAF92),
                              borderRadius:
                              BorderRadius.circular(14),
                            ),

                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons.upload_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),

                                SizedBox(width: 5),

                                Text(
                                  "Upload report",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.bold ,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// CALORIES CONTAINER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: BoxBorder.all(color: Colors.grey.shade300)
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Calories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "DAILY TRACKING",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Column(
                      children: [

                        Text(
                          "0",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          "OF 3335",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// DETAILS CONTAINER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffFBF8F2),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        /// PROTEIN
                        Row(
                          children: [

                            Icon(
                              Icons.water_drop_outlined,
                              color: Colors.redAccent,
                              size: 16,
                            ),

                            SizedBox(width: 6),

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "18g",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                Text(
                                  "PROTEIN",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// CARBS
                        Row(
                          children: [

                            Icon(
                              Icons.favorite_border,
                              color: Colors.blue,
                              size: 16,
                            ),

                            SizedBox(width: 6),

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "68g",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                Text(
                                  "CARBS",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// FATS
                        Row(
                          children: [

                            Icon(
                              Icons.sentiment_satisfied_alt,
                              color: Colors.green,
                              size: 16,
                            ),

                            SizedBox(width: 6),

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "9g",
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                Text(
                                  "FATS",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Divider(height: 1),

                  const SizedBox(height: 10),

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      Text(
                        "Nutrient Info",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ),

                      Row(
                        children: [

                          Text(
                            "View Details",
                            style: TextStyle(
                              color: Color(0xff5D8B74),
                              fontWeight:
                              FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(width: 2),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Color(0xff5D8B74),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// TODAY'S DIET CONTAINER
            TodayDietContainer(
              onViewFullPlan: onViewFullPlan ?? () {},
            ),

            // Extra bottom padding for FAB clearance
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}