/// Configuracion central de la app.
///
/// Todo lo que puedas necesitar cambiar esta en este archivo.
/// No hace falta tocar ningun otro codigo para cambiar el stream,
/// el WhatsApp, las redes sociales o la programacion.
library;

class AppConfig {
  // ---------------------------------------------------------------
  // IDENTIDAD
  // ---------------------------------------------------------------
  static const String appName = 'Rumba.Com';
  static const String tagline = 'La programación musical perfecta';

  /// Debe coincidir con `version:` en pubspec.yaml.
  static const String version = '2.0.0';

  // ---------------------------------------------------------------
  // STREAM
  // ---------------------------------------------------------------
  /// URL del stream de audio.
  static const String streamUrl =
      'https://streaming.radiosenlinea.com.ar/8588/stream';

  /// Endpoint del panel que devuelve la cancion actual y el historial.
  /// Verificado: responde con JSON {history:[...], art, listeners}.
  /// Es mas fiable que la metadata cruda del stream. Dejalo vacio para
  /// usar solo la metadata del stream en su lugar.
  static const String nowPlayingApiUrl =
      'https://streaming.radiosenlinea.com.ar/cp/get_info.php?p=8588';

  /// Cada cuantos segundos preguntar la cancion actual al panel.
  static const int nowPlayingPollSeconds = 15;

  // ---------------------------------------------------------------
  // CONTACTO
  // ---------------------------------------------------------------
  /// Numero de WhatsApp para pedir canciones, en formato internacional
  /// sin +, sin espacios y sin guiones. Ejemplo Colombia: 573001234567
  static const String whatsappNumber = '573043336106';

  static const String whatsappMessage =
      'Hola Rumba.Com! Quiero pedir una canción:';

  /// Politica de privacidad.
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/politicas-de-privacidad-rumba/p%C3%A1gina-principal';

  /// Enlace de la app en Google Play, usado al compartir y al calificar.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rumbapuntocom.radio';

  // ---------------------------------------------------------------
  // REDES SOCIALES
  // Borra o agrega las que quieras. Iconos disponibles:
  // facebook, instagram, whatsapp, youtube, tiktok, x, web
  // ---------------------------------------------------------------
  static const List<SocialLink> socials = [
    SocialLink(
      name: 'Facebook',
      icon: 'facebook',
      url: 'https://www.facebook.com/profile.php?id=61553321344548&locale=es_LA',
    ),
    SocialLink(
      name: 'Instagram',
      icon: 'instagram',
      url: 'https://www.instagram.com/rumba.comturadio',
    ),
    SocialLink(
      name: 'WhatsApp',
      icon: 'whatsapp',
      url: 'https://wa.me/$whatsappNumber',
    ),
  ];

  // ---------------------------------------------------------------
  // PROGRAMACION
  // day: 1 = lunes ... 7 = domingo
  // Usa formato de 24 horas.
  // ---------------------------------------------------------------
  static const List<Program> schedule = [
    Program(
      title: 'Amanecer Rumbero',
      host: 'Equipo Rumba.Com',
      day: 1,
      startHour: 6,
      endHour: 10,
    ),
    Program(
      title: 'La Hora del Sabor',
      host: 'Equipo Rumba.Com',
      day: 1,
      startHour: 12,
      endHour: 14,
    ),
    Program(
      title: 'Tarde Tropical',
      host: 'Equipo Rumba.Com',
      day: 1,
      startHour: 16,
      endHour: 19,
    ),
    Program(
      title: 'Rumba de Noche',
      host: 'Equipo Rumba.Com',
      day: 5,
      startHour: 20,
      endHour: 23,
    ),
    Program(
      title: 'Domingo en Familia',
      host: 'Equipo Rumba.Com',
      day: 7,
      startHour: 9,
      endHour: 13,
    ),
  ];

  // ---------------------------------------------------------------
  // COMPORTAMIENTO
  // ---------------------------------------------------------------
  /// Empezar a reproducir apenas se abre la app.
  static const bool autoPlayByDefault = true;

  /// Cuantas canciones guardar en el historial.
  static const int historyLimit = 60;

  /// Segundos de espera antes de reintentar cuando se cae el stream.
  static const int reconnectDelaySeconds = 5;
}

class SocialLink {
  final String name;
  final String icon;
  final String url;

  const SocialLink({
    required this.name,
    required this.icon,
    required this.url,
  });
}

class Program {
  final String title;
  final String host;

  /// 1 = lunes, 7 = domingo
  final int day;
  final int startHour;
  final int endHour;

  const Program({
    required this.title,
    required this.host,
    required this.day,
    required this.startHour,
    required this.endHour,
  });

  bool get isOnAir {
    final now = DateTime.now();
    return now.weekday == day && now.hour >= startHour && now.hour < endHour;
  }

  String get timeLabel =>
      '${startHour.toString().padLeft(2, '0')}:00 - '
      '${endHour.toString().padLeft(2, '0')}:00';

  static const List<String> dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  String get dayName => dayNames[(day - 1).clamp(0, 6)];
}
