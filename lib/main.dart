import 'package:flutter/material.dart';
import 'package:janpath_school/app.dart';
import 'package:janpath_school/config/database.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await windowManager.ensureInitialized();

  // set fullscreen before running the app
  await windowManager.setFullScreen(true);

  // optionally wait for the window to be ready
  await windowManager.waitUntilReadyToShow();

  await DatabaseHelper().database;

  runApp(const JanpathApp());
}
