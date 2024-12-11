import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

///[ thisMethod ] is a widget that allows you to pick an image from the gallery or the camera
///[Use] this method to pick an image from the gallery or the camera
// (File image) {
// setState(() {
// _image = image;
// });
// },
///

class MyImagePickerWidget extends StatefulWidget {

  final double height;
  final double width;
  final Function(File) onImagePicked;
  final String holderText;

  const MyImagePickerWidget({
    super.key,
    required this.height,
    required this.width,
    required this.onImagePicked,
    required this.holderText
  });

  @override
  State<MyImagePickerWidget> createState() => _MyImagePickerWidgetState();
}
class _MyImagePickerWidgetState extends State<MyImagePickerWidget> {
  late Size size;
  File? _image;
  Future<void> _pickImage(ImageSource camera) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      final File imageFile = File(file.path.toString());
      // Check image size and compress if necessary
      int fileSize = await imageFile.length();
      int maxSize = 1024 * 1024;
      if (fileSize <= maxSize) {
        setState(() {
          _image = imageFile;
        });
        widget.onImagePicked(_image!);
      } else {
        // Compress the image
        Uint8List compressedBytes = await compressImage(imageFile);
        // Create a temporary file from the compressed bytes
        final tempDir = await Directory.systemTemp.createTemp();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(compressedBytes);
        setState(() {
          _image = tempFile;
        });
        widget.onImagePicked(_image!);
      }
    } else {
      // User canceled
    }
  }
  Future<Uint8List> compressImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    String base64String = base64.encode(imageBytes);
    String compressedBase64 = await reducirCalidadImagenBase64(base64String);
    Uint8List compressedBytes = base64.decode(compressedBase64);
    return compressedBytes;
  }
  Future<String> reducirCalidadImagenBase64(String base64Str, {int calidad = 50}) async {
    // Decodificar la imagen base64 a Uint8List
    Uint8List bytes = base64.decode(base64Str);
    // Decodificar la imagen para obtener un objeto Image de 'image'
    img.Image? image = img.decodeImage(bytes);
    // Codificar la imagen a JPEG con una calidad reducida
    Uint8List jpeg = img.encodeJpg(image!, quality: calidad);
    // Convertir la imagen optimizada a base64
    return base64.encode(jpeg);
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          if(_image == null )
            Text(
              widget.holderText,
              style: const TextStyle(fontWeight: FontWeight.normal,),
            ),
          const SizedBox( height: 4 ),
          _image != null
              ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.height-35,
              maxWidth: widget.width-40,
            ),
            child: Image.file(
              _image!,
              fit: BoxFit.contain,
            ),
          )
              : Container(
            height: widget.height*.35,
            width: widget.width*.25,
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              color: Colors.white,
              Icons.image,
              size: widget.width*.25 ,
              shadows: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.5,
                  blurStyle: BlurStyle.outer,
                  offset: Offset(1, 3),
                ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children:[

                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
          ])
        ],
      ),
    );
  }
}
