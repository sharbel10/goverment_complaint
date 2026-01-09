import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserComplaintsHeader extends StatelessWidget {
  final VoidCallback onBack;
  const UserComplaintsHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'my_complaints'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
