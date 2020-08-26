import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreviewImageScreen extends StatefulWidget {
  PreviewImageScreen({
    this.url,
    this.body
  });
  final String url;
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
              imageUrl: '${widget.url}/${widget.body}',
              placeholder: (context, url) => Image.asset('assets/default-avatar.png'),
              errorWidget: (context, url, error) => Image.asset('assets/default-avatar.png'),
            ),
          )
        ),
      )
    );
  }
}