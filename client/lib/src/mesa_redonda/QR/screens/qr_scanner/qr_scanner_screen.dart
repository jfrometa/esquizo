// QR Scanner Screen

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/models/qr_code_data.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/QR/screens/table_menu_screen.dart';
import '../../../providers/provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? scanError;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Table QR Code'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Scanner
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && isScanning) {
                      setState(() {
                        isScanning = false;
                      });
                      
                      final String code = barcodes.first.rawValue ?? '';
                      _processQRCode(code);
                    }
                  },
                ),
                
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Point camera at table QR code',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Error message if any
                if (scanError != null)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          scanError!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Bottom panel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Having trouble?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset scanner
                      setState(() {
                        isScanning = true;
                        scanError = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQRCode(String data) {
    try {
      final qrData = QRCodeData.fromQRString(data);
      
      if (qrData == null) {
        setState(() {
          scanError = 'Invalid QR code format';
          isScanning = true;
        });
        return;
      }
      
      // Find the table in our database
      final tablesAsync = ref.read(tablesProvider);
      
      tablesAsync.whenData((tables) {
        final table = tables.firstWhere(
          (t) => t.id == qrData.tableId,
          orElse: () => throw Exception('Table not found'),
        );
        
        // Set the selected table
        ref.read(selectedTableProvider.notifier).state = table;
        
        // Navigate to the menu screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TableMenuScreen(
              tableData: qrData,
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        scanError = 'Error processing QR code: ${e.toString()}';
        isScanning = true;
      });
    }
  }
}
