import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityService extends StatefulWidget {
  ConnectivityService({
    this.widget
  });
  final Widget widget;
  @override
  _ConnectivityServiceState createState() => _ConnectivityServiceState();
}

class _ConnectivityServiceState extends State<ConnectivityService> {
  ConnectivityResult connectionStatus;
  Connectivity connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    initConnectivity();
    connectivitySubscription = connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  } 

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }
    return updateConnectionStatus(result);
  }
   Future<void> updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => connectionStatus = result);
      break;
      case ConnectivityResult.mobile:
        setState(() => connectionStatus = result);
      break;
      case ConnectivityResult.none:
        setState(() => connectionStatus = result);
      break;
      default:
    }
  }
  Widget showError() {
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
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return connectionStatus == ConnectivityResult.none ? showError() : widget.widget; 
  }
}