import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:visualizeit/common/ui/adaptive_container_widget.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/ui/tags_widget.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/fake_data.dart';
import 'package:visualizeit/scripting/action.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/ui/script_editor_widget.dart';

import '../../common/ui/base_page.dart';

class ScriptEditorPage extends StatefulBasePage {
  static const RouteName = "script-editor";

  const ScriptEditorPage(
      GetRawScriptById getRawScriptById,
      ScriptParser scriptParser,
      ExtensionRepository extensionRepository,
      {super.key, required this.scriptId, this.openScriptInPlayer, this.readOnly = false}) :
      this._getRawScriptById = getRawScriptById,
      this._scriptParser = scriptParser,
      this._extensionRepository = extensionRepository,
      super(RouteName);

  final String scriptId;
  final bool readOnly;
  final Future<void> Function(String scriptRef, bool readonly)? openScriptInPlayer;

  final GetRawScriptById _getRawScriptById;
  final ScriptParser _scriptParser;
  final ExtensionRepository _extensionRepository;

  @override
  State<StatefulWidget> createState() {
    return ScriptEditorPageState();
  }
}

class ScriptEditorPageState extends BasePageState<ScriptEditorPage> {

  RawScript? rawScript = null;
  Script? script = null;
  bool scriptHasChanges = false;
  bool graphicalMode = false;
  final CodeScrollController codeScrollController = CodeScrollController();
  final CodeLineEditingController codeController = CodeLineEditingController();


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: resolveRawScript(),
        builder: (context, snapshot) {
          if(snapshot.hasError) { //TODO
            return Text("Error loading script: ${snapshot.error}");
          }else if (snapshot.hasData) {
            return Builder(builder: (context) => super.build(context));
          } else
            return CircularProgressIndicator();
        });
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "${script?.metadata.name ?? "Unknown script name"}${ widget.readOnly ? " <read only>": ""}",
      // modeSwitch: ModeSwitch(
      //   initialState: false,
      //   enabledModeName: "GUI",
      //   disabledModeName: "Text",
      //   onModeChanged: (bool it) => setState(() => graphicalMode = it),
      // ),
      // titleAction: TitleAction(Icons.edit, () { debugPrint("perform title edit"); })
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return graphicalMode
        ? buildGraphicalScriptEditorContent(context)
        : buildTextScriptEditorContent(context, rawScript!);
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        Buttons.icon(Icons.cancel_outlined, "Discard changes", action: scriptHasChanges ? () => setState(() {
          codeController.text = rawScript!.contentAsYaml;
          scriptHasChanges = false;
        }) : null),
        Buttons.icon(Icons.save_outlined, "Save changes", action: scriptHasChanges ? () {
          setState(() {
            rawScript!.contentAsYaml = codeController.text;
            script = widget._scriptParser.parse(codeController.text);
            scriptHasChanges = false;
          });
        } : null),
        Buttons.highlightedIcon(
            Icons.play_circle,
            "Play",
            action: () {
              //TODO ask for pending changes
              widget.openScriptInPlayer?.call(widget.scriptId, widget.readOnly);
            },
        )
      ],
    );
  }

  Future<RawScript> resolveRawScript() async {
    if(rawScript == null){
      rawScript = await widget._getRawScriptById(widget.scriptId);
      codeController.text = rawScript!.contentAsYaml;
    }
    script = widget._scriptParser.parse(rawScript!.contentAsYaml);

    return Future.value(rawScript);
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

  Widget buildTextScriptEditorContent(BuildContext context, RawScript rawScript) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildScriptWidget(context, buildButtonBar(context), rawScript.contentAsYaml),
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

  Expanded buildScriptWidget(BuildContext context, ButtonBar buttonBar, String scriptContentAsYaml) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ScriptEditorWidget(
                readOnly: widget.readOnly,
                controller: codeController,
                scrollController: codeScrollController,
                availableExtensions: widget._extensionRepository.getAll(),
                onCodeChange: (String text ) {
                  if (!scriptHasChanges) setState(() {
                    scriptHasChanges = true;
                  });
                },
              ),
            ),
            buttonBar
          ],
        ));
  }
}
