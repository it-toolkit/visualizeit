import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/widget/all.dart';
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
  final Future<String> _helpAsMarkdownString = readHelpMarkdownDoc();

  @override
  Widget buildBody(BuildContext context) {
    return WidgetFutureUtils.awaitAndBuild<String>(
      future: _helpAsMarkdownString,
      builder: (BuildContext context, String doc) => MarkdownWidget(data: doc),
    );
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => customBarWithModeSwitch("Help");

  static Future<String> readHelpMarkdownDoc() async {
    return await rootBundle.loadString('assets/docs/help.md');
  }
}
