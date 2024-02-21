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
            print("listen $playerState");

            var stateUpdate = (playerState.currentSceneModels[globalModelName] as GlobalModel).takeNextGlobalStateUpdate();
            if (stateUpdate == null) return;
            switch(stateUpdate){
              case PopupMessage _: _showAlertDialog(context, message: stateUpdate.message);
            }
          },
          builder: (context, playerState) {

            print("Rendering state: ${playerState.currentSceneIndex} - ${playerState.currentCommandIndex}");
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

  void _showAlertDialog(BuildContext context, {String? title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(message),
          actions: [
            TextButton(child: const Text("Close"), onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            }),
          ],
        );
      },
    );
  }
}
