import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'checkpoint_status_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final int checkPointId;
  final String checkPointName;
  final Function(bool) onScanComplete;

  const QRScannerScreen({
    super.key,
    required this.checkPointId,
    required this.checkPointName,
    required this.onScanComplete,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = false;
  bool _hasPermission = false;
  String _scanResult = '';
  int _currentStep = 1;
  final int _totalSteps = 10;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  void _simulateQRScan() {
    setState(() {
      _isScanning = true;
    });

    // Simulate QR scanning process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
        _scanResult = 'QR_${widget.checkPointId}_${DateTime.now().millisecondsSinceEpoch}';
      });
      _navigateToStatusScreen();
    });
  }

  void _navigateToStatusScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckPointStatusScreen(
          checkPointId: widget.checkPointId,
          checkPointName: widget.checkPointName,
          qrCode: _scanResult,
          onStatusComplete: widget.onScanComplete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan the ${_getOrdinalNumber(_currentStep)} QR code point',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= _totalSteps; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _currentStep ? Colors.orange : Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
          // Camera view area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  children: [
                    // Camera preview placeholder
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[900],
                      child: _hasPermission
                          ? const Center(
                              child: Text(
                                'Camera Preview\n(QR Scanner will be here)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Camera permission required',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                    // Scanning overlay
                    if (_isScanning)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    // QR code frame overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            // Corner brackets
                            ...[
                              Alignment.topLeft,
                              Alignment.topRight,
                              Alignment.bottomLeft,
                              Alignment.bottomRight,
                            ].map((alignment) => Align(
                              alignment: alignment,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                                        ? const BorderSide(color: Colors.orange, width: 4)
                                        : BorderSide.none,
                                    bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                                        ? const BorderSide(color: Colors.orange, width: 4)
                                        : BorderSide.none,
                                    left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                                        ? const BorderSide(color: Colors.orange, width: 4)
                                        : BorderSide.none,
                                    right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                                        ? const BorderSide(color: Colors.orange, width: 4)
                                        : BorderSide.none,
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Instructions and scan button
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Position the QR code within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                if (_hasPermission)
                  ElevatedButton(
                    onPressed: _isScanning ? null : _simulateQRScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      _isScanning ? 'Scanning...' : 'Scan QR Code',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _requestCameraPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'Grant Camera Permission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOrdinalNumber(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}