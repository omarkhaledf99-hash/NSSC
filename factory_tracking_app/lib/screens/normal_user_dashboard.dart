import 'package:flutter/material.dart';
import 'checkpoints_list_screen.dart';
import 'stop_card_screen.dart';

class NormalUserDashboard extends StatelessWidget {
  const NormalUserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Choose an option!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkpoints Button
            _buildOptionCard(
              context: context,
              title: 'Checkpoints',
              imagePath: 'assets/images/checkpoints_illustration.svg',
              backgroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckPointsListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Stop Card Button
            _buildOptionCard(
              context: context,
              title: 'Stop Card',
              imagePath: 'assets/images/stop_card_illustration.svg',
              backgroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StopCardScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for illustration - will be replaced with actual SVG
            Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                color: title == 'Checkpoints' ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                title == 'Checkpoints' ? Icons.location_on : Icons.report_problem,
                size: 60,
                color: title == 'Checkpoints' ? Colors.green[600] : Colors.red[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}