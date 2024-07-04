import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:visualizeit/common/ui/buttons.dart';
import 'package:visualizeit/common/ui/custom_bar_widget.dart';
import 'package:visualizeit/common/ui/future_builder.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
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
  Set<String> referencedExtensionIds = { DefaultExtensionConsts.Id };
  final CodeScrollController codeScrollController = CodeScrollController();
  final CodeLineEditingController codeController = CodeLineEditingController();

  @override
  Widget build(BuildContext context) {
    return WidgetFutureUtils.awaitAndBuild<Script>(
      future: _resolveScript(),
      builder: (context, snapshot) => super.build(context),
    );
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    return customBarWithModeSwitch(
      "${script?.metadata.name ?? "Unknown script name"}",
      titleAction:  widget.readOnly ? TitleAction(Icons.edit_off_outlined, null, tooltip: "Read only script"): null,
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
            action: scriptHasChanges && scriptErrors == null
                ? () async {
                    var updatedRawScript = script!.raw.copyWith(contentAsYaml: codeController.text);
                    final parsedScript = widget._scriptParser.parse(script!.raw.copyWith(contentAsYaml: codeController.text));
                    if (parsedScript is InvalidScript) throw parsedScript.parserError;

                    try {
                      final updateScript = await widget._scriptRepository.save(updatedRawScript);
                      setState(() {
                        script = updateScript;
                        scriptHasChanges = false;
                      });
                    } on ParserException catch (e) {
                      _logger.warn(() {
                        final buffer = StringBuffer("Save aborted due ${e.causes.length} errors: \n");
                        e.errorMessages.forEach((errorMessage) => buffer.writeln("\t$errorMessage"));
                        return buffer.toString();
                      });
                    }
                  }
                : null),
        Buttons.highlightedIcon(
          Icons.play_circle,
          "Play",
          action: !scriptHasChanges && scriptErrors == null
              ? () => widget.openScriptInPlayer?.call(widget.scriptId, widget.readOnly)
              : null,
        )
      ],
    );
  }

  Future<Script> _resolveScript() async {
    if (script == null) {
      var loadedScript = await widget._scriptRepository.get(widget.scriptId);
      script = loadedScript;
      codeController.text = loadedScript.raw.contentAsYaml;
      scriptErrors = loadedScript is InvalidScript ? loadedScript.parserError : null;
    }

    return Future.value(script);
  }

  Widget _buildScriptWidget(BuildContext context, ButtonBar buttonBar, String scriptContentAsYaml) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildScriptEditorWidget()),
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
      referencedExtensionIds: referencedExtensionIds,
      availableExtensions: widget._extensionRepository.getAll(),
      onCodeChange: _monitorScriptChangesAndErrors,
    );
  }

  Set<String> _resolveReferencedExtensionIds(ValidScript script) {
    Set<String> referencedExtensionIds = { DefaultExtensionConsts.Id };
    referencedExtensionIds.addAll(script.scenes.expand((element) => element.metadata.extensionIds));
    return referencedExtensionIds;
  }

  void _monitorScriptChangesAndErrors(String text) {
    ParserException? newScriptErrors;
    Set<String>? referencedExtensionIds;
    try {
      final parsedScript = widget._scriptParser.parse(RawScript("ref", text));  //TODO avoid throwing exception
      if (parsedScript is InvalidScript) throw parsedScript.parserError;

      _logger.trace(() => "Script syntax is correct");
      referencedExtensionIds = _resolveReferencedExtensionIds(parsedScript as ValidScript);
      newScriptErrors = null;
    } on ParserException catch (e) {
      newScriptErrors = e;
    }
    final bool newErrors = newScriptErrors != scriptErrors;
    final bool newExtensions = !setEquals(referencedExtensionIds, this.referencedExtensionIds);
    if (!scriptHasChanges) {
      setState(() {
        scriptHasChanges = true;
        scriptErrors = newScriptErrors;
      });
    } else if (newErrors || newExtensions) setState(() {
      scriptErrors = newScriptErrors;
      this.referencedExtensionIds = referencedExtensionIds ?? this.referencedExtensionIds;
    });

    if (newErrors && newScriptErrors != null) _logErrorsFound(newScriptErrors);
  }

  void _logErrorsFound(ParserException? newScriptErrors) {
    _logger.trace(() {
      final buffer = StringBuffer("There are ${newScriptErrors!.causes.length} errors: \n");
      newScriptErrors.errorMessages.forEach((errorMessage) => buffer.writeln("\t$errorMessage"));
      return buffer.toString();
    });
  }
}
