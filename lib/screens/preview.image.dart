import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_complete_guide/constants/url.dart';

class PreviewImageScreen extends StatefulWidget {
  PreviewImageScreen({this.body});
  final String body;


  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }
   @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: '$imagesStepsUrl/${widget.body}',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          )
        ),
      )
    );
  }
}