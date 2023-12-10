import 'package:flutter/cupertino.dart';

class AdaptiveContainer extends StatelessWidget {
  const AdaptiveContainer({super.key, this.header, required this.children, this.wrapWidth = 600});

  final Widget? header;
  final List<Widget> children;
  final int wrapWidth;

  @override
  Widget build(BuildContext context) {
    return header != null
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [header!, const SizedBox(height: 20), buildBody(context)])
        : buildBody(context);
  }

  Expanded buildBody(BuildContext context) {
    return (MediaQuery.sizeOf(context).width >= wrapWidth)
        ? Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))
        : Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
  }
}
