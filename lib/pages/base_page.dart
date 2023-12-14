import 'package:flutter/material.dart';
import 'package:visualizeit/utils/extensions.dart';

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
            centerTitle: false,
            actions: <Widget?>[
              IconButton(icon: const Icon(Icons.login), tooltip: 'SignIn', onPressed: onSignInPressed).takeIfDef(onSignInPressed),
              IconButton(icon: const Icon(Icons.account_tree), tooltip: 'Extensions', onPressed: onExtensionsPressed).takeIfDef(onExtensionsPressed),
              IconButton(icon: const Icon(Icons.help), tooltip: 'Help', onPressed: onHelpPressed).takeIfDef(onHelpPressed),
            ].nonNulls.toList()),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}


abstract class StatefulBasePage extends StatefulWidget {
  const StatefulBasePage({super.key, this.onSignInPressed, this.onExtensionsPressed, this.onHelpPressed});

  final VoidCallback? onHelpPressed;
  final VoidCallback? onSignInPressed;
  final VoidCallback? onExtensionsPressed;

}

abstract class BasePageState<T extends StatefulBasePage> extends State<T> {
  /// Constructs a [BasePageState]
  BasePageState();

  bool showAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !showAppBar ? null : AppBar(
            scrolledUnderElevation: 0,//Disable color change on scroll
            toolbarHeight: 80,
            bottom: buildAppBarBottom(context),
            title: const FittedBox(child: Text("Visualize IT", textScaler: TextScaler.linear(3.0))),
            actions: <Widget?>[
              IconButton(icon: const Icon(Icons.login), tooltip: 'SignIn', onPressed: widget.onSignInPressed).takeIfDef(widget.onSignInPressed),
              IconButton(icon: const Icon(Icons.account_tree), tooltip: 'Extensions', onPressed: widget.onExtensionsPressed).takeIfDef(widget.onExtensionsPressed),
              IconButton(icon: const Icon(Icons.help), tooltip: 'Help', onPressed: widget.onHelpPressed).takeIfDef(widget.onHelpPressed),
            ].nonNulls.toList()),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}
