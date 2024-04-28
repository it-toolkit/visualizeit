import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/common/ui/tags_widget.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';

import '../../common/ui/adaptive_container_widget.dart';
import '../domain/script_def.dart';

class ScriptSelectorPage extends StatefulBasePage {
  static const RouteName = "script-selector";

  const ScriptSelectorPage(this._rawScriptRepository, {super.key, this.onPlayPressed, this.onViewPressed}): super(RouteName);

  final Function(String)? onPlayPressed;
  final Function(String)? onViewPressed;
  final RawScriptRepository _rawScriptRepository;

  @override
  State<StatefulWidget> createState() {
    return _ScriptSelectorPageState();
  }
}


class _ScriptSelectorPageState extends BasePageState<ScriptSelectorPage> {
  late List<MapEntry<ScriptRef, ScriptMetadata>> _availableScripts;
  List<MapEntry<ScriptRef, ScriptMetadata>> _filteredScripts = [];
  int? _selectedIndex;
  String _query = '';

  void search(String query) {
    setState(
          () {
        _query = query;
        _filteredScripts = _availableScripts.where((item) => item.value.name.toLowerCase().contains(query.toLowerCase())).toList();
        if (_filteredScripts.length == 1) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = null;
        }
      },
    );
  }

  MapEntry<ScriptRef, ScriptMetadata>? _getSelectedScript() {
    return _selectedIndex != null ? (_query.isEmpty ? _availableScripts[_selectedIndex!] : _filteredScripts[_selectedIndex!]) : null;
  }

  @override
  buildBody(BuildContext context) {
    final availableScriptsFuture = widget._rawScriptRepository.fetchAvailableScriptsMetadata();
    return FutureBuilder(future: availableScriptsFuture, builder: (BuildContext context, AsyncSnapshot<Map<ScriptRef, ScriptMetadata>> snapshot)
    {
      this._availableScripts = snapshot.data?.entries.toList() ?? List.empty();

      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(40.0),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[Colors.lightBlue, Colors.lightGreenAccent]),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: const TabBar(
                  tabs: [
                    Tab(child: Text("Public scripts", softWrap: true, textAlign: TextAlign.center)),
                    Tab(child: Text("My scripts", softWrap: true, textAlign: TextAlign.center)),
                    Tab(child: Text("Shared with me", softWrap: true, textAlign: TextAlign.center))
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                buildTabContent(context, buildButtonBar(context)),
                _isUserLoggedIn() ? buildTabContent(context, buildMyScriptsButtonBar(context)) : buildLoginRequiredTabContent(context),
                _isUserLoggedIn() ? buildTabContent(context, buildButtonBar(context)) : buildLoginRequiredTabContent(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  bool _isUserLoggedIn() => false; //TODO

  Widget buildTabContent(BuildContext context, ButtonBar scriptButtonBar) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(),
      children: [buildScriptsList(), const Spacer(flex: 2), buildDetailsSection(context, scriptButtonBar)],
    );
  }

  Widget buildScriptsList() {

      return Expanded(
          flex: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text("Scripts"),
                Spacer(),
                IconButton(onPressed: null, icon: Icon(Icons.add_circle_outline), tooltip: "Create script", iconSize: 20),
                IconButton(onPressed: null, icon: Icon(Icons.compare_arrows), tooltip: "Import scripts", iconSize: 20),
                IconButton(onPressed: null, icon: Icon(Icons.import_export), tooltip: "Export scripts", iconSize: 20),
              ]),
              Expanded(
                  child: Container(
                    decoration:
                    const BoxDecoration(color: Color.fromRGBO(171, 197, 212, 0.3), borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: _filteredScripts.isNotEmpty || _query.isNotEmpty
                        ? (_filteredScripts.isEmpty
                          ? const Center(child: Text('No Results Found', style: TextStyle(fontSize: 18)))
                          : _buildListView(_filteredScripts.map((e) => e.value).toList()))
                        : _buildListView(_availableScripts.map((e) => e.value).toList()),
                  )),
            ],
          ));
  }

  ListView _buildListView(List<ScriptMetadata> scripts) {
    return ListView.builder(
        itemCount: scripts.length,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            dense: true,
            titleAlignment: ListTileTitleAlignment.top,
            title: Text('- ${scripts[index].name}'),
            selectedTileColor: Colors.blue.shade200,
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            hoverColor: Colors.blue.shade100,
            selected: index == _selectedIndex,
          );
        },
      );
  }

  Widget buildSearchBar() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 15,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 40,
              child: TextField(
                  onChanged: search,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search scripts...')),
            ),
            TagsWidget(),
          ],
        ));
  }

  Expanded buildDetailsSection(BuildContext context, ButtonBar buttonBar) {
    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 40,
              child: Align(alignment: Alignment.centerLeft, child: Text("Script details")),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(171, 197, 212, 0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(physics: const ClampingScrollPhysics(), child: MarkdownBody(
                    data: _getSelectedScript()?.value.description ?? ""
                )),
              ),
            ),
            buttonBar
          ],
        ));
  }

  ButtonBar buildButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {widget.onViewPressed?.call(_getSelectedScript()!.key)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {widget.onPlayPressed?.call(_getSelectedScript()!.key)}, child: const Text("Play")),
      ],
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "delete the script")}, child: const Text("Delete")),
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {widget.onViewPressed?.call(_getSelectedScript()!.key)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {widget.onPlayPressed?.call(_getSelectedScript()!.key)}, child: const Text("Play")),
      ],
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, String actionDescription) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('...'),
          content: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ListBody(
              children: <Widget>[
                Text('Would you like to $actionDescription?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  buildLoginRequiredTabContent(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 36,
              color: Colors.blue.shade300,
            ),
            const Text("Login required")
          ],
        ));
  }
}
