import 'dart:async';

import 'package:chumbucket_recipes/helpers/show.error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityService extends StatefulWidget {
  ConnectivityService({
    this.widget,
    this.refresh
  });
  final Function refresh;
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

  Widget build(BuildContext context) {
    return connectionStatus == ConnectivityResult.none ? ShowError(notifyParent: widget.refresh) : widget.widget; 
  }
}