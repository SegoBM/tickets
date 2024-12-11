import 'dart:convert';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../../models/ConfigModels/GeneralSettingsModels/listaPrecio.dart';

const urlapi= url;
const waitTime1 = waitTime;
class ListaPrecioController with ChangeNotifier {
  ListaPrecioController() {}

  Future<List<ListaPrecio>> getListaPrecio() async {
    final url1 = Uri.http(urlapi, '/api/ListaPrecio');
    List<ListaPrecio> listaPrecio = [];
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          listaPrecio = listaPrecioFromJson(resp.body);
          return listaPrecio;
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return listaPrecio;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listaPrecio;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listaPrecio;
  }
  Future<List<ListaPrecio>> getListaPrecioActivos() async {
    List<ListaPrecio> listaPrecio = [];
    final url1 = Uri.http(urlapi, '/api/ListaPrecio/Activos');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          listaPrecio = listaPrecioFromJson(resp.body);
          return listaPrecio;
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return listaPrecio;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listaPrecio;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listaPrecio;
  }
  Future<ListaPrecio?> saveListaPrecio(ListaPrecio listaPrecio, String id) async {
    final url1 = Uri.http(urlapi, '/api/ListaPrecio', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "precio": listaPrecio.precio,
            "descripcion": listaPrecio.descripcion,
            "porcentaje": listaPrecio.porcentaje,
            "porcentajeValue": listaPrecio.porcentajeValue,
            "monto": listaPrecio.monto,
            "montoValue": listaPrecio.montoValue,
            "capturaManual": listaPrecio.capturaManual,
            "listaBase": listaPrecio.listaBase
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200) {
          return listaPrecioModelFromJson(resp.body);
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return null;
  }
  Future<ListaPrecio?> updateListaPrecio(ListaPrecio listaPrecio, String id) async {
    final url1 = Uri.http(urlapi, '/api/ListaPrecio', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "idListaPrecio": listaPrecio.idListaPrecio,
            "precio": listaPrecio.precio,
            "descripcion": listaPrecio.descripcion,
            "porcentaje": listaPrecio.porcentaje,
            "porcentajeValue": listaPrecio.porcentajeValue,
            "monto": listaPrecio.monto,
            "montoValue": listaPrecio.montoValue,
            "capturaManual": listaPrecio.capturaManual,
            "listaBase": listaPrecio.listaBase
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200) {
          return listaPrecioModelFromJson(resp.body);
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return null;
  }
  Future<bool> changeStatusListaPrecio(String idListaPrecio, bool estatus, String id) async {
    final url1 = Uri.http(urlapi, '/api/ListaPrecio/Estatus', {'id': idListaPrecio, 'estatus': estatus.toString(), 'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return true;
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
}