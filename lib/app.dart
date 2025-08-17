import 'package:flutter/material.dart';
import 'package:janpath_school/config/router.dart';
import 'package:janpath_school/dashboard/widgets/app_header.dart';

class JanpathApp extends StatelessWidget {
  const JanpathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'जनपथ माध्यमिक विद्यालय',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const BaseLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          AppHeader(title: title),
          Expanded(child: child),
        ],
      ),
    );
  }
}
