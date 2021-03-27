import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sudokutable/ui/Home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  runApp(
    MaterialApp(
      title:"Sudo king",
      home:Home(),
      debugShowCheckedModeBanner: false,
    )
  );
}
