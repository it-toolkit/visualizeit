

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/extension/domain/default/show_banner.dart';

class BannerWidget extends StatefulWidget {

  final BannerModel model;

  BannerWidget(this.model);

  @override
  _BannerState createState() => _BannerState();
}

class _BannerState extends State<BannerWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Schedule the animation to start after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() {
    setState(() {
      _isVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var frameDuration = widget.model.timeFrame;

    final bannerContainer = frameDuration == Duration.zero
        ? buildBannerWidget(widget.model)
        : AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: (frameDuration.inMilliseconds / 3).round()),
            child: buildBannerWidget(widget.model),
          );

    return Positioned.fill(child: Align(alignment: parseAlignment(widget.model.alignment), child: bannerContainer));
  }

  Widget buildBannerWidget(BannerModel innerModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3)),
      ]),
      child: MarkdownBody(
        data: innerModel.message,
      ),
    );
  }

  Alignment parseAlignment(String alignment) {
    switch(alignment) {
      case "topLeft": return Alignment.topLeft;
      case "topCenter": return Alignment.topCenter;
      case "topRight": return Alignment.topRight;
      case "centerLeft": return Alignment.centerLeft;
      case "center": return Alignment.center;
      case "centerRight": return Alignment.centerRight;
      case "bottomLeft": return Alignment.bottomLeft;
      case "bottomCenter": return Alignment.bottomCenter;
      case "bottomRight": return Alignment.bottomRight;
      default: throw Exception("Unknown alignment value"); //TODO handle error properly
    }
  }
}