import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polity/dashboard.dart';
import 'package:polity/sidemenu.dart';
import 'package:polity/statspage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/stats': (context) => const StatsPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StatsPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: Text('Polity'),
      ),
      body: SafeArea(
          child: Row(
        children: [
          Expanded(flex: 5, child: Dashboard()),
        ],
      )),
    );
  }
}
