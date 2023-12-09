import 'package:flutter/material.dart';

abstract class BasePage extends StatelessWidget {
  /// Constructs a [TemplateScreen]
  const BasePage({super.key, this.onSignInPressed, this.onExtensionsPressed, this.onHelpPressed});

  final VoidCallback? onHelpPressed;
  final VoidCallback? onSignInPressed;
  final VoidCallback? onExtensionsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,//Disable color change on scroll
            toolbarHeight: 80,
            bottom: buildAppBarBottom(context),
            title: const FittedBox(child: Text("Visualize IT", textScaler: TextScaler.linear(3.0))),
            actions: <Widget>[
              IconButton(icon: const Icon(Icons.login), tooltip: 'SignIn', onPressed: onSignInPressed),
              IconButton(icon: const Icon(Icons.account_tree), tooltip: 'Extensions', onPressed: onExtensionsPressed),
              IconButton(icon: const Icon(Icons.help), tooltip: 'Help', onPressed: onHelpPressed),
            ]),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}
