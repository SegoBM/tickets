import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const THEME_STATUS = "THEMESTATUS";

  setTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool?> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS); // Si no se encuentra ninguna preferencia, se devuelve null
  }
  Future<void> guardarUsuario(UsuarioModels usuario) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("idUsuario", usuario.idUsuario??"");
    await preferences.setString("nombre", usuario.nombre);
    await preferences.setString("apellidoPaterno", usuario.apellidoPaterno);
    await preferences.setString("apellidoMaterno", usuario.apellidoMaterno!);
    await preferences.setString("userName", usuario.userName);
    await preferences.setString("contrasenia", usuario.contrasenia);
    await preferences.setString("tipoUsuario", usuario.tipoUsuario);
    await preferences.setString("puestoId", usuario.puestoId?? "");
    await preferences.setString("empresaId", usuario.empresaID?? "");
    await preferences.setString("empresaNombre", usuario.empresaNombre?? "");
  }

  Future<UsuarioModels> getUsuario() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UsuarioModels usuario = UsuarioModels(idUsuario: "", nombre: "", apellidoPaterno: "",empresaID: "",
        apellidoMaterno: "", userName: "", contrasenia: "", tipoUsuario: "", puestoId: ""
        , empresaNombre: "");
    final String nombre = preferences.getString("nombre") ?? "";
    if(nombre!= ""){
      final String idUsuario = preferences.getString("idUsuario") ?? "";
      final String apellidoPaterno = preferences.getString("apellidoPaterno") ?? "";
      final String apellidoMaterno = preferences.getString("apellidoMaterno") ?? "";
      final String userName = preferences.getString("userName") ?? "";
      final String contrasenia = preferences.getString("contrasenia") ?? "";
      final String tipoUsuario = preferences.getString("tipoUsuario") ?? "";
      final String puestoId = preferences.getString("puestoId") ?? "";
      final String empresaId = preferences.getString("empresaId") ?? "";
      final String empresaNombre = preferences.getString("empresaNombre") ?? "";
      usuario = UsuarioModels(idUsuario: idUsuario, nombre: nombre, apellidoPaterno: apellidoPaterno,empresaID: empresaId,
          apellidoMaterno: apellidoMaterno, userName: userName, contrasenia: contrasenia, tipoUsuario: tipoUsuario, puestoId: puestoId
          , empresaNombre: empresaNombre);
      return usuario;
    }
    return usuario;
  }
  Future<String> getUsuarioNombre() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String user = await preferences.getString("nombre") ?? "";

    return user;
  }
  Future<String> getUsuarioID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String user = await preferences.getString("idUsuario") ?? "";

    return user;
  }
  Future<String> getEmpresaId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String empresaId = await preferences.getString("empresaId") ?? "";

    return empresaId;
  }
  Future<String> getEmpresaNombre() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String empresaNombre = await preferences.getString("empresaNombre") ?? "";

    return empresaNombre;
  }

  Future<String> getPuestoID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String puestoId = await preferences.getString("puestoId") ?? "";

    return puestoId;
  }

  Future<void> changeCompanyId(String empresaID, String empresaNombre) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("empresaId", empresaID);
    await preferences.setString("empresaNombre", empresaNombre);
  }
  Future<void> borrarUsuario() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("idUsuario");        await preferences.remove("nombre");
    await preferences.remove("apellidoPaterno");  await preferences.remove("apellidoMaterno");
    await preferences.remove("userName");         await preferences.remove("contrasenia");
    await preferences.remove("tipoUsuario");      await preferences.remove("puestoId");
    await preferences.remove("empresaId");        await preferences.remove("empresaNombre");
  }
}