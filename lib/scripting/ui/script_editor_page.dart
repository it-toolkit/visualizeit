import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/scripting/action.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/ui/script_editor_widget.dart';
import 'package:visualizeit/common/ui/base_page.dart';

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
  final CodeScrollController codeScrollController = CodeScrollController();
  final CodeLineEditingController codeController = CodeLineEditingController();


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _resolveRawScript(),
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
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return _buildTextScriptEditorContent(context, rawScript!);
  }

  ButtonBar _buildButtonBar(BuildContext context) {
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

  Future<RawScript> _resolveRawScript() async {
    if(rawScript == null){
      rawScript = await widget._getRawScriptById(widget.scriptId);
      codeController.text = rawScript!.contentAsYaml;
    }
    script = widget._scriptParser.parse(rawScript!.contentAsYaml);

    return Future.value(rawScript);
  }

  Widget _buildTextScriptEditorContent(BuildContext context, RawScript rawScript) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScriptWidget(context, _buildButtonBar(context), rawScript.contentAsYaml),
      ],
    );
  }

  Expanded _buildScriptWidget(BuildContext context, ButtonBar buttonBar, String scriptContentAsYaml) {
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
