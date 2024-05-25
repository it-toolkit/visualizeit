import 'package:flutter/material.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/ui/tags_widget.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/fake_data.dart';
import 'package:visualizeit/scripting/action.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/ui/script_editor_widget.dart';

import '../../common/ui/base_page.dart';

class ScriptEditorPage extends StatefulBasePage {
  static const RouteName = "script-editor";

  const ScriptEditorPage(GetRawScriptById getRawScriptById, ScriptParser scriptParser, ExtensionRepository extensionRepository,
      {super.key, required this.scriptId, this.onPlayPressed}) :
      this._getRawScriptById = getRawScriptById,
      this._scriptParser = scriptParser,
      this._extensionRepository = extensionRepository,
      super(RouteName);

  final String scriptId;
  final Function(String)? onPlayPressed;

  final GetRawScriptById _getRawScriptById;
  final ScriptParser _scriptParser;
  final ExtensionRepository _extensionRepository;

  @override
  State<StatefulWidget> createState() {
    return ScriptEditorPageState();
  }
}

class ScriptEditorPageState extends BasePageState<ScriptEditorPage> {
  bool graphicalMode = false;

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    //TODO use script repository
    return customBarWithModeSwitch(
        // "> ${fakeScriptNames[int.tryParse(widget.scriptId) ?? 0]}",
        "> ${fakeScriptNames[0]}",
        (bool it) => {
              debugPrint("Mode updated: $it"),
              setState(() {
                graphicalMode = it;
              })
            },
        (bool it) => it ? "GUI" : "Text",
        titleActionIcon: Icons.edit, onTitleActionIconPressed: () {
      debugPrint("perform title edit");
    });
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
        ElevatedButton(
            onPressed: () {
              widget.onPlayPressed?.call(widget.scriptId);
            },
            child: const Text("Play")),
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
        buildScriptWidget(context, buildButtonBar(context), fakeFullScriptExample),
      ],
    );
  }

  Widget buildDetails(BuildContext context) {
    return AdaptiveContainerWidget(children: [
      buildScenesList(),
      const Spacer(flex: 2),
      buildScriptWidget(context, buildButtonBar(context), fakeSceneScriptExample),
    ]);
  }

  Widget buildDescriptionRow(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text("Details"),
      Container(
        constraints: const BoxConstraints(maxHeight: 80),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: SingleChildScrollView(
          child: Text(fakeSelectedScriptDetails, style: const TextStyle(fontSize: 14)),
        ),
      )
    ]);
  }

  Expanded buildScenesList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scenes"),
            Expanded(
                child: Container(
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: ReorderableListView.builder(
                physics: const ClampingScrollPhysics(),
                onReorder: (int oldIndex, int newIndex) => {},
                buildDefaultDragHandles: false,
                itemCount: fakeScenes.length,
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
                            Text(
                              fakeScenes[index],
                              textAlign: TextAlign.center,
                            ),
                          ])));
                },
              ),
            )),
          ],
        ));
  }

  Expanded buildScriptWidget(BuildContext context, ButtonBar buttonBar, String sampleText) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Scene 1 script"),
            Expanded(
              child: ScriptEditorWidget(script: sampleText, availableExtensions: widget._extensionRepository.getAll()),
            ),
            buttonBar
          ],
        ));
  }
}
