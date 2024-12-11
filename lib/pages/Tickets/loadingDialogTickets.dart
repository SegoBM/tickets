import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';

class LoadingDialogTickets {
  static final GlobalKey<State> _keyLoader = GlobalKey<State>();
  static void showLoadingDialogTickets(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: ColorPalette.ticketsColor,
          key: _keyLoader,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(backgroundColor: ColorPalette.ticketsColor,color: Colors.white,), // Un indicador de carga
              const SizedBox(height: 16.0),
              Text(message, style: const TextStyle(fontSize: 18, color: Colors.white),), // Un mensaje opcional
            ],
          ),
        );
      },
    );
  }

  static void hideLoadingDialogTickets(BuildContext context) {
    if (_keyLoader.currentContext != null) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    }
  }


}