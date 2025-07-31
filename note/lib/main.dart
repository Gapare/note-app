import 'package:flutter/material.dart';
import 'package:note/pages/home.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Notes', home: Home());
  }
}
