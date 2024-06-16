import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit_extensions/extension.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/scripting.dart';
import 'package:visualizeit/player/domain/player.dart';

final _logger = Logger("scripting.ui.script_editor_widget");

class ScriptEditorWidget extends StatelessWidget {
  ScriptEditorWidget({
    super.key,
    String? script,
    CodeLineEditingController? controller,
    CodeScrollController? scrollController,
    required this.onCodeChange,
    this.availableExtensions = const [],
    this.listenPlayerEvents = false,
    this.readOnly = false
  }) :
    this.scrollController = scrollController ?? CodeScrollController(),
    this.controller = controller ?? CodeLineEditingController.fromText(script);

  final CodeLineEditingController controller;
  final CodeScrollController scrollController;
  final List<Extension> availableExtensions;
  final bool listenPlayerEvents;
  final Function(String) onCodeChange;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (!listenPlayerEvents) {
      return buildCodeEditorContainer(scrollController, controller).let(withCodeAutocompletion);
    } else {
      return BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, playerState) {
          updateScriptEditorSelectedLineOnCommandExecution(playerState, controller, scrollController);
        },
        builder: (context, playerState) {
          return buildCodeEditorContainer(scrollController, controller).let(withCodeAutocompletion);
        },
      );
    }
  }

  Widget buildCodeEditorContainer(CodeScrollController scrollController, CodeLineEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: CodeEditor(
        scrollController: scrollController,
        padding: EdgeInsets.all(15),
        readOnly: readOnly,
        showCursorWhenReadOnly: !readOnly,
        onChanged: (CodeLineEditingValue value) {
          if(controller.codeLines != controller.preValue?.codeLines && controller.preValue != null) onCodeChange(controller.text);
        },
        controller: controller,
        wordWrap: false,
        chunkAnalyzer: NonCodeChunkAnalyzer(),
        //TODO DefaultCodeChunkAnalyzer(),
        style: buildCodeEditorStyle(),
        indicatorBuilder: indicatorBuilder,
        sperator: Container(width: 1, color: Colors.blue),
      ),
    );
  }

  Widget indicatorBuilder(context, editingController, chunkController, notifier) {
    return Row(
      children: [
        DefaultCodeLineNumber(
          textStyle: TextStyle(color: Colors.white),
          focusedTextStyle: TextStyle(color: Colors.red),
          controller: editingController,
          notifier: notifier,
        ),
        DefaultCodeChunkIndicator(
          width: 15,
          controller: chunkController,
          notifier: notifier,
          painter: DefaultCodeChunkIndicatorPainter(color: Colors.white),
        )
      ],
    );
  }

  CodeEditorStyle buildCodeEditorStyle() {
    return CodeEditorStyle(
      fontSize: 14,
      selectionColor: Colors.amber.shade50.withAlpha(70),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      chunkIndicatorColor: Colors.red,
      codeTheme: CodeHighlightTheme(
        languages: {'yaml': CodeHighlightThemeMode(mode: langYaml)},
        theme: atomOneDarkTheme,
      ),
    );
  }

  void updateScriptEditorSelectedLineOnCommandExecution(
      PlayerState playerState, CodeLineEditingController controller, CodeScrollController scrollController) {
    final scene = playerState.script.scenes[playerState.currentSceneIndex];
    final currentCommand = playerState.currentCommandIndex >= -1
        ? scene.transitionCommands[min(playerState.currentCommandIndex + 1, scene.transitionCommands.length - 1)]
        : null;
    final scriptLineIndex = currentCommand?.metadata?.scriptLineIndex ?? scene.metadata.scriptLineIndex;

    _logger.trace(() => "Update script editor selected line to $scriptLineIndex - Current command $currentCommand");

    controller.selectLine(scriptLineIndex);
    controller.cancelSelection();
    scrollController.horizontalScroller.jumpTo(0);
  }

  Widget withCodeAutocompletion(Widget child) {
    final keywordPrompts = availableExtensions.map((e) => CodeKeywordPrompt(word: e.id)).toList();
    List<CodePrompt> templatePrompts = [
      CodeTemplatePrompt(word: "name", template: "name: ...element name..."),
      CodeTemplatePrompt(word: "description", template: "description: ...script description..."),
      CodeTemplatePrompt(word: "tags", template: "tags: [optional-tags]"),
      CodeTemplatePrompt(word: "scenes", template:
      """
            scenes:
              - name: "...scene name..."
                extensions: [ ]
                description: "...scene description"
                initial-state:
                  - nop
                transitions:
                  - nop
            """.trimIndent())
    ];

    Map<String, List<CodePrompt>> relatedCommandPrompts = {
      for (var e in availableExtensions)
        e.id : e.scripting.getAllCommandDefinitions().map((def) => CodeExtensionCommandPrompt(def)).toList()
          ..sort((a,b) => a.commandDefinition.name.compareTo(b.commandDefinition.name))
    };

    List<CodePrompt> commandPrompts = relatedCommandPrompts.values.expand((e) => e).toList();

    return CodeAutocomplete(
        viewBuilder: (context, notifier, onSelected) {
          return _DefaultCodeAutocompleteListView(
            notifier: notifier,
            onSelected: onSelected,
          );
        },
        promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
          language: langYaml,
          directPrompts: templatePrompts + commandPrompts,
          keywordPrompts: keywordPrompts,
          relatedPrompts: relatedCommandPrompts
        ),
        child: child);
  }
}

class _DefaultCodeAutocompleteListView extends StatefulWidget implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const _DefaultCodeAutocompleteListView({
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
      250,
      // 2 is border size
      min(kItemHeight * notifier.value.prompts.length, 150) + 2);

  @override
  State<StatefulWidget> createState() => _DefaultCodeAutocompleteListViewState();
}

class _DefaultCodeAutocompleteListViewState extends State<_DefaultCodeAutocompleteListView> {
  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(6)),
        child: AutoScrollListView(
          controller: ScrollController(),
          initialIndex: widget.notifier.value.index,
          scrollDirection: Axis.vertical,
          itemCount: widget.notifier.value.prompts.length,
          itemBuilder: (context, index) {
            final CodePrompt prompt = widget.notifier.value.prompts[index];
            final BorderRadius radius = BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(5) : Radius.zero,
              topRight: index == 0 ? const Radius.circular(5) : Radius.zero,
              bottomLeft: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
              bottomRight: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
            );
            return InkWell(
                borderRadius: radius,
                onTap: () {
                  widget.onSelected(widget.notifier.value.copyWith(index: index).autocomplete);
                },
                child: Container(
                  width: double.infinity,
                  height: _DefaultCodeAutocompleteListView.kItemHeight,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: index == widget.notifier.value.index ? Color.fromARGB(255, 255, 140, 0) : null, borderRadius: radius),
                  child: RichText(
                    text: prompt.createSpan(context, widget.notifier.value.input),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ));
          },
        ));
  }

  void _onValueChanged() {
    setState(() {});
  }
}

extension _CodePromptExtension on CodePrompt {
  InlineSpan createSpan(BuildContext context, String input) {
    final TextStyle style = TextStyle();
    final InlineSpan span = style.createSpan(
      value: word,
      anchor: input,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );
    final CodePrompt prompt = this;
    if (prompt is CodeFieldPrompt) {
      return TextSpan(children: [span, TextSpan(text: ' ${prompt.type}', style: style.copyWith(color: Colors.cyan))]);
    }
    if (prompt is CodeFunctionPrompt) {
      return TextSpan(children: [span, TextSpan(text: '(...) -> ${prompt.type}', style: style.copyWith(color: Colors.cyan))]);
    }
    return span;
  }
}

