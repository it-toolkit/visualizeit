import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visualizeit/router.dart';
import 'package:visualizeit_extensions/logging.dart';

final _logger = Logger("base.ui");

class AppBarAction {
  final IconData icon;
  final String tooltip;
  final String destinationName;

  AppBarAction(this.icon, this.tooltip, this.destinationName);
}

class AppBarActions {
  static final SignIn = AppBarAction(Icons.login, 'SignIn', "sign-in");
  static final Extensions = AppBarAction(Icons.account_tree, 'Extensions', "extensions");
  static final Help = AppBarAction(Icons.help, 'Help', "help");
}

PreferredSizeWidget _buildBasePageAppBar(
    {
      required BuildContext context,
      required PreferredSizeWidget? Function(BuildContext) buildAppBarBottom,
      List<AppBarAction> actions = const []
    }) {

  final bloc = BlocProvider.of<AppBloc>(context);

  return AppBar(
      scrolledUnderElevation: 0, //Disable color change on scroll
      toolbarHeight: 80,
      bottom: buildAppBarBottom(context),
      title: const FittedBox(child: Text("Visualize IT", textScaler: TextScaler.linear(3.0))),
      centerTitle: false,
      actions: actions.map((action) => bloc._buildIconButton(action)).toList()
  );
}

extension _AppBlocExt on AppBloc {
  IconButton _buildIconButton(AppBarAction action) {
    return IconButton(
        icon: Icon(action.icon),
        tooltip: action.tooltip,
        onPressed: () => this.add(NavigationEvent(action.destinationName)));
  }
}

abstract class BasePage extends StatelessWidget {
  /// Constructs a [TemplateScreen]
  const BasePage({super.key, this.onSignInPressed, this.onExtensionsPressed, this.onHelpPressed});

  final VoidCallback? onHelpPressed;
  final VoidCallback? onSignInPressed;
  final VoidCallback? onExtensionsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBasePageAppBar(context: context, buildAppBarBottom: buildAppBarBottom),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}

abstract class StatefulBasePage extends StatefulWidget {
  final String name;

  const StatefulBasePage(this.name, {super.key});
}

abstract class BasePageState<T extends StatefulBasePage> extends State<T> {
  BasePageState();

  bool showAppBar = true;

  @override
  Widget build(BuildContext context) {
    final appActions = [AppBarActions.SignIn, AppBarActions.Extensions, AppBarActions.Help]
        .where((a) => a.destinationName != widget.name).toList();

    return Scaffold(
        appBar: !showAppBar
            ? null
            : _buildBasePageAppBar(context: context, buildAppBarBottom: buildAppBarBottom, actions: appActions),
        body: Container(margin: const EdgeInsets.all(15), child: buildBody(context)));
  }

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => null;

  Widget buildBody(BuildContext context);
}
