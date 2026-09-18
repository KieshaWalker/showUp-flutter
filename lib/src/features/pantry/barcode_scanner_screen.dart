// barcode_scanner_screen.dart — Full-screen camera view for scanning a food
// barcode (UPC/EAN) to prefill the pantry add-food form.
//
// Pops with the scanned barcode string, or null if the user backs out.
// Includes a manual-entry fallback for damaged barcodes or the simulator,
// where there's no camera to scan with.
//
// Every exit path — a successful scan, manual entry, AND backing out via the
// AppBar back button or the system back gesture — is routed through _exit(),
// which stops the camera before popping. mobile_scanner's AVCaptureSession
// teardown on iOS/macOS isn't guaranteed to finish by the time dispose() runs
// during a pop transition, which otherwise leaves the OS's camera-in-use
// indicator lit after this screen closes. The back-button/system-back path
// is caught with PopScope(canPop: false): that blocks Navigator.maybePop()
// (what the back button and system gestures call) but NOT an explicit
// Navigator.pop() call, so _exit() can still pop for real once it's done
// stopping the camera — see the official PopScope async-confirmation pattern
// this mirrors (examples/api/lib/widgets/pop_scope/pop_scope.0.dart in the
// Flutter SDK).
//
// Connections:
//   pantry_screen.dart           — pushes this screen, then looks up the
//                                  result via open_food_facts_service.dart
//   open_food_facts_service.dart — resolves the scanned barcode to nutrition

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stops the camera session, then pops with [code] (or no result, for a
  /// plain back-out). See the file-level comment for why every exit path
  /// funnels through here instead of popping directly.
  Future<void> _exit([String? code]) async {
    if (_handled) return;
    _handled = true;
    await _controller.stop();
    if (mounted) Navigator.pop(context, code);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _exit(code);
  }

  void _enterManually() {
    final ctrl = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter barcode'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 0123456789012'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Look Up'),
          ),
        ],
      ),
    ).then((code) {
      if (code != null && code.isNotEmpty && mounted) {
        _exit(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Scan Barcode'),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard),
              tooltip: 'Enter manually',
              onPressed: _enterManually,
            ),
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, child) => Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                ),
              ),
              tooltip: 'Toggle flashlight',
              onPressed: () => _controller.toggleTorch(),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.terracotta, width: 3),
                    borderRadius: AppRadius.lgAll,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Text(
                'Align the barcode within the frame',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
