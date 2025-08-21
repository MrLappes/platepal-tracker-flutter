import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/product.dart';
import '../../services/open_food_facts_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(Product)? onProductFound;
  final VoidCallback? onCancel;

  const BarcodeScannerScreen({super.key, this.onProductFound, this.onCancel});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();

  bool _isSearching = false;
  String? _lastScannedBarcode;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
        _controller.stop();
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty || _isSearching) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code == _lastScannedBarcode) return;

    _lastScannedBarcode = code;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔍 Barcode scanned: $code');

      final product = await _openFoodFactsService.getProductByBarcode(code);
      if (product != null && product.isValid) {
        debugPrint('✅ Product found: ${product.name}');

        // Stop the camera before closing
        _controller.stop();

        if (mounted) {
          // Close the scanner screen and call the callback
          Navigator.of(context).pop();
          widget.onProductFound?.call(product);
        }
      } else {
        debugPrint('❌ Product not found for barcode: $code');
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context).productNotFound;
          });

          // Clear error after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _errorMessage = null;
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error searching for product: $e');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(
            context,
          ).errorScanningBarcode(e.toString());
        });

        // Clear error after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        // Reset last scanned barcode after a delay to allow rescanning
        Future.delayed(const Duration(seconds: 2), () {
          _lastScannedBarcode = null;
        });
      }
    }
  }

  void _toggleTorch() {
    _controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.barcodeScanner),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, child) {
                return Icon(
                  value.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner view
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Scanner Error: ${error.errorCode}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (error.errorCode ==
                        MobileScannerErrorCode.permissionDenied) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(localizations.openSettings),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Overlay with scanning instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.scanningBarcode,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_errorMessage != null) ...[
                    Icon(Icons.error, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      localizations.scanBarcodeToAddProduct,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Scanning area overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
