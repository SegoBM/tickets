import 'package:flutter/material.dart';

class LoadingDialog {
  static final GlobalKey<State> _keyLoader = GlobalKey<State>();
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
            key: _keyLoader,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(), // Un indicador de carga
              const SizedBox(height: 16.0),
              Text(message, style: const TextStyle(fontSize: 18),), // Un mensaje opcional
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (_keyLoader.currentContext != null) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    }
  }


}