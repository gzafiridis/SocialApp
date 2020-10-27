import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading...',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: 22),
              ),
              Container(height: 20.0,),
              CircularProgressIndicator(),
            ],
          ),
        ));
  }
}
