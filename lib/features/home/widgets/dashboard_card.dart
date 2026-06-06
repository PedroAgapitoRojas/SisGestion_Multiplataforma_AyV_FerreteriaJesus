import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DashboardCard extends StatelessWidget {

  final String title;

  final String value;

  final IconData icon;

  const DashboardCard({

    super.key,

    required this.title,

    required this.value,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Text(

                title,

                style: const TextStyle(

                  color: AppColors.gray,

                  fontSize: 15,
                ),
              ),

              Icon(
                icon,
                color: AppColors.skyBlue,
              ),
            ],
          ),

          const Spacer(),

          Text(

            value,

            style: const TextStyle(

              color: AppColors.navy,

              fontSize: 30,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}