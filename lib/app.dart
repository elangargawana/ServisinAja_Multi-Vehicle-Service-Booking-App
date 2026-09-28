// lib/app.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:servis_aja/core/router/app_router.dart';
import 'package:servis_aja/core/theme/app_theme.dart';

/// Root application widget.
/// ProviderScope wraps the entire tree — Riverpod requirement.
class ServisinAjaApp extends StatelessWidget {
  const ServisinAjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ServisinAja',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

/// Initializes locale data before running the app.
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Indonesian locale for intl date formatting
  await initializeDateFormatting('id_ID');
}
