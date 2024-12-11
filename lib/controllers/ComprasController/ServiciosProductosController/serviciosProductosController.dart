import 'dart:convert';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/serviciosProductos.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
const urlapi= url;

class ServiciosProductosController with ChangeNotifier {
  ServiciosProductosController() {}
  final String baseUrl = "http://192.168.1.251:85";

  //GET ServiciosProductos
  Future<List<ServiciosProductosModels>> GetServiciosProductos() async {
    List<ServiciosProductosModels> listServiciosProductos = [];
    final url1 = Uri.http(urlapi, '/api/ServiciosProductos/');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      listServiciosProductos = serviciosProductosModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listServiciosProductos;
  }

  //GET ServiciosProductos{id}
  Future<ServiciosProductos> getServiciosProductosID(String idServicioProducto) async {
    print("Obteniendo datos del producto");
    // Asegúrate de que la URL esté bien formada.
    final url1 = Uri.http(urlapi, '/api/ServiciosProductos/ServicioProductoProveedores', {
      'id': idServicioProducto.toUpperCase(),
    });
    print(url1);
    try {
      // Realiza la solicitud HTTP GET a la API
      final response = await http.get(url1, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }); // Establece un timeout para la solicitud

      // Verifica el estado de la respuesta
      if (response.statusCode == 200) {
        print('Respuesta de la API: ${response.body}');
        // Decodifica el JSON de la respuesta
        final jsonResponse = json.decode(response.body);
        // Convierte el JSON a una instancia de ServiciosProductos
        return ServiciosProductos.fromJson2(jsonResponse);

      } else {
        // Si la respuesta tiene un estado diferente a 200, lanza un error
        print('Error en la solicitud: ${response.statusCode}');
        throw Exception('Error al obtener el producto, código de estado: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores de la solicitud
      print('Error al realizar la solicitud: $e');
      throw Exception('Error al conectar con la API');
    }
  }

  //GET Servicios
  Future<List<ServiciosProductosModels>> GetServicios(List<int> estatus) async {
    List<ServiciosProductosModels> listServicios = [];
    Uri url = Uri.parse('$baseUrl/api/ServiciosProductos/ServiciosEstatus')
        .replace(queryParameters: {'estatus': estatus.map((e) => e.toString()).toList()});
    try {
      final response = await http.get(url, headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-type": "application/json",
      });
      if (response.statusCode == 200) {
        listServicios= serviciosProductosModelsFromJson(response.body);
      } else {
        print('*Error en la solicitud*: ${response.statusCode}');
      }
    } catch (error) {
      print('*Error en la solicitud*: $error');
      throw Exception('Error al obtener los servicios');
    }
    return listServicios;
  }

  //GET Productos
  Future<List<ServiciosProductosModels>> GetProductos(List<int> estatus) async {
    List<ServiciosProductosModels> listProductos = [];
    // Construir la URL completa con los parámetros de consulta
    Uri url = Uri.parse('$baseUrl/api/ServiciosProductos/ProductosEstatus')
        .replace(queryParameters: {'estatus': estatus.map((e) => e.toString()).toList()});
    try {
      final response = await http.get(url, headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-type": "application/json",
      });
      if (response.statusCode == 200) {
        listProductos = serviciosProductosModelsFromJson(response.body);
      } else {
        print('*Error en la solicitud*: ${response.statusCode}');
      }
    } catch (error) {
      print('*Error en la solicitud*: $error');
      throw Exception('Error al obtener los productos');
    }
    return listProductos;
  }

  //POST Servicio&Producto
  Future<bool> saveServicioProductoConProveedores(ServiciosProductos servicioProducto) async {
    Uri url = Uri.parse('$baseUrl/api/ServiciosProductos/ServicioProductoWithProveedores');
    final resp = await http.post(url,
      body: jsonEncode({
        "serviciosProductos": {
          "codigo": servicioProducto.serviciosProductos.codigo,
          "descripcion": servicioProducto.serviciosProductos.descripcion,
          "clasificacion": servicioProducto.serviciosProductos.clasificacion,
          "categoria": servicioProducto.serviciosProductos.categoria,
          "estatus": servicioProducto.serviciosProductos.estatus,
          "foto": servicioProducto.serviciosProductos.foto ?? null,
          "concepto": servicioProducto.serviciosProductos.concepto,
          "duracionAproximada": servicioProducto.serviciosProductos.duracionAproximada ?? 'N/A',
          "unidad": servicioProducto.serviciosProductos.unidad,
          "moneda": servicioProducto.serviciosProductos.moneda,
          "costeo": servicioProducto.serviciosProductos.costeo,
          "claveSATID": servicioProducto.serviciosProductos.claveSATID ?? null,
        },
        "proveedores": servicioProducto.proveedoresList?.map((e) => e.toJson2()).toList(),
        "listaPrecioPSMKs": servicioProducto.listaPrecioPSMK?.map((e) => e.toJson2()).toList(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    print('Response status: ${resp.statusCode}');
    print('Response body: ${resp.body}');

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  //PUT Servicio&Producto
  Future<bool> updateServiciosProductos (String IdServicioProducto, ServiciosProductos servicioProducto) async {
    final url1 = Uri.http(urlapi,
        '/api/ServiciosProductos/ActualizarServicioProductoConProveedores',
        {'id': IdServicioProducto.toUpperCase(),});
    print(url1);
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(url1,
          body:
          jsonEncode({
            "serviciosProductos": {
              "codigo": '${servicioProducto.serviciosProductos.codigo}',
              "descripcion": '${servicioProducto.serviciosProductos
                  .descripcion}',
              "clasificacion": '${servicioProducto.serviciosProductos
                  .clasificacion}',
              "categoria": '${servicioProducto.serviciosProductos.categoria}',
              "estatus": '${servicioProducto.serviciosProductos.estatus}',
              "foto": '${servicioProducto.serviciosProductos.foto}',
              "concepto": '${servicioProducto.serviciosProductos.concepto}',
              "duracionAproximada": '${servicioProducto.serviciosProductos
                  .duracionAproximada}',
              "unidad": '${servicioProducto.serviciosProductos.unidad}',
              "moneda": '${servicioProducto.serviciosProductos.moneda}',
              "costeo": '${servicioProducto.serviciosProductos.costeo}',
              "claveSATID": '${servicioProducto.serviciosProductos.claveSATID ?? null}',
            },
            "proveedores": servicioProducto.proveedoresList?.map((e) =>
                e.toJson2()).toList(),
            "listaPrecioPSMKs": servicioProducto.listaPrecioPSMK?.map((e) =>
                e.toJson2()).toList(),
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          print("Actualizado");
          print(  jsonEncode({
            "serviciosProductos": {
              "codigo": '${servicioProducto.serviciosProductos.codigo}',
              "descripcion": '${servicioProducto.serviciosProductos
                  .descripcion}',
              "clasificacion": '${servicioProducto.serviciosProductos
                  .clasificacion}',
              "categoria": '${servicioProducto.serviciosProductos.categoria}',
              "estatus": '${servicioProducto.serviciosProductos.estatus}',
              "foto": '${servicioProducto.serviciosProductos.foto}',
              "concepto": '${servicioProducto.serviciosProductos.concepto}',
              "duracionAproximada": '${servicioProducto.serviciosProductos
                  .duracionAproximada}',
              "unidad": '${servicioProducto.serviciosProductos.unidad}',
              "moneda": '${servicioProducto.serviciosProductos.moneda}',
              "costeo": '${servicioProducto.serviciosProductos.costeo}',
              "claveSATID": '${servicioProducto.serviciosProductos.claveSATID ?? null}',
            },
            "proveedores": servicioProducto.proveedoresList?.map((e) =>
                e.toJson2()).toList(),
            "listaPrecioPSMKs": servicioProducto.listaPrecioPSMK?.map((e) =>
                e.toJson2()).toList(),
          }));
          return true;
        } else {
          print("Error: ${resp.statusCode}");
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
    }
    return false;
  }

  //PUT Servicio&Producto
  Future<bool> updateEstatusServicio(String IdServicioProducto, int estatus) async {
    final url1 = Uri.http(
      urlapi,
      'api/ServiciosProductos/EstatusServiciosProductos',
      {
        'id': IdServicioProducto,
        'estatus': estatus.toString(),
      },
    );
    try {
      final resp = await http.put(
        url1,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (resp.statusCode == 200) {
        return true;
      } else {
        print('Error: ${resp.statusCode}, ${resp.body}');
        return false;
      }
    } catch (e){
      print('Exception: $e');
      return false;
    }
  }

  //DELETE Servicio&Producto
  Future<bool> deleteServicioProducto(String IdServicioProducto) async{
    final url1 = Uri.http(urlapi, 'api/ServiciosProductos/DeleteServicioProducto', {'id' : IdServicioProducto.toString()});
    final resp = await http.delete(
        url1,
      headers: {
          'Content-Type' : 'application/json',
          'Accept' : 'application/json',
      },
    );
    if (resp.statusCode == 200){
      return true;
    } else if ( resp.statusCode == 404){
      return false;
    }else {
      print ( resp.body);
      return false;
    }
  }

}
