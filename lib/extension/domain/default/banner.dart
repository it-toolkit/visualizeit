

import 'package:flutter/material.dart';
import 'package:visualizeit/common/markdown/markdown.dart';
import 'package:visualizeit/extension/domain/default/show_banner.dart';
import 'package:visualizeit_extensions/visualizer.dart';

class BannerWidget extends StatefulWidget with RenderingPriority {

  final BannerModel model;

  BannerWidget(this.model) {
    initPriority(RenderingPriority.maxPriority);
  }

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
    var alignment = widget.model.alignment;

    final bannerContainer = frameDuration == Duration.zero
        ? buildBannerWidget(widget.model, alignment)
        : AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: (frameDuration.inMilliseconds / 3).round()),
            child: buildBannerWidget(widget.model, alignment),
          );


    return Positioned.fill(child: Align(alignment: alignment, child: bannerContainer));
  }

  Widget buildBannerWidget(BannerModel innerModel, Alignment alignment) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3)),
      ]),
      child: innerModel.adjustSize
          ? ExtendedMarkdownBlock(data: innerModel.message)
          : FractionallySizedBox(
              widthFactor: alignment == Alignment.center ? 0.75 : 1 - alignment.x.abs() * 0.75,
              heightFactor: alignment == Alignment.center ? 0.75 : 1 - alignment.y.abs() * 0.75,
              child: SingleChildScrollView(child: ExtendedMarkdownBlock(data: innerModel.message)),
          ),
    );
  }
}