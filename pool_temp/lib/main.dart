import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'thermometer_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pool Temperature',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String temp = '';
  String serverStatus = '';

  void getPoolTemp() async {
    setState(() {
      serverStatus = 'Verbinde...';
    });
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:5000/poolTemp'));
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        temp = decoded['tC'];
        serverStatus = 'Verbunden';
      });
    } catch (e) {
      setState(() {
        temp = '0.0';
        serverStatus = 'Server Offline';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getPoolTemp();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Center(
            child: CustomPaint(
              foregroundPainter: CircleProgress(double.parse(temp), true),
              child: Container(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Temperatur'),
                      Text(
                        '$temp',
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
              child: Column(
            children: [
              Text('Server Status:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              serverStatus == 'Verbunden'
                  ? Text(serverStatus,
                      style: TextStyle(fontSize: 20, color: Colors.green))
                  : Text(serverStatus,
                      style: TextStyle(fontSize: 20, color: Colors.red))
            ],
          ))
        ]),
      ),
    );
  }
}
