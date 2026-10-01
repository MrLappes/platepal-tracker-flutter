import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/product.dart';
import '../../services/open_food_facts_service.dart';
import 'product_search_screen.dart';

enum BarcodeNotFoundAction { searchByName, enterManually, scanAgain }

/// Asks what to do after [barcode] was not found; null if dismissed.
Future<BarcodeNotFoundAction?> showBarcodeNotFoundSheet(
  BuildContext context,
  String barcode, {
  bool canEnterManually = true,
}) {
  return showModalBottomSheet<BarcodeNotFoundAction>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.componentsScannerBarcodeScannerProductNotFound,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.componentsScannerBarcodeScannerNotFoundMessage(barcode),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.componentsScannerBarcodeScannerSearchByName),
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(BarcodeNotFoundAction.searchByName),
              ),
              if (canEnterManually)
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: Text(
                    l10n.componentsScannerBarcodeScannerEnterManually,
                  ),
                  onTap:
                      () => Navigator.of(
                        context,
                      ).pop(BarcodeNotFoundAction.enterManually),
                ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(l10n.componentsScannerBarcodeScannerScanAgain),
                onTap:
                    () => Navigator.of(
                      context,
                    ).pop(BarcodeNotFoundAction.scanAgain),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class BarcodeScannerScreen extends StatefulWidget {
  final Function(Product)? onProductFound;
  final VoidCallback? onCancel;

  /// Opens manual entry for a barcode that is not in Open Food Facts.
  final void Function(String barcode)? onManualEntry;

  const BarcodeScannerScreen({
    super.key,
    this.onProductFound,
    this.onCancel,
    this.onManualEntry,
  });

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
      final product = await _openFoodFactsService.getProductByBarcode(code);
      if (!mounted) return;
      if (product != null && product.isValid) {
        // Stop the camera before closing
        _controller.stop();

        if (mounted) {
          // Close the scanner screen and call the callback
          Navigator.of(context).pop();
          widget.onProductFound?.call(product);
        }
      } else {
        debugPrint('Product not found for scanned barcode');
        if (mounted) {
          setState(() => _isSearching = false);
          await _handleNotFound(code);
        }
      }
    } catch (e) {
      debugPrint('❌ Error searching for product: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(
                context,
              ).componentsScannerBarcodeScannerServiceUnavailable;
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

  Future<void> _handleNotFound(String code) async {
    await _controller.stop();
    if (!mounted) return;
    final action = await showBarcodeNotFoundSheet(
      context,
      code,
      canEnterManually: widget.onManualEntry != null,
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    switch (action) {
      case BarcodeNotFoundAction.searchByName:
        navigator.pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => ProductSearchScreen(
                  onProductSelected: widget.onProductFound,
                  onCancel: widget.onCancel,
                ),
          ),
        );
      case BarcodeNotFoundAction.enterManually:
        navigator.pop();
        widget.onManualEntry?.call(code);
      case BarcodeNotFoundAction.scanAgain:
      case null:
        _lastScannedBarcode = null;
        await _controller.start();
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
        title: Text(
          localizations.componentsScannerBarcodeScannerBarcodeScanner,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              final isOn = value.torchState == TorchState.on;
              return IconButton(
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
                tooltip:
                    isOn
                        ? localizations.componentsScannerBarcodeScannerTorchOff
                        : localizations.componentsScannerBarcodeScannerTorchOn,
                onPressed: _toggleTorch,
              );
            },
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
                      localizations.componentsScannerBarcodeScannerScannerError(
                        error.errorCode.toString(),
                      ),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (error.errorCode ==
                        MobileScannerErrorCode.permissionDenied) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          localizations
                              .componentsScannerBarcodeScannerPermissionHint,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          localizations.componentsScannerBarcodeScannerClose,
                        ),
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
                      localizations
                          .componentsScannerBarcodeScannerScanningBarcode,
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
                      localizations
                          .componentsScannerBarcodeScannerScanBarcodeToAddProduct,
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
