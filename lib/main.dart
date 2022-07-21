import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildQrView(context),
        Center(
          child: CustomPaint(
            painter: BorderPainter(),
            child: const SizedBox(
              width: 200,
              height: 200,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 8,
              borderLength: 0,
              borderWidth: 0,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

}
class BorderPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final frameHWidth = size.width * .1;
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;


    /// top left
    ///
    canvas.drawLine(
      const Offset(0, 0),
      Offset(
        0 + frameHWidth,
        0,
      ),
      paint..color = Colors.white,
    );

    canvas.drawLine(
      const Offset(0, 0),
      Offset(
        0,
        0 + frameHWidth,
      ),
      paint..color = Colors.white,
    );

    /// top Right
    canvas.drawLine(
      Offset(size.width - 0, 0),
      Offset(size.width - 0 - frameHWidth, 0),
      paint..color = Colors.white,
    );
    canvas.drawLine(
      Offset(size.width - 0, 0),
      Offset(size.width - 0, 0 + frameHWidth),
      paint..color = Colors.white,
    );

    /// Bottom Right
    canvas.drawLine(
      Offset(size.width - 0, size.height - 0),
      Offset(size.width - 0 - frameHWidth, size.height - 0),
      paint..color = Colors.white,
    );
    canvas.drawLine(
      Offset(size.width - 0, size.height - 0),
      Offset(size.width - 0, size.height - 0 - frameHWidth),
      paint..color = Colors.white,
    );

    /// Bottom Left
    canvas.drawLine(
      Offset(0 + 0, size.height - 0),
      Offset(0 + 0 + frameHWidth, size.height - 0),
      paint..color = Colors.white,
    );
    canvas.drawLine(
      Offset(0 + 0, size.height - 0),
      Offset(0 + 0, size.height - 0 - frameHWidth),
      paint..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;


}
