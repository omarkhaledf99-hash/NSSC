import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';

class CheckPointsListScreen extends StatefulWidget {
  const CheckPointsListScreen({super.key});

  @override
  State<CheckPointsListScreen> createState() => _CheckPointsListScreenState();
}

class _CheckPointsListScreenState extends State<CheckPointsListScreen> {
  final List<CheckPointItem> checkPoints = [
    CheckPointItem(id: 1, name: 'Entry Gate', isCompleted: false),
    CheckPointItem(id: 2, name: 'Production Line A', isCompleted: false),
    CheckPointItem(id: 3, name: 'Quality Control', isCompleted: false),
    CheckPointItem(id: 4, name: 'Packaging Area', isCompleted: false),
    CheckPointItem(id: 5, name: 'Exit Gate', isCompleted: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Checkpoints',
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
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: checkPoints.length,
                itemBuilder: (context, index) {
                  final checkPoint = checkPoints[index];
                  return _buildCheckPointCard(checkPoint, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckPointCard(CheckPointItem checkPoint, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: checkPoint.isCompleted ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            checkPoint.isCompleted ? Icons.check_circle : Icons.location_on,
            color: checkPoint.isCompleted ? Colors.green[600] : Colors.orange[600],
            size: 30,
          ),
        ),
        title: Text(
          checkPoint.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          checkPoint.isCompleted ? 'Completed' : 'Pending',
          style: TextStyle(
            fontSize: 14,
            color: checkPoint.isCompleted ? Colors.green[600] : Colors.orange[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: !checkPoint.isCompleted
            ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerScreen(
                        checkPointId: checkPoint.id,
                        checkPointName: checkPoint.name,
                        onScanComplete: (success) {
                          if (success) {
                            setState(() {
                              checkPoints[index].isCompleted = true;
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Scan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 30,
              ),
      ),
    );
  }
}

class CheckPointItem {
  final int id;
  final String name;
  bool isCompleted;

  CheckPointItem({
    required this.id,
    required this.name,
    required this.isCompleted,
  });
}