import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../extension/domain/default/default_extension.dart';
import '../../player/domain/player.dart';

class CanvasWidget extends StatelessWidget {

  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocConsumer<PlayerBloc, PlayerState>(
          listener: (context, playerState) {
            print("listen $playerState, playing: ${playerState.isPlaying}");

            var stateUpdate = (playerState.currentSceneModels[globalModelName] as GlobalModel).takeNextGlobalStateUpdate();
            if (stateUpdate == null) return;
            switch(stateUpdate){
              case PopupMessage _:
                {
                  print("Showing PopupMessage");
                  var playerBloc = BlocProvider.of<PlayerBloc>(context);
                  playerBloc.add(StopPlaybackEvent(waitingAction: true));
                  _showAlertDialog(context, playerBloc, message: stateUpdate.message);
                };
            }
          },
          builder: (context, playerState) {

            print("Rendering state: ${playerState.currentSceneIndex} - ${playerState.currentCommandIndex}, playing: ${playerState.isPlaying}");
            var visualizer = buildDefaultExtension().visualizer;
            List<Widget> widgets = playerState.currentSceneModels.values.map((e) => visualizer.render(e, context)).nonNulls.toList();

            return Stack(children: widgets);
          },
    ),);

    // return Container(
    //   decoration: BoxDecoration(color: Colors.blue.shade100),
    //   child: const Center(
    //     child: Icon(
    //       Icons.play_circle,
    //       size: 48,
    //     ),
    //   ),
    // );
  }

  void _showAlertDialog(BuildContext context, PlayerBloc playerBloc, {String? title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(message),
          actions: [
            TextButton(child: const Text("Close"), onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              playerBloc.add(StartPlaybackEvent(waitingAction: true));
            }),
          ],
        );
      },
    );
  }
}
