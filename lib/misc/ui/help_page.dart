import 'package:flutter/material.dart';
import 'package:markdown_widget/config/toc.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:visualizeit/common/markdown/markdown.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/ui/future_builder.dart';

class HelpPage extends StatefulBasePage {
  static const RouteName = "help";

  const HelpPage({super.key}): super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return HelpPageState();
  }
}

class HelpPageState extends BasePageState<HelpPage> {

  TocController? _tocController;
  bool _showTableOfContents = true;

  @override
  void dispose() {
    _tocController?.dispose();
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return WidgetFutureUtils.awaitAndBuild<String>(
      future: readHelpMarkdownDoc(context),
      builder: (BuildContext context, String doc) {
        final markdownWidget = ExtendedMarkdownWidget(data: doc, tocController: _tocController);

        if (_showTableOfContents) {
          return Row(
            children: <Widget>[
              LimitedBox(maxWidth: 200, child: _buildTocWidget()),
              Expanded(child: markdownWidget)
            ],
          );
        } else return markdownWidget;
      },
    );
  }

  TocWidget _buildTocWidget() {
    return TocWidget(controller: _tocController!,
              itemBuilder: (data) => TocItemWidget(
                toc: data.toc,
                isCurrent: data.index == data.currentIndex,
                onTap: () {
                  _tocController!.jumpToIndex(data.toc.widgetIndex);
                  data.refreshIndexCallback(data.index);
                },
              )
    );
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => customBarWithModeSwitch(
      "Help",
      modeSwitch: ModeSwitch(
          initialState: _showTableOfContents,
          enabledModeName: "Show index",
          disabledModeName: "Show index",
          onModeChanged: (mode) => setState(() => _showTableOfContents = mode)
      )
  );

  Future<String> readHelpMarkdownDoc(BuildContext context) async {
    _tocController?.dispose();
    _tocController = TocController();

    return await DefaultAssetBundle.of(context).loadString('assets/docs/help.md');
  }
}


class TocItemWidget extends StatelessWidget {
  const TocItemWidget({Key? key, this.isCurrent = false, required this.toc, this.onTap, this.fontSize = 14.0}) : super(key: key);

  final bool isCurrent;
  final Toc toc;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return getNodeWidget(toc, context);
  }

  Widget getNodeWidget(Toc toc, BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final tag = toc.node.headingConfig.tag;
    final level = _tag2Level[tag] ?? 1;
    var textStyle = isCurrent ? TextStyle(color: color, fontSize: fontSize) : TextStyle(fontSize: fontSize, color: null);
    var tocHeadingConfig = _TocHeadingConfig(textStyle, tag);
    final node = toc.node.copy(headingConfig: tocHeadingConfig);

    return InkWell(
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0 * level, 4, 4, 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ProxyRichText(node.build()),
      ),
      onTap: () { if (!isCurrent) onTap?.call(); },
    );
  }
}

///every heading tag has a special level
final _tag2Level = <String, int>{
  'h1': 1,
  'h2': 2,
  'h3': 3,
  'h4': 5,
  'h5': 5,
  'h6': 6,
};

class _TocHeadingConfig extends HeadingConfig {
  final TextStyle style;
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}