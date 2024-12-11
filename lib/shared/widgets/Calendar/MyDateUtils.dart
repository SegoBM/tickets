import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtils {
  static Future<void> displayDatePicker(BuildContext context, TextEditingController? dateC, DateTime selected, DateTime initial, DateTime last) async {
    var date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );

    if (date != null) {
      dateC?.text = date.toLocal().toString().split(" ")[0];
    }
  }
  static Future<void> displayTimePicker(BuildContext context, TextEditingController timeC, TimeOfDay timeOfDay, bool ampm) async {
    var time = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (time != null) {
      int hour = time.hour;
      String period = 'AM';

      // Calcula si es AM o PM
      if (hour >= 12) {
        period = 'PM';
        if (hour > 12) {
          hour -= 12; // Convierte la hora en formato de 12 horas
        }
      }
      if (ampm){
        timeC.text = "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
      }else{
        timeC.text = "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      }
    }
  }
}

