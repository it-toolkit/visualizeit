import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

import '../../player/domain/player.dart';

class PlayerScriptEditorWidget extends StatelessWidget {
  const PlayerScriptEditorWidget({super.key, required this.script});

  final String script;

  @override
  Widget build(BuildContext context) {
    final controller = CodeLineEditingController.fromText(script);
    final scrollController = CodeScrollController();
    return BlocConsumer<PlayerBloc, PlayerState>(listener: (context, playerState) {
      final scene = playerState.script.scenes[playerState.currentSceneIndex];
      final currentCommand = playerState.currentCommandIndex >= -1 ? scene.transitionCommands[min(playerState.currentCommandIndex+1, scene.transitionCommands.length-1)] : null;
      print("XXX - Current command $currentCommand");
      final scriptLineIndex = currentCommand?.metadata?.scriptLineIndex ?? scene.metadata.scriptLineIndex;

      print("XXX Script line index: $scriptLineIndex");

      controller.selectLine(scriptLineIndex);
      controller.cancelSelection();
      scrollController.horizontalScroller.jumpTo(0);
    }, builder: (context, playerState) {
      return Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: CodeEditor(
          scrollController: scrollController,
          padding: EdgeInsets.all(15),
          readOnly: false,
          onChanged: (CodeLineEditingValue value) {
            //TODO print("Updated: \n${controller.selectedText}");
          },
          controller: controller,
          wordWrap: false,
          chunkAnalyzer: NonCodeChunkAnalyzer(),
          //TODO DefaultCodeChunkAnalyzer(),
          style: CodeEditorStyle(
            fontSize: 14,
            selectionColor: Colors.amber.shade50.withAlpha(70),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            chunkIndicatorColor: Colors.red,
            codeTheme: CodeHighlightTheme(
              languages: {'yaml': CodeHighlightThemeMode(mode: langYaml)},
              theme: atomOneDarkTheme,
            ),
          ),

          indicatorBuilder: (context, editingController, chunkController, notifier) {
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
          },
          sperator: Container(width: 1, color: Colors.blue),
        ),
      );
    });
  }
}

class ScriptEditorWidget extends StatelessWidget {
  const ScriptEditorWidget({super.key, required this.script});

  final String script;

  @override
  Widget build(BuildContext context) {
    final controller = CodeLineEditingController.fromText(script);
    final scrollController = CodeScrollController();

    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: CodeEditor(
        scrollController: scrollController,
        padding: EdgeInsets.all(15),
        readOnly: false,
        onChanged: (CodeLineEditingValue value) {
          print("Updated: \n${controller.selectedText}");
        },
        controller: controller,
        wordWrap: false,
        chunkAnalyzer: NonCodeChunkAnalyzer(),
        //TODO DefaultCodeChunkAnalyzer(),
        style: CodeEditorStyle(
          fontSize: 14,
          selectionColor: Colors.amber.shade50.withAlpha(70),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          chunkIndicatorColor: Colors.red,
          codeTheme: CodeHighlightTheme(
            languages: {'yaml': CodeHighlightThemeMode(mode: langYaml)},
            theme: atomOneDarkTheme,
          ),
        ),

        indicatorBuilder: (context, editingController, chunkController, notifier) {
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
        },
        sperator: Container(width: 1, color: Colors.blue),
      ),
    );
  }
}
