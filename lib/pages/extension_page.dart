
import 'package:flutter/material.dart';
import 'package:visualizeit/pages/base_page.dart';

import 'adaptive_container.dart';

class ExtensionPage extends BasePage {
  const ExtensionPage({super.key, super.onHelpPressed});

  @override
  Widget buildBody(BuildContext context) {
    return AdaptiveContainer(
      header: buildSearchBar(),
      children: [
        buildScriptsList(),
        const Spacer(flex: 2),
        buildDetailsSection(context)
      ],
    );
  }

  Expanded buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Extensions"),
            Expanded(
                child: Container(
                  decoration:
                  const BoxDecoration(color: Color.fromRGBO(171, 197, 212, 0.3), borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: ListView.builder(
                    itemExtent: 25,
                    itemCount: 10,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        title: Text('- Dummy extension ${index + 1}'), //TODO replace with model selected value
                        selected: index == 0,
                      );
                    },
                  ),
                )),
          ],
        ));
  }

  Widget buildSearchBar() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: const Align(
          alignment: Alignment.centerLeft,
          child:
            SizedBox(
              width: 200,
              height: 40,
              child: TextField(
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search extensions...')),
            ),
        ));
  }

  Expanded buildDetailsSection(BuildContext context) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Details"),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 197, 212, 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Text(extensionDocsExample)),
              ),
            ),
          ],
        ));
  }

  static const extensionDocsExample = """
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
""";
}