import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/extension/action.dart';
import 'package:visualizeit_extensions/common.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../player/domain/player.dart';
import 'dialog.dart';

final _logger = Logger("visualizer.ui.canvas");

class CanvasWidget extends StatelessWidget {

  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocConsumer<PlayerBloc, PlayerState>(
          listener: (context, playerState) {
            _logger.debug(() => "Listening $playerState when script isPlaying=${playerState.isPlaying}");

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
            _logger.debug(() => "Rendering $playerState");

            final getExtensionById = context.read<GetExtensionById>();

            List<Widget> widgets = getModelsOrderedByPriority(playerState)
                .map((model) => getExtensionById(model.extensionId).visualizer.render(model, context))
                .nonNulls.toList();

            return Stack(fit: StackFit.expand, children: widgets);
          },
    ),);
  }

  Iterable<Model> getModelsOrderedByPriority(PlayerState playerState) {
    List<Model> topModels = [];
    List<Model> bottomModels = [];

    playerState.currentSceneModels.values.forEach((model) {
        (model.extensionId == DefaultExtensionConsts.Id ? topModels : bottomModels).add(model);
    });

    return bottomModels.followedBy(topModels);
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
