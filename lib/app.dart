import 'package:flutter/material.dart';

class FieldTaskApp extends StatelessWidget {
  const FieldTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: remplacer par MaterialApp.router avec go_router
    // (login -> liste -> detail -> carte).
    return MaterialApp(
      title: 'FieldTask Pro',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Scaffold(body: Center(child: Text('FieldTask Pro'))),
    );
  }
}
