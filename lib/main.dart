import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:isolate_image_compress/isolate_image_compress.dart';

import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class ShowPdf extends StatefulWidget {
  const ShowPdf({super.key, required this.pdf});

  final Uint8List pdf;

  @override
  State<ShowPdf> createState() => _ShowPdfState();
}

class _ShowPdfState extends State<ShowPdf> {
  @override
  Widget build(BuildContext context) {
    print(widget.pdf);
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF FILE"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: SfPdfViewer.memory(widget.pdf),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _pictures = [];
  Uint8List? _pdfBytes;
  String pdfSize = '';
  List<Uint8List> imagesUint8list = [];

  List clickedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: clickedImages.isEmpty
          ? Center(
              child: ElevatedButton(
                  onPressed: onPressed, child: const Text("Add Pictures")),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              clickedImages.clear();
                              setState(() {});
                            },
                            child: Text("Clear All")),
                        ElevatedButton(
                            onPressed: () async {
                              await createPdfFile(context);
                            },
                            child: const Text("Convert To Pdf")),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: clickedImages.length,
                      itemBuilder: (context, index) {
                        final data = clickedImages[index];

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.all(4),
                          // color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Image Size : ${data[1].toStringAsFixed(2)} kB",
                                      style: const TextStyle(
                                          // color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Image.memory(
                                  data[0],
                                  height: 300,
                                  width: double.maxFinite,
                                  fit: BoxFit.fitWidth,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    // Text("Your PDF SIZE is $pdfSize kB"),
                    // for (var picture in _pictures) Image.file(File(picture))
                  ],
                ),
              ),
            ),
    );
  }

  void onPressed() async {
    List<String> pictures;

    pictures = await CunningDocumentScanner.getPictures() ?? [];
    if (!mounted) return;
    _pictures = pictures;
    for (String picturePath in _pictures) {
      final compressedImage = await FlutterNativeImage.compressImage(
          picturePath,
          quality: 50,
          percentage: 50);

      // final file = File(picturePath);

      // final resizedImage = Completer<ui.Image>();

      // final stream = FileImage(file)
      //     .resolve(ImageConfiguration(size: Size(100, 100)))
      //     .addListener(ImageStreamListener((image, synchronousCall) {
      //   resizedImage.complete(image.image);
      // }));

      // final finalImage = await resizedImage.future;
      // final imageBytes = (await finalImage.toByteData())!.buffer.asUint8List();
      // final size = imageBytes.lengthInBytes ?? 0;
      // print(size);

      clickedImages.add([
        await compressedImage.readAsBytes(),
        ((await compressedImage.length()) / 1024)
      ]);
      // imagesUint8list.add(compressedImage.readAsBytesSync());
    }
    setState(() {});
  }

  getImageBytes(String imgPath) async {
    // final _image = IsolateImage.path(imgPath);

    // final _data = await _image.compress(
    //     maxSize: 1 * 1024 * 1024,
    //     maxResolution: ImageResolution(720, 720),
    //     format: ImageFormat.png);

    final compressedImage = await FlutterNativeImage.compressImage(imgPath,
        quality: 50, percentage: 50);
    imagesUint8list.add(compressedImage.readAsBytesSync());
  }

  createPdfFile(context) async {
    pdfSize = '0';
    imagesUint8list.clear();
    var pdf = pw.Document();
    //convert each image to Uint8List
    for (String image in _pictures) {
      await getImageBytes(image);
    }
    //create a list of images
    final List<pw.Widget> images = imagesUint8list.map((image) {
      return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: pw.Image(
              pw.MemoryImage(
                image,
              ),
              height: 700,
              fit: pw.BoxFit.fill));
    }).toList();

    //create PDF
    pdf.addPage(pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.max,
                children: images),
          ];
        }));

    final pdfBytes = await pdf.save();
    final _data = await pdfBytes.compress(
      maxSize: 3 * 1024 * 1024,
      resolution: ImageResolution(512, 512),
    ); // 1 M

    // _pdfBytes = _data;

    final directory =
        (await getExternalStorageDirectories(type: StorageDirectory.downloads))!
            .first;

    File file2 = File("${directory.path}/test.pdf");
    file2.writeAsBytesSync(pdfBytes);
    imagesUint8list.clear();

    debugPrint("${directory.path}/test.pdf");
    pdfSize = (await file2.length() / 1024).toStringAsFixed(2);
    debugPrint("PDF File Size  :   " + pdfSize + "kB");
    // setState(() {});
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewWidget(
            pdfPath: file2.path,
          ),
        ));
  }
}

class PdfPreviewWidget extends StatefulWidget {
  const PdfPreviewWidget({super.key, this.pdfPath});
  final pdfPath;
  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  double pdfSize = 0;
  bool viewPdf = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSize();
  }

  getSize() async {
    pdfSize = await File(widget.pdfPath).length() / 1024;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (viewPdf) {
          viewPdf = false;
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                if (viewPdf) {
                  viewPdf = false;
                  setState(() {});
                } else {
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.arrow_back)),
          title: const Text("Pdf Preview"),
        ),
        body: viewPdf
            ? Container(child: SfPdfViewer.file(File(widget.pdfPath)))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(4),
                      // color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pdf Path : ${widget.pdfPath}",
                              style: const TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Pdf Size : ${pdfSize.toStringAsFixed(2)} kB",
                              style: const TextStyle(
                                  // color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () {
                                viewPdf = true;
                                setState(() {});
                              },
                              child: SizedBox(
                                width: 100,
                                child: Image.network(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/PDF_file_icon.svg/833px-PDF_file_icon.svg.png",
                                  // height: 300,

                                  fit: BoxFit.fill,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
