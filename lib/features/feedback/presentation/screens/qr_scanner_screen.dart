import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../shared/widgets/glass_header.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      // Expected: nuris://reviews/building/UUID
      if (value.startsWith('nuris://reviews/')) {
        final path = value.replaceFirst('nuris://', '/');
        setState(() => _scanned = true);
        Future.microtask(() {
          if (mounted) context.push(path);
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          // Gradient top
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Header
          GlassAppBar(
            title: strings.scanQr,
            canPop: true,
          ),

          // Scan frame
          Center(
            child: SizedBox(
              width: 260, height: 260,
              child: Stack(
                children: [
                  // Outer border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                  // Blue corner — top-left
                  Positioned(top: 0, left: 0, child: _ScanCorner(flipX: false, flipY: false)),
                  // top-right
                  Positioned(top: 0, right: 0, child: _ScanCorner(flipX: true, flipY: false)),
                  // bottom-left
                  Positioned(bottom: 0, left: 0, child: _ScanCorner(flipX: false, flipY: true)),
                  // bottom-right
                  Positioned(bottom: 0, right: 0, child: _ScanCorner(flipX: true, flipY: true)),

                  if (_scanned)
                    const Center(
                      child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                    ),
                ],
              ),
            ),
          ),

          // Bottom info
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(context).padding.bottom + 28,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    strings.scanQrInstruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.autoRedirectNotice,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.flipX, required this.flipY});
  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipX ? -1 : 1,
      scaleY: flipY ? -1 : 1,
      child: SizedBox(
        width: 32, height: 32,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width * 0.3, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
