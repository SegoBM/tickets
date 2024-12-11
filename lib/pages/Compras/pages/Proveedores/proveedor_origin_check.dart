import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'document_upload.dart';
import 'document_upload_fisica.dart';
import 'package:path/path.dart' as path;

class ProveedorOriginCheck extends StatefulWidget {
  @override
  ProveedorOriginCheckState createState() => ProveedorOriginCheckState();
}

class ProveedorOriginCheckState extends State<ProveedorOriginCheck> {
  late ThemeData theme;
  late Size size;

  String? selectedProveedorType;
  final List<String> proveedorTypes = ["SERVICIO", "FABRICANTE", "DISTRIBUIDOR"];

  String? selectedLocalExtranjero;
  final List<String> localExtranjeroOptions = ["LOCAL", "EXTRANJERO"];

  String? selectedPersonaType;
  final List<String> personaTypes = ["PERSONA FISICA", "PERSONA MORAL"];

  List<String> _filePaths = [];
  bool _isPersonaTypeSelectable = true;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 60.0),
                Flexible(
                  child: DropdownButton<String>(
                    value: selectedProveedorType,
                    hint: Text("Tipo de Proveedor"),
                    items: proveedorTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProveedorType = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 60.0),
                Flexible(
                  child: DropdownButton<String>(
                    value: selectedLocalExtranjero,
                    hint: Text("Tipo de Origen"),
                    items: localExtranjeroOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLocalExtranjero = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 60.0),
                Flexible(
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedPersonaType,
                        hint: Text("Tipo de Persona"),
                        items: personaTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13.2, fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary,)),
                          );
                        }).toList(),
                        onChanged: _isPersonaTypeSelectable ? (String? newValue) {
                          setState(() {
                            selectedPersonaType = newValue;
                            if (newValue == "PERSONA MORAL") {
                              _showDocumentUploadModal();
                            } else if (newValue == "PERSONA FISICA") {
                              _showDocumentUploadModalFisica();
                            }
                          });
                        } : null,
                      ),
                      SizedBox(width: 30.0),
                      IconButton(
                        icon: Icon(Icons.edit_document, color: theme.colorScheme.onPrimary),
                        onPressed: (){
                          selectedPersonaType=="PERSONA FISICA"?_showDocumentUploadModalFisica():_showDocumentUploadModal();
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentUploadModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return DocumentUploadModal(
          onSave: (List<String> filePaths) {
            setState(() {
              _filePaths = filePaths;
              _isPersonaTypeSelectable = false;
            });
          },
        );
      },
    );
  }

  void _showDocumentUploadModalFisica() {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      isScrollControlled: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return DocumentUploadModalFisica(
          onSave: (List<String> filePaths) {
            setState(() {
              _filePaths = filePaths;
              _isPersonaTypeSelectable = false;
            });
          },
        );
      },
    );
  }
}
