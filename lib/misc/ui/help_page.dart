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

  @override
  Widget buildBody(BuildContext context) {
    return WidgetFutureUtils.awaitAndBuild<String>(
      future: readHelpMarkdownDoc(context),
      builder: (BuildContext context, String doc) => MarkdownWidget(data: doc),
    );
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => customBarWithModeSwitch("Help");

  Future<String> readHelpMarkdownDoc(BuildContext context) async {
    return await DefaultAssetBundle.of(context).loadString('assets/docs/help.md');
  }
}
