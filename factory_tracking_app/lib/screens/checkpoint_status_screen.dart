import 'package:flutter/material.dart';
import 'issue_report_screen.dart';

class CheckPointStatusScreen extends StatelessWidget {
  final int checkPointId;
  final String checkPointName;
  final String qrCode;
  final Function(bool) onStatusComplete;

  const CheckPointStatusScreen({
    super.key,
    required this.checkPointId,
    required this.checkPointName,
    required this.qrCode,
    required this.onStatusComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Point one is done!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success checkmark
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 80,
              ),
            ),
            const SizedBox(height: 40),
            // Status selection text
            const Text(
              'How is everything at this checkpoint?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            // Status buttons
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    context: context,
                    title: 'Good',
                    icon: Icons.thumb_up,
                    color: Colors.green,
                    onTap: () => _handleGoodStatus(context),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatusButton(
                    context: context,
                    title: 'Issue',
                    icon: Icons.report_problem,
                    color: Colors.red,
                    onTap: () => _handleIssueStatus(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleDone(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
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
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoodStatus(BuildContext context) {
    // Handle good status - could show a brief confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status marked as Good'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleIssueStatus(BuildContext context) {
    // Navigate to issue report screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IssueReportScreen(
          checkPointId: checkPointId,
          checkPointName: checkPointName,
          qrCode: qrCode,
        ),
      ),
    );
  }

  void _handleDone(BuildContext context) {
    // Mark checkpoint as complete and navigate back
    onStatusComplete(true);
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}