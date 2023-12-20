import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/common/ui/tags_widget.dart';

import '../../common/ui/adaptive_container_widget.dart';
import '../../fake_data.dart';

class ScriptSelectorPage extends BasePage {
  /// Constructs a [ScriptSelectorPage]
  const ScriptSelectorPage(
      {super.key, this.onPlayPressed, this.onViewPressed, super.onSignInPressed, super.onHelpPressed, super.onExtensionsPressed});

  final Function(String)? onPlayPressed;
  final Function(String)? onViewPressed;

  @override
  buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.grey),
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[Colors.lightBlue, Colors.lightGreenAccent]),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: const TabBar(
                tabs: [
                  Tab(child: Text("Public scripts", softWrap: true, textAlign: TextAlign.center)),
                  Tab(child: Text("My scripts", softWrap: true, textAlign: TextAlign.center)),
                  Tab(child: Text("Shared with me", softWrap: true, textAlign: TextAlign.center))
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              buildTabContent(context, buildButtonBar(context)),
              _isUserLoggedIn() ? buildTabContent(context, buildMyScriptsButtonBar(context)) : buildLoginRequiredTabContent(context),
              _isUserLoggedIn() ? buildTabContent(context, buildButtonBar(context)) : buildLoginRequiredTabContent(context),
            ],
          ),
        ),
      ),
    );
  }

  bool _isUserLoggedIn() => false; //TODO

  Widget buildTabContent(BuildContext context, ButtonBar scriptButtonBar) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(),
      children: [buildScriptsList(), const Spacer(flex: 2), buildDetailsSection(context, scriptButtonBar)],
    );
  }

  Expanded buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text("Scripts"),
              Spacer(),
              IconButton(onPressed: null, icon: Icon(Icons.add_circle_outline), tooltip: "Create script", iconSize: 20),
              IconButton(onPressed: null, icon: Icon(Icons.compare_arrows), tooltip: "Import scripts", iconSize: 20),
              IconButton(onPressed: null, icon: Icon(Icons.import_export), tooltip: "Export scripts", iconSize: 20),
            ]),
            Expanded(
                child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(171, 197, 212, 0.3), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: ListView.builder(
                itemExtent: 25,
                itemCount: fakeScriptNames.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    dense: true,
                    title: Text('- ${fakeScriptNames[index]}'), //TODO replace with model selected value
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
        child: const Wrap(
          spacing: 15,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 40,
              child: TextField(
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search scripts...')),
            ),
            TagsWidget(),
          ],
        ));
  }

  Expanded buildDetailsSection(BuildContext context, ButtonBar buttonBar) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 40,
              child: Align(alignment: Alignment.centerLeft, child: Text("Script details")),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 197, 212, 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(physics: const ClampingScrollPhysics(), child: MarkdownBody(data: fakeSelectedScriptDetails)),
              ),
            ),
            buttonBar
          ],
        ));
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {onViewPressed?.call(fakeSelectedScriptId)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {onPlayPressed?.call(fakeSelectedScriptId)}, child: const Text("Play")),
      ],
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "delete the script")}, child: const Text("Delete")),
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {onViewPressed?.call(fakeSelectedScriptId)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {onPlayPressed?.call(fakeSelectedScriptId)}, child: const Text("Play")),
      ],
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, String actionDescription) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('...'),
          content: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ListBody(
              children: <Widget>[
                Text('Would you like to $actionDescription?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  buildLoginRequiredTabContent(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 36,
              color: Colors.blue.shade300,
            ),
            const Text("Login required")
          ],
        ));
  }
}