extension _TextStyleExtension on TextStyle {
  InlineSpan createSpan({
    required String value,
    required String anchor,
    required Color color,
    FontWeight? fontWeight,
    bool casesensitive = false,
  }) {
    if (anchor.isEmpty) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    final int index;
    if (casesensitive) {
      index = value.indexOf(anchor);
    } else {
      index = value.toLowerCase().indexOf(anchor.toLowerCase());
    }
    if (index < 0) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    return TextSpan(children: [
      TextSpan(text: value.substring(0, index), style: this),
      TextSpan(
          text: value.substring(index, index + anchor.length),
          style: copyWith(
            color: color,
            fontWeight: fontWeight,
          )),
      TextSpan(text: value.substring(index + anchor.length), style: this)
    ]);
  }
}

class AutoScrollListView extends StatefulWidget {
  final ScrollController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int initialIndex;
  final Axis scrollDirection;

  const AutoScrollListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StatefulWidget> createState() => _AutoScrollListViewState();
}

class _AutoScrollListViewState extends State<AutoScrollListView> {
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    _keys = List.generate(widget.itemCount, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AutoScrollListView oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      _keys.addAll(List.generate(widget.itemCount - oldWidget.itemCount, (index) => GlobalKey()));
    } else if (widget.itemCount < oldWidget.itemCount) {
      _keys.sublist(oldWidget.itemCount - widget.itemCount);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < widget.itemCount; i++) {
      widgets.add(Container(
        key: _keys[i],
        child: widget.itemBuilder(context, i),
      ));
    }
    return SingleChildScrollView(
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      child: isHorizontal
          ? Row(
              children: widgets,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
    );
  }

  void _autoScroll() {
    final ScrollController controller = widget.controller;
    if (!controller.hasClients) {
      return;
    }
    if (controller.position.maxScrollExtent == 0) {
      return;
    }
    double pre = 0;
    double cur = 0;
    for (int i = 0; i < _keys.length; i++) {
      final RenderObject? obj = _keys[i].currentContext?.findRenderObject();
      if (obj == null || obj is! RenderBox) {
        continue;
      }
      if (isHorizontal) {
        double width = obj.size.width;
        if (i == widget.initialIndex) {
          cur = pre + width;
          break;
        }
        pre += width;
      } else {
        double height = obj.size.height;
        if (i == widget.initialIndex) {
          cur = pre + height;
          break;
        }
        pre += height;
      }
    }
    if (pre == cur) {
      return;
    }
    if (pre < widget.controller.offset) {
      controller.jumpTo(pre - 1);
    } else if (cur > controller.offset + controller.position.viewportDimension) {
      controller.jumpTo(cur - controller.position.viewportDimension);
    }
  }

  bool get isHorizontal => widget.scrollDirection == Axis.horizontal;
}

class CodeExtensionCommandPrompt extends CodePrompt {
  CodeExtensionCommandPrompt(this.commandDefinition) : super(word: commandDefinition.name);

  final CommandDefinition commandDefinition;

  @override
  CodeAutocompleteResult get autocomplete {
    if (commandDefinition.args.isEmpty) {
      return CodeAutocompleteResult.fromText('$word');
    } else {
      var args =
          commandDefinition.args.map((arg) => "${arg.name}: ${arg.required ? "<${arg.type}>" : arg.convert(arg.defaultValue)}").join(", ");
      return CodeAutocompleteResult.fromText('$word: { ${args} }');
    }
  }

  @override
  bool match(String input) {
    return word != input && word.startsWith(input);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CodeExtensionCommandPrompt && other.word == word && other.commandDefinition == commandDefinition;
  }

  @override
  int get hashCode => Object.hash(word, commandDefinition);
}

class CodeTemplatePrompt extends CodePrompt {
  CodeTemplatePrompt({required super.word, required this.template} );

  final String template;

  @override
  CodeAutocompleteResult get autocomplete {
      return CodeAutocompleteResult.fromText(template);
  }

  @override
  bool match(String input) {
    return word != input && word.startsWith(input);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CodeTemplatePrompt && other.word == word && other.template == template;
  }

  @override
  int get hashCode => Object.hash(word, template);
}
