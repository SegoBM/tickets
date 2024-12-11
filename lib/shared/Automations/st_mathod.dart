List<String> parseInputToList(String input) {
  final result = <String>[];

  // Mapeo de tallas de ropa en orden
  final sizes = ["xxs","xs", "s", "m", "l", "xl", "xxl"];
  final sizeIndices = {for (var i = 0; i < sizes.length; i++) sizes[i]: i};

  // Divide la entrada por comas
  final parts = input.split(',');

  for (var part in parts) {
    if (part.contains('-')) {
      // Si el segmento contiene un rango
      // Dividir el segmento por el guion para identificar un posible rango
      final rangeParts = part.split('-');
      if (rangeParts.length == 2) {
        // `rangeParts` tendrá dos elementos: `start` y `end`
        // `start` es el valor inicial del rango y `end` el valor final.
        final start = rangeParts[0];
        final end = rangeParts[1];

        // Comprobar si ambos extremos del rango (`start` y `end`) son tallas de ropa conocidas
        if (sizeIndices.containsKey(start) && sizeIndices.containsKey(end)) {
          // Expande el rango de tallas de ropa (ej. `m-xl` se convierte en `["m", "l", "xl"]`)
          // Obtén los índices de `start` y `end` en la lista `sizes` usando el mapa `sizeIndices`.
          final startIndex = sizeIndices[start]!;
          final endIndex = sizeIndices[end]!;
          if(startIndex > endIndex){
            print('El rango no es válido');
          }else{
            // Añade a `result` cada talla entre `start` y `end` usando el índice.
            for (var i = startIndex; i <= endIndex; i++) {
              result.add(sizes[i]);
            }
          }
        }
        // Si no es un rango de tallas, revisamos si `start` y `end` son números
        else if (int.tryParse(start) != null && int.tryParse(end) != null) {
          // Expande el rango de números (ej. `5-8` se convierte en `["5", "6", "7", "8"]`)
          final startNum = int.parse(start);
          final endNum = int.parse(end);

          // Añade a `result` cada número entre `startNum` y `endNum`.
          for (var i = startNum; i <= endNum; i++) {
            result.add(i.toString());
          }
        }
        // Si `start` y `end` son letras individuales, expande el rango de letras
        else if (start.length == 1 && end.length == 1 &&
            start.codeUnitAt(0) <= end.codeUnitAt(0)) {
          // Expande el rango de letras (ej. `a-c` se convierte en `["a", "b", "c"]`)
          for (var i = start.codeUnitAt(0); i <= end.codeUnitAt(0); i++) {
            result.add(String.fromCharCode(i));
          }
        }else{
          print('No es un rango válido');
        }
      }
    } else {
      // Añadir directamente si no es un rango
      result.add(part);
    }
  }
  return result;
}