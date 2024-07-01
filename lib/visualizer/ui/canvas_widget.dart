import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:single_child_two_dimensional_scroll_view/single_child_two_dimensional_scroll_view.dart';
import 'package:visualizeit/common/markdown/markdown.dart';
import 'package:visualizeit/extension/domain/default/default_extension.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';
import 'package:visualizeit/player/domain/player.dart';
import 'package:visualizeit/scripting/domain/script_def.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/visualizer.dart';

import 'dialog.dart';

final _logger = Logger("visualizer.ui.canvas");

class CanvasWidget extends StatefulWidget {

  final ExtensionRepository extensionRepository;

  const CanvasWidget(this.extensionRepository, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _CanvasWidgetState();
  }
}


class _CanvasWidgetState extends State<CanvasWidget> {

  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();
  final _transformationController = TransformationController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocConsumer<PlayerBloc, PlayerState>(
          listener: (context, playerState) {
            _logger.debug(() => "Listening $playerState when script isPlaying=${playerState.isPlaying}");

            if (scaleWasUpdated(context, playerState)) {
              _verticalController.jumpTo(0);
              _horizontalController.jumpTo(0);
              _transformationController.value = Matrix4.identity();
            }

            var stateUpdate = (playerState.currentSceneModels[globalModelName] as GlobalModel).takeNextGlobalStateUpdate();
            if (stateUpdate == null) return;
            switch(stateUpdate){
              case PopupMessage _:
                {
                  _logger.debug(() => "Showing PopupMessage");
                  var playerBloc = BlocProvider.of<PlayerBloc>(context);
                  playerBloc.add(StopPlaybackEvent(waitingAction: true));
                  _showAlertDialog(context, playerBloc, message: stateUpdate.message);
                };
            }
          },
        builder: (context, playerState) {
          _logger.trace(() => "Rendering $playerState");

          List<Widget> widgets;
          if (playerState.countdownToStart > 0) {
            widgets = buildScenePresentation(playerState.currentScene.metadata, playerState.countdownToStart);
          } else {

            widgets = playerState.currentSceneModels.values
                .expand((model) => widget.extensionRepository.getById(model.extensionId).renderer.renderAll(model, context))
                .nonNulls
                .toList()
              ..sort((a, b) => (a is RenderingPriority ? a.priority : 0).compareTo(b is RenderingPriority ? b.priority : 0));
          }
          final scaledDown = playerState.canvasScale < 1;

          return LayoutBuilder(builder: (context, constraints) {
              return SingleChildTwoDimensionalScrollView(
                  verticalController: _verticalController,
                  horizontalController: _horizontalController,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                      minScale: 0.1,
                      maxScale: scaledDown ? 3 / playerState.canvasScale: 3,
                      child: scaledDown ? Transform.scale(scale: playerState.canvasScale, child: Container(
                          width: max(400, constraints.maxWidth),
                          height: max(400, constraints.maxHeight),
                          child: Stack(fit: StackFit.expand, children: widgets)))
                      : Container(
                          width: max(400, constraints.maxWidth * playerState.canvasScale),
                          height: max(400, constraints.maxHeight * playerState.canvasScale),
                          child: Stack(fit: StackFit.expand, children: widgets))
                  ));
            });
        },
      ),);
  }

  bool scaleWasUpdated(BuildContext context, PlayerState playerState) {
    var lastState = BlocProvider.of<PlayerBloc>(context).history.lastOrNull;
    return lastState?.canvasScale != playerState.canvasScale;
  }

  void _showAlertDialog(BuildContext context, PlayerBloc playerBloc, {String? title, required String message}) {
    InformationDialog.show(
      context,
      () {
        Navigator.of(context, rootNavigator: true).pop();
        playerBloc.add(StartPlaybackEvent(waitingAction: true));
      },
      title: title,
      message: message,
    );
  }

  List<Widget> buildScenePresentation(SceneMetadata metadata, int pendingFrames) {
    return [
      SceneTitleSlide(title: metadata.name, description: metadata.description),
      Align(alignment: Alignment.topRight, child: Padding(padding: EdgeInsets.only(right: 5), child: CircularCounter(pendingFrames)))
    ];
  }
}

class SceneTitleSlide extends StatelessWidget {
  final String title;
  final String? description;

  SceneTitleSlide({required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // colors: [Colors.cyan.shade100, Colors.green.shade100],
          colors: [Colors.teal, Colors.grey.shade100],
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (description != null) ...[
            SizedBox(height: 10),
            ExtendedMarkdownBlock(data: description!)
          ],
        ],
      ),
    );
  }
}

class CircularCounter extends StatelessWidget {

  final int counterValue;

  const CircularCounter(this.counterValue);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
            width: 2.0,
          ),
        ),
        child: Text("$counterValue"),
    );
  }
}