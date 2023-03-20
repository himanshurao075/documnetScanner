import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
