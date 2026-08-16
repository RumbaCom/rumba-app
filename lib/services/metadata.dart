/// Limpieza de los titulos que manda la emisora.
///
/// La metadata de Rumba.Com llega bastante sucia (verificado en el panel):
///   "2.) UB 40 - RED RED WINE.MP3"      -> numero, mayusculas, .MP3
///   "1.) ESTAS ESCUCHANDO - MIKE"       -> jingle del locutor, no cancion
///   "16.) JERRY RIVERA - NADA SIN TI"   -> formato bueno pero en mayusculas
///
/// Estas funciones la dejan presentable y separan artista de cancion.
library;

class Metadata {
  /// Limpia un titulo crudo. Devuelve null si no hay nada mostrable.
  static String? clean(String? raw) {
    if (raw == null) return null;

    var t = raw.trim();
    if (t.isEmpty) return null;

    // Quita el prefijo de posicion del historial: "12.) ".
    t = t.replaceFirst(RegExp(r'^\s*\d+\.\)\s*'), '');

    // Quita saltos de linea y espacios repetidos.
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Quita la extension del archivo al final: ".mp3", ".flac", etc.
    t = t.replaceFirst(RegExp(r'\.(mp3|flac|wav|m4a|aac|ogg)\s*$',
        caseSensitive: false), '');

    // Quita URLs.
    t = t.replaceAll(RegExp(r'https?://\S+'), '').trim();

    // Quita separadores sueltos al inicio o al final.
    t = t.replaceAll(RegExp(r'^[\s\-|•]+|[\s\-|•]+$'), '').trim();

    if (t.isEmpty) return null;

    // Descarta relleno.
    final lower = t.toLowerCase();
    const junk = ['unknown', 'no title', 'sin titulo', 'sin título', '-'];
    if (junk.contains(lower)) return null;

    // Titulos absurdamente largos suelen ser anuncios pegados.
    if (t.length > 120) return null;

    // Si viene TODO EN MAYUSCULAS, lo pasa a Formato De Titulo.
    if (t == t.toUpperCase() && t.contains(RegExp('[A-Z]'))) {
      t = _titleCase(t);
    }

    return t;
  }

  /// Reconoce los jingles e identificaciones del locutor, para no
  /// guardarlos en el historial como si fueran canciones. La reproduccion
  /// en pantalla si los muestra: es lo que suena en ese momento.
  static bool looksLikeJingle(String cleaned) {
    final l = cleaned.toLowerCase();
    const marks = [
      'estas escuchando',
      'estás escuchando',
      'identificacion',
      'identificación',
      'aqui suena',
      'aquí suena',
      'somos rumba',
      'para el mundo',
      'para l mundo',
      'soltando musica',
      'soltando música',
      'los que saben de musica',
      'los que saben de música',
      'sonando en hogares',
      'mejor programacion',
      'mejor programación',
      'spots',
    ];
    return marks.any(l.contains);
  }

  /// Separa "Artista - Cancion". Devuelve (titulo, artista?).
  static (String, String?) split(String full) {
    final parts = full.split(RegExp(r'\s+-\s+'));
    if (parts.length >= 2) {
      final artist = parts.first.trim();
      final title = parts.sublist(1).join(' - ').trim();
      if (artist.isNotEmpty && title.isNotEmpty) return (title, artist);
    }
    return (full, null);
  }

  static String _titleCase(String s) {
    // Palabras que se dejan en minuscula si no son la primera.
    const small = {
      'de', 'la', 'el', 'los', 'las', 'y', 'e', 'o', 'u', 'del', 'al',
      'un', 'una', 'en', 'con', 'por', 'para', 'a', 'sin', 'the', 'of',
    };

    final words = s.toLowerCase().split(' ');
    return words.asMap().entries.map((e) {
      final i = e.key;
      final w = e.value;
      if (w.isEmpty) return w;
      if (i != 0 && small.contains(w)) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}
