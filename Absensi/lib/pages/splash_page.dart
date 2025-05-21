import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/utils.dart';


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Utils.mainThemeColor,
      body: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            'assets/smanic.png',
            width: MediaQuery.of(context).size.width * 0.5,
            filterQuality: FilterQuality.high,
          ),
        ),
        ],
      ),
      ),
    );
  }
}