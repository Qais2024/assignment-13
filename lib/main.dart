import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'sqflite.dart';

 void main()async{
  WidgetsFlutterBinding();
  await Hive.initFlutter();
  await Hive.openBox("bundel_box");
  runApp(MaterialApp(
    home: Myapp(),debugShowCheckedModeBanner: false,));
}