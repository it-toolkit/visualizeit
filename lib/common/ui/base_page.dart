import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualizeit/extension/ui/extension_page.dart';
import 'package:visualizeit/misc/ui/help_page.dart';
import 'package:visualizeit_extensions/logging.dart';

final _logger = Logger("base.ui");

class AppBarAction {
  final IconData icon;
  final String tooltip;
  final String destinationName;

  AppBarAction(this.icon, this.tooltip, this.destinationName);
}

class AppBarActions {
  static final Extensions = AppBarAction(Icons.account_tree, 'Extensions', ExtensionPage.RouteName);
  static final Help = AppBarAction(Icons.help, 'Help', HelpPage.RouteName);
}

PreferredSizeWidget _buildBasePageAppBar(
    {
      required BuildContext context,
      required PreferredSizeWidget? Function(BuildContext) buildAppBarBottom,
      List<AppBarAction> actions = const []
    }) {

  return AppBar(
      scrolledUnderElevation: 0, //Disable color change on scroll
      toolbarHeight: 80,
      bottom: buildAppBarBottom(context),
      title: const FittedBox(child: Text("Visualize IT", textScaler: TextScaler.linear(3.0))),
      centerTitle: false,
      actions: actions.map((action) =>
          IconButton(
              icon: Icon(action.icon),
              tooltip: action.tooltip,
              onPressed: () => context.push("/${action.destinationName}"),
          )).toList()
  );
}

abstract class StatefulBasePage extends StatefulWidget {
  final String name;

  const StatefulBasePage(this.name, {super.key});
}

abstract class BasePageState<T extends StatefulBasePage> extends State<T> {
  BasePageState();

  static final _HelperPageNavigationActions = [AppBarActions.Extensions, AppBarActions.Help];

  bool showAppBar = true;

  @override
  Widget build(BuildContext context) {
    final isShowingAnyHelperPage = _HelperPageNavigationActions.any((a) => a.destinationName == widget.name);
    final actions = isShowingAnyHelperPage ? <AppBarAction>[] : _HelperPageNavigationActions;

    return Scaffold(
        appBar: !showAppBar
            ? null
            : _buildBasePageAppBar(context: context, buildAppBarBottom: buildAppBarBottom, actions: actions),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}


abstract class StatelessBasePage extends StatelessWidget {
  const StatelessBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBasePageAppBar(context: context, buildAppBarBottom: buildAppBarBottom),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}