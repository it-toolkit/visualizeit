import 'package:flutter/material.dart';
import 'package:visualizeit/pages/adaptive_container.dart';
import 'package:visualizeit/pages/custom_bar.dart';
import 'package:visualizeit/pages/tags.dart';

import 'base_page.dart';

class ScriptEditorPage extends StatefulBasePage {
  const ScriptEditorPage({super.key, required this.scriptId, super.onSignInPressed, super.onHelpPressed, super.onExtensionsPressed});

  final String scriptId;

  @override
  State<StatefulWidget> createState() {
    return ScriptEditorPageState();
  }
}


class ScriptEditorPageState extends BasePageState<ScriptEditorPage> {

  bool graphicalMode = true;

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "> ${widget.scriptId}",
      (bool it) => {
        debugPrint("Mode updated: $it"),
        setState(() {
          graphicalMode = it;
        })
      },
      (bool it) => it ? "GUI" : "Text",
        titleActionIcon: Icons.edit,
      onTitleActionIconPressed: () { debugPrint("perform title edit"); }
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return graphicalMode ? buildGraphicalScriptEditorContent(context) : buildTextScriptEditorContent(context);
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {}, child: const Text("Delete")),
        TextButton(onPressed: () => {}, child: const Text("Edit")),
        ElevatedButton(onPressed: () => {}, child: const Text("Play")),
      ],
    );
  }

  Widget buildGraphicalScriptEditorContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TagsWidget(),
        buildDescriptionRow(context),
        const SizedBox(height: 20),
        buildDetails(context),
      ],
    );
  }

  Widget buildTextScriptEditorContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildScriptWidget(context, buildButtonBar(context), scriptExample),
      ],
    );
  }

  Widget buildDetails(BuildContext context) {
    return AdaptiveContainer(children: [
      buildScriptsList(),
      const Spacer(flex: 2),
      buildScriptWidget(context, buildButtonBar(context), sceneExample),
    ]);
  }

  Widget buildDescriptionRow(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(maxHeight: 100),
        child: const SingleChildScrollView(
            child: TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(labelText: "Description", hintText: '...'),
          maxLines: null,
        )));
  }

  Expanded buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scenes"),
            Expanded(
                child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(171, 197, 212, 0.3), borderRadius: BorderRadius.all(Radius.circular(10))),
              child: ReorderableListView.builder(
                physics: const ClampingScrollPhysics(),
                onReorder: (int oldIndex, int newIndex) => {},
                buildDefaultDragHandles: false,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return ReorderableDragStartListener(
                      index: index,
                      key: Key("scene-list-$index"),
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: index == 0 ? Colors.lightBlue : Colors.white, //TODO replace with model selected value
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(blurRadius: 5),
                              ]),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Row(children: [const Icon(Icons.drag_indicator), Text('Scene ${index + 1}')]),
                            const Text(
                              'Scene description\nin two lines...',
                              textAlign: TextAlign.center,
                            ),
                          ])));
                },
              ),
            )),
          ],
        ));
  }

  //TODO replace with Script widget from scripting module
  Expanded buildScriptWidget(BuildContext context, ButtonBar buttonBar, String sampleText) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scene 1 script"),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 197, 212, 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Text(sampleText),
                  ),
                ),
              ),
            ),
            buttonBar
          ],
        ));
  }

  static const sceneExample = """
fixture
    btree TD
      # nodeId(/parentNodeId)? : level : (value(->childNodeId)?)(,value(->childNodeId)?)+
      P1 : 2 : 1 -> P1.1, 7 -> P1.2
      P1.1/P1 : 1 : 1 -> P1.1.1, 3 -> P1.1.2, 5 -> P1.1.3
      P1.2/P1 : 1 : 7 -> P1.2.1, 9 -> P1.2.2
      P1.1.1/P1.1 : 0 : 1,2
      P1.1.2/P1.1 : 0 : 3,4
      P1.1.3/P1.2 : 0 : 5,6
      P1.2.1/P1.2 : 0 : 7,8
      P1.2.2/P1.3 : 0 : 9,10,11,12
transitions
    Add node value 13 (1s)
    Add node value 14 (1s)
    Delete node value 13
""";

  static const scriptExample = """
scene A
    description: B+ Tree values manipulation
    tags: data-structure, tree
    fixture
        btree TD
          # nodeId(/parentNodeId)? : level : (value(->childNodeId)?)(,value(->childNodeId)?)+
          P1 : 2 : 1 -> P1.1, 7 -> P1.2
          P1.1/P1 : 1 : 1 -> P1.1.1, 3 -> P1.1.2, 5 -> P1.1.3
          P1.2/P1 : 1 : 7 -> P1.2.1, 9 -> P1.2.2
          P1.1.1/P1.1 : 0 : 1,2
          P1.1.2/P1.1 : 0 : 3,4
          P1.1.3/P1.2 : 0 : 5,6
          P1.2.1/P1.2 : 0 : 7,8
          P1.2.2/P1.3 : 0 : 9,10,11,12
    transitions
        Add node value 13 (1s)
        Add node value 14 (1s)
        Delete node value 13
""";
}

