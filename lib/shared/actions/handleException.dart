import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/Snackbars/customSnackBar.dart';

class ConnectionExceptionHandler {
   void handleConnectionException(BuildContext context, dynamic e) async {
    switch (e.toString()) {
      case 'Connection failed':
        bool isConnected = await checkInternetConnection();
        if (!isConnected) {
          CustomSnackBar.showWarningSnackBar(
              context, 'No cuentas con conexión a internet');
        } else {
          CustomSnackBar.showErrorSnackBar(
              context, 'Error de servidor, contacte soporte');
        }
        break;
      case 'Connection timed out':
      case 'TimeoutException after 0:00:10.000000: Future not completed':
        CustomSnackBar.showErrorSnackBar(
            context, 'Tiempo excedido sin conexión, contacte soporte');
        break;
      default:
        CustomSnackBar.showErrorSnackBar(
            context, 'Error inesperado: Contacte soporte');
        print("EXCEPCION: $e");
        break;
    }
  }
  Future<String> handleConnectionExceptionString(dynamic e) async {
    switch (e.toString()) {
      case 'Connection failed':
        bool isConnected = await checkInternetConnection();
        if (!isConnected) {
          return 'No cuentas con conexión a internet';
        } else {
          return 'Error de servidor. Contacte soporte';
        }
        break;
      case 'Connection timed out':
      case 'TimeoutException after 0:00:10.000000: Future not completed':
        return 'Tiempo excedido sin conexión. Contacte soporte';
        break;
      default:
        return 'Error inesperado. Contacte soporte';
        break;
    }
  }
Future<bool> checkInternetConnection() async {
  try {
    final response = await http.get('https://www.google.com' as Uri);
    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {}
  return false;
}
}
