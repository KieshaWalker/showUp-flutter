// barcode_scanner_screen.dart — Full-screen camera view for scanning a food
// barcode (UPC/EAN) to prefill the pantry add-food form.
//
// Pops with the scanned barcode string, or null if the user backs out.
// Includes a manual-entry fallback for damaged barcodes or the simulator,
// where there's no camera to scan with.
//
// Every exit path — a successful scan, manual entry, AND backing out via the
// AppBar back button or the system back gesture — is routed through _exit(),
// which stops the camera before popping. The back-button/system-back path is
// caught with PopScope(canPop: false): that blocks Navigator.maybePop() (what
// the back button and system gestures call) but NOT an explicit
// Navigator.pop() call, so _exit() can still pop for real once it's done
// stopping the camera — see the official PopScope async-confirmation pattern
// this mirrors (examples/api/lib/widgets/pop_scope/pop_scope.0.dart in the
// Flutter SDK).
//
// Known mobile_scanner iOS bug (still reproduces on 7.4.2, confirmed on a
// real iPhone, on EVERY exit path including a clean detected-barcode
// success): MobileScannerController.stop() has several "already stopped,
// skip" guards (isRunning / _textureId == null) that can short-circuit
// before the native AVCaptureSession is actually released, leaving iOS's
// camera-in-use indicator lit until the app is force-quit. See
// https://github.com/juliansteenbakker/mobile_scanner/issues/619 for the
// same symptom reported against older versions. mobile_scanner's own code
// works around this for its debug/hot-restart case by calling the
// method-channel's stop(force: true) directly, bypassing those guards (see
// MobileScanner._initializeController's kDebugMode branch in
// mobile_scanner.dart) — _exit() below does the same thing for our
// navigate-away case, which isn't covered by that built-in workaround.
//
// Connections:
//   pantry_screen.dart           — pushes this screen, then looks up the
//                                  result via open_food_facts_service.dart
//   open_food_facts_service.dart — resolves the scanned barcode to nutrition

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// ignore: implementation_imports
import 'package:mobile_scanner/src/method_channel/mobile_scanner_method_channel.dart';
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
  /// funnels through here instead of popping directly, and why this force-
  /// stops the platform channel directly rather than trusting
  /// MobileScannerController.stop() alone.
  Future<void> _exit([String? code]) async {
    if (_handled) return;
    _handled = true;
    await _controller.stop();
    try {
      if (MobileScannerPlatform.instance
          case final MethodChannelMobileScanner impl) {
        await impl.stop(force: true);
      }
    } catch (_) {}
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
