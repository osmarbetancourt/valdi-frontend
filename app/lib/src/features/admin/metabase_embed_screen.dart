import 'package:flutter/material.dart';

class MetabaseEmbedScreen extends StatelessWidget {
  const MetabaseEmbedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Embedded Dashboards')),
      body: const Center(child: Text('Metabase embed / iframe flow goes here')),
    );
  }
}
