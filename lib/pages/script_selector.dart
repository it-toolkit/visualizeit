
import 'package:flutter/material.dart';
import 'package:visualizeit/pages/base_page.dart';

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
            preferredSize:  const Size.fromHeight(40.0),
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[Colors.lightBlue, Colors.lightGreenAccent]),
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
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
              buildTabContent(context, buildMyScriptsButtonBar(context)),
              buildTabContent(context, buildButtonBar(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabContent(BuildContext context, ButtonBar scriptButtonBar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSearchBar(),
        const SizedBox(height: 20),
        (MediaQuery.sizeOf(context).width >= 600)
            ? Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                buildScriptsList(),
                const Spacer(flex: 2),
                buildDetailsSection(context, scriptButtonBar),
              ]))
            : Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                buildScriptsList(),
                const Spacer(flex: 2),
                buildDetailsSection(context, scriptButtonBar),
              ]))
      ],
    );
  }

  Expanded buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scripts"),
            Expanded(
                child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(171, 197, 212, 0.3), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: ListView.builder(
                itemCount: 5,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    dense: true,
                    title: Text('Test script ${index + 1}'), //TODO replace with model selected value
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
        child: Wrap(
          spacing: 15,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(
              width: 200,
              height: 40,
              child: TextField(
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search scripts...')),
            ),
            Chip(
              label: const Text("data", style: TextStyle(fontSize: 10)),
              onDeleted: () => {},
            ),
          ],
        ));
  }

  Expanded buildDetailsSection(BuildContext context, ButtonBar buttonBar) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Script details"),
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(171, 197, 212, 0.3),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Text(scriptDetailsExample)),
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
        TextButton(onPressed: () => {onViewPressed?.call("Test script 1 with long message")}, child: const Text("View")),
        ElevatedButton(onPressed: () => {onPlayPressed?.call("Test script 1")}, child: const Text("Play")),
      ],
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "delete the script")}, child: const Text("Delete")),
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {onViewPressed?.call("Test script 1")}, child: const Text("View")),
        ElevatedButton(onPressed: () => {onPlayPressed?.call("Test script 1")}, child: const Text("Play")),
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


  static const scriptDetailsExample = """
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum  
""";
}
