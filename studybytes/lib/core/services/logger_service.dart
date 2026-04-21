import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  // Instancia única del logger (patrón singleton)
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();
  
  // El logger real
  late final Logger _logger;
  
  // Inicializar el logger
  static void init() {
    _instance._logger = Logger(
      level: kDebugMode ? Level.debug : Level.info,
      printer: PrettyPrinter(
        methodCount: 2,        // Número de métodos en el stack trace
        errorMethodCount: 5,   // Métodos a mostrar en errores
        lineLength: 120,       // Longitud máxima de línea
        colors: true,          // Colores en la consola
        printEmojis: true,     // Emojis para cada nivel
        dateTimeFormat: DateTimeFormat.dateAndTime, // Mostrar fecha/hora
      ),
      output: kDebugMode ? ConsoleOutput() : null, // Solo output en debug
    );
  }
  
  // Métodos para diferentes niveles de log
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.d(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.i(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _instance._logger.w(message, error: error, stackTrace: stackTrace);
    }
  }
  
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // Los errores se muestran incluso en producción si quieres
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // "What a terrible failure" - para errores catastróficos
    _instance._logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}
