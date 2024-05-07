import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:visualizeit/common/ui/base_page.dart';

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
    return FutureBuilder(
      future: _helpAsMarkdownString,
      builder: (BuildContext context, AsyncSnapshot<String> doc) {
        if (doc.hasData) {
          return MarkdownWidget(data: doc.data ?? 'Help was not found');
        } else if (doc.hasError) {
          return const Text("Error loading help");
        } else {
          return const Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()));
        }
      },
    );
  }

  static Future<String> readHelpMarkdownDoc() async {
    return await rootBundle.loadString('assets/docs/help.md');
  }
}
