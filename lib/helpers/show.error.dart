import 'package:flutter/material.dart';

class ShowError extends StatefulWidget {
  final BuildContext context;

  ShowError({
    this.context
  });

  @override
  _ShowErrorState createState() => _ShowErrorState();
}

class _ShowErrorState extends State<ShowError> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150.0,
            child: Image.asset('assets/no-network.png')
          ),
          SizedBox(height: 15.0),
          Text('Bad Connection or Server Unreachable',
            style: TextStyle(
              fontSize: 16.0
            ),
          ),
          SizedBox(height: 10.0),
          GestureDetector(
            child: Text('Try Again',
              style: TextStyle(
                fontSize: 16.0,
                decoration: TextDecoration.underline
              ),
            ),
            onTap: () {
              setState((){});
            },
          ),
        ],
      ),
    );
  }
}