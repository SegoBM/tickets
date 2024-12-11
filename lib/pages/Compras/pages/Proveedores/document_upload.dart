import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentUploadModal extends StatefulWidget {
  final Function(List<String>) onSave;

  DocumentUploadModal({required this.onSave});

  @override
  _DocumentUploadModalState createState() => _DocumentUploadModalState();
}

class _DocumentUploadModalState extends State<DocumentUploadModal> {
  late Size size;
  late ThemeData theme;
  List<String?> _filePaths = List<String?>.filled(7, null);
  final List<String> _labels = [
    'Acta Constitutiva De La Sociedad',
    'Poder Del Representante Legal',
    'Registro Federal De Contribuyentes',
    'Comprobante De Domicilio',
    'Comprobante Situación Fiscal',
    'Identificación Oficial Vigente',
    'Curriculum Vitae De La Empresa',
  ];
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _saveDocuments() {
    List<String> filePaths = _filePaths.where((filePath) => filePath != null).cast<String>().toList();
    widget.onSave(filePaths);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    return FractionallySizedBox(
      heightFactor: 0.7, widthFactor: 0.9,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        child: Column(mainAxisSize: MainAxisSize.min,
          children: [
            Text("Anexar Documentos", style: DefaultTextStyle.of(context).style.copyWith(fontSize: 25, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,),),
            const SizedBox(height: 8.0), // Espaciado reducido
            Expanded(
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _labels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 3.0,
                    mainAxisSpacing: 3.0, childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_labels[index],
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4.0),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(onSecondaryTapDown: (details) {
                                      _showContextMenu(context, index, details.globalPosition);
                                    },
                                    onDoubleTap: () {
                                      if (_filePaths[index] != null) {
                                        _showFilePreviewDialog(_filePaths[index]!);
                                      }
                                    },
                                    child: _filePaths[index] != null ? _buildFilePreview(_filePaths[index]!) : const Icon(Icons.attach_file),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                TextButton(
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                                    if (result != null) {
                                      setState(() {_filePaths[index] = result.files.single.path;
                                      });
                                    }
                                  },
                                  child: Tooltip(
                                    message: _filePaths[index] != null ? path.basename(_filePaths[index]!) : '',
                                    child: Text(_filePaths[index] != null ? path.basename(_filePaths[index]!) : 'Seleccionar Documento',
                                      overflow: TextOverflow.ellipsis, maxLines: 1,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(top: -12, right: -12,
                            child: IconButton( icon: const Icon(Icons.close, size: 16, color: Colors.red,),
                              onPressed: () {setState(() {_filePaths[index] = null;});
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0), // Espaciado reducido
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancelar"),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(250, 40),
                      primary: theme.colorScheme.onPrimary,
                      backgroundColor: theme.colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _saveDocuments();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Guardar"),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(250, 40),
                      primary: theme.colorScheme.onPrimary,
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, int index, Offset position) {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'Eliminar',
          height: 25,
          child: Text(
            "Eliminar",
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 13.2,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Eliminar') {
        setState(() {
          _filePaths[index] = null;
        });
      }
    });
  }

  Widget _buildFilePreview(String filePath) {
    String extension = path.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return const Icon(Icons.picture_as_pdf, size: 40);
    } else if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
      return const Icon(Icons.image, size: 40);
    } else if (extension == '.txt') {
      return const Icon(Icons.text_snippet, size: 40);
    } else {
      return const Icon(Icons.insert_drive_file, size: 40);
    }
  }

  void _showFilePreviewDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget content;
        String extension = path.extension(filePath).toLowerCase();

        if (extension == '.pdf') {
          content = SfPdfViewer.file(File(filePath));
        } else {
          content = const Center(child: Text("Vista no disponible"));
        }

        return AlertDialog(
          title: const Text("Vista Previa del Archivo"),
          content: Container(
            width: size.width * 0.4,
            height: size.height * 0.7,
            child: content,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cerrar"),
              style: TextButton.styleFrom(
              minimumSize: const Size(150, 40),
              primary: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.secondary,),
            ),
          ],
        );
      },
    );
  }
}
