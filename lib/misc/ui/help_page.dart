import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/common/ui/base_page.dart';

class HelpPage extends StatefulBasePage {
  const HelpPage({super.key, super.onHelpPressed});

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
          return Markdown(data: doc.data ?? 'Help was not found');
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