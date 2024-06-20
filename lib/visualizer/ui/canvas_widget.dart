import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:single_child_two_dimensional_scroll_view/single_child_two_dimensional_scroll_view.dart';
import 'package:visualizeit/extension/action.dart';
import 'package:visualizeit_extensions/logging.dart';
import 'package:visualizeit_extensions/visualizer.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../player/domain/player.dart';
import 'dialog.dart';

final _logger = Logger("visualizer.ui.canvas");

class CanvasWidget extends StatefulWidget {

  const CanvasWidget({super.key});

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

          final getExtensionById = context.read<GetExtensionById>();
          List<Widget> widgets = playerState.currentSceneModels.values
              .expand((model) => getExtensionById(model.extensionId).renderer.renderAll(model, context))
              .nonNulls
              .toList()
            ..sort((a, b) => (a is RenderingPriority ? a.priority : 0).compareTo(b is RenderingPriority ? b.priority : 0));

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
}
