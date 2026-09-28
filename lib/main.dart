// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  await initializeApp();
  runApp(
    const ProviderScope(
      child: ServisinAjaApp(),
    ),
  );
}
