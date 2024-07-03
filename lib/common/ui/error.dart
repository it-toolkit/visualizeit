import 'package:flutter/material.dart';
import 'package:visualizeit/common/ui/base_page.dart';

class VisualizeItErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  VisualizeItErrorWidget(this.errorDetails);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var screenSize = MediaQuery.of(context).size;
      if (screenSize.width > constraints.maxWidth || screenSize.height > constraints.maxHeight) {
        return LimitedBox(maxWidth: screenSize.width, maxHeight: screenSize.height, child: RenderingErrorWidget(errorDetails));
      }else if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
        return LimitedBox(maxWidth: screenSize.width / 3, maxHeight: screenSize.height / 3, child: RenderingErrorWidget(errorDetails));
      }else {
        return LimitedBox(maxWidth: screenSize.width, maxHeight: screenSize.height, child: ErrorPage(errorDetails));
      }
    });
  }
}

class RenderingErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  RenderingErrorWidget(this.errorDetails);

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Container(color: Colors.yellow.shade200),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50.0),
          SizedBox(height: 10.0),
          Text('An unexpected error occurred!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.0),
          Text(errorDetails.exceptionAsString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0)),
        ],
      )
    ]);
  }
}


class ErrorPage extends StatelessBasePage {
  final FlutterErrorDetails errorDetails;

  ErrorPage(this.errorDetails);

  @override
  Widget buildBody(BuildContext context) => RenderingErrorWidget(errorDetails);
}