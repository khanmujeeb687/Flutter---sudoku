import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sudokutable/ui/Home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      title:"Sudo king",
      home:Home(),
      debugShowCheckedModeBanner: false,
    )
  );
}
