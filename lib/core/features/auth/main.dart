// Este archivo es parte de la aplicaci�n 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

/// Punto de entrada de la aplicación.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope es necesario para que Riverpod funcione.
  runApp(
    const ProviderScope(
      child: NotesApp(),
    ),
  );
}