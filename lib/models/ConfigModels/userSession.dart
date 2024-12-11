import 'package:shared_preferences/shared_preferences.dart';

class UserSession{
  static const String _tokenKey ='auth_token';
  static const dateTimeKey = 'dateTime';

  Future <void> setToken(String token) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future <String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future <void> removeToken() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future <void> setDateTime(String dateTime) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dateTimeKey, dateTime);
  }

  Future <String> getDateTime() async{
    final prefs = await SharedPreferences.getInstance();
    String? dateTimeString = prefs.getString(dateTimeKey);
    if(dateTimeString == null || dateTimeString.isEmpty){
      return '';
    }
    return dateTimeString;
  }

  Future <void> removeDateTime() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(dateTimeKey);
  }
}