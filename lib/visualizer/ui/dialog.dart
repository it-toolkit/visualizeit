import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

abstract class InformationDialog {
  static void show(BuildContext context, void onClose(), {String? title, required String message}) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation)
          => _buildDialog(context, title, message, onClose),
    );
  }

  static ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
      side: BorderSide(color: Colors.black),
    );
  }

  static _getTitleText(context, String? text) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
        child: Container(
            alignment: FractionalOffset.topLeft,
            child: text != null ? Text(text) : Icon(Icons.info_outline, color: Colors.grey),
        )
    );
  }

  static _getCloseButton(context, void onClose()) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
      // child: GestureDetector(
      //   onTap: () {},
      child: Container(
        alignment: FractionalOffset.topRight,
        child: GestureDetector(
          child: Icon(Icons.clear, color: Colors.black),
          onTap: onClose,
        ),
        //   ),
      ),
    );
  }

  static Widget _buildDialog(context, String? title, String message, void onClose()) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: _defaultShape(),
      insetPadding: EdgeInsets.all(8),
      elevation: 10,
      titlePadding: const EdgeInsets.all(0.0),
      title: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_getTitleText(context, title), _getCloseButton(context, onClose)],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Center(child: MarkdownBlock(data: message)),
              )
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.all(8),
    );
  }
}
