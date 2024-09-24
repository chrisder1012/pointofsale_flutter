import 'dart:async';

import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    routeUrl(); // TODO: implement initState
    super.initState();
  }

  routeUrl() async {
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context, true);
      // return Navigator.popUntil(
      // context, ModalRoute.withName(Navigator));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
