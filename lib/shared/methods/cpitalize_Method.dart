String capitalize2 (String texto) {
  if (texto.isEmpty) return texto;

  return texto.split(' ').map((palabra) {
    if( palabra.isEmpty) return palabra;
    return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
  }).join(' ');
}
