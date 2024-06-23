import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/scripting/domain/parser.dart';
import 'package:visualizeit/scripting/domain/script.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:visualizeit/scripting/ui/script_editor_widget.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/scripting/ui/script_errors_widget.dart';
import 'package:visualizeit_extensions/logging.dart';

final _logger = Logger("scripting.ui.script_editor_page");

class ScriptEditorPage extends StatefulBasePage {
  static const RouteName = "script-editor";

  const ScriptEditorPage(ScriptRepository scriptRepository, ScriptParser scriptParser, ExtensionRepository extensionRepository,
      {super.key, required this.scriptId, this.openScriptInPlayer, this.readOnly = false})
      : this._scriptRepository = scriptRepository,
        this._scriptParser = scriptParser,
        this._extensionRepository = extensionRepository,
        super(RouteName);

  final String scriptId;
  final bool readOnly;
  final Future<void> Function(String scriptRef, bool readonly)? openScriptInPlayer;

  final ScriptRepository _scriptRepository;
  final ScriptParser _scriptParser;
  final ExtensionRepository _extensionRepository;

  @override
  State<StatefulWidget> createState() {
    return ScriptEditorPageState();
  }
}

class ScriptEditorPageState extends BasePageState<ScriptEditorPage> {
  Script? script = null;
  bool scriptHasChanges = false;
  ParserException? scriptErrors = null;
  final CodeScrollController codeScrollController = CodeScrollController();
  final CodeLineEditingController codeController = CodeLineEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _resolveScript(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error loading script: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return Builder(builder: (context) => super.build(context));
          } else
            return CircularProgressIndicator();
        });
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "${script?.metadata.name ?? "Unknown script name"}${widget.readOnly ? " <read only>" : ""}",
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return _buildScriptWidget(context, _buildButtonBar(context), script!.raw.contentAsYaml);
  }

  ButtonBar _buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        Buttons.icon(Icons.cancel_outlined, "Discard changes",
            action: scriptHasChanges
                ? () => setState(() {
                      codeController.text = script!.raw.contentAsYaml;
                      scriptHasChanges = false;
                    })
                : null),
        Buttons.icon(Icons.save_outlined, "Save changes",
            action: scriptHasChanges
                ? () async {
                    var updatedRawScript = script!.raw.copyWith(contentAsYaml: codeController.text);
                    try {
                      final updateScript = await widget._scriptRepository.save(updatedRawScript);
                      setState(() {
                        script = updateScript;
                        scriptHasChanges = false;
                      });
                    } on ParserException catch (e) {
                      _logger.warn(() {
                        final buffer = StringBuffer("Save aborted due ${e.causes.length} errors: \n");
                        e.causes.forEach((error) {
                          final errorLocation = 'line ${error.span!.start.line + 1}, column ${error.span!.start.column + 1}';
                          buffer.writeln("\t${error.message} ($errorLocation)");
                        });
                        return buffer.toString();
                      });
                    }
                  }
                : null),
        Buttons.highlightedIcon(
          Icons.play_circle,
          "Play",
          action: () {
            //TODO ask for pending changes to save
            widget.openScriptInPlayer?.call(widget.scriptId, widget.readOnly);
          },
        )
      ],
    );
  }

  Future<Script> _resolveScript() async {
    if (script == null) {
      script = await widget._scriptRepository.get(widget.scriptId);
      codeController.text = script!.raw.contentAsYaml;
    }

    return Future.value(script);
  }

  Widget _buildScriptWidget(BuildContext context, ButtonBar buttonBar, String scriptContentAsYaml) {
    ScriptEditorWidget scriptEditorWidget = _buildScriptEditorWidget();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: scriptEditorWidget),
        if (scriptErrors != null) ScriptErrorWidget(scriptErrors),
        buttonBar,
      ],
    );
  }

  ScriptEditorWidget _buildScriptEditorWidget() {
    return ScriptEditorWidget(
      readOnly: widget.readOnly,
      controller: codeController,
      scrollController: codeScrollController,
      availableExtensions: widget._extensionRepository.getAll(),
      onCodeChange: _monitorScriptChangesAndErrors,
    );
  }

  void _monitorScriptChangesAndErrors(String text) {
    ParserException? newScriptErrors;
    try {
      widget._scriptParser.parse(RawScript("ref", text));
      _logger.trace(() => "Script syntax is correct");
      newScriptErrors = null;
    } on ParserException catch (e) {
      newScriptErrors = e;
    }
    final bool newErrors = newScriptErrors != scriptErrors;
    if (!scriptHasChanges) {
      setState(() {
        scriptHasChanges = true;
        scriptErrors = newScriptErrors;
      });
    } else if (newErrors) setState(() => scriptErrors = newScriptErrors);

    if (newErrors && newScriptErrors != null) _logErrorsFound(newScriptErrors);
  }

  void _logErrorsFound(ParserException? newScriptErrors) {
    _logger.trace(() {
      final buffer = StringBuffer("There are ${newScriptErrors!.causes.length} errors: \n");
      newScriptErrors.causes.forEach((error) {
        final errorLocation = 'line ${error.span!.start.line + 1}, column ${error.span!.start.column + 1}';
        buffer.writeln("\t${error.message} ($errorLocation)");
      });
      return buffer.toString();
    });
  }
}
