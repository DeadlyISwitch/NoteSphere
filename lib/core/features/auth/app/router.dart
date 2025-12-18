// Este archivo es parte de la aplicaci�n 
import 'package:flutter/material.dart';
import '../presentation/notes_page.dart';
import '../presentation/login_page.dart';

/// Manejador básico de rutas.
/// Preparado para migrar a go_router en el futuro.
class AppRouter {
  static const String home = '/';
  static const String auth = '/auth';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const NotesPage());
      case auth:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}