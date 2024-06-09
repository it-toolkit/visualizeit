import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/common/ui/tags_widget.dart';
import 'package:visualizeit/common/utils/extensions.dart';
import 'package:visualizeit/scripting/domain/script_repository.dart';
import 'package:collection/collection.dart';
import 'package:visualizeit_extensions/logging.dart';

import '../../common/markdown/markdown.dart';
import '../../common/ui/adaptive_container_widget.dart';
import '../domain/script_def.dart';

final _logger = Logger("scripting.ui.script_selector_page");

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


class SearchableList<T> {
  List<T> _allItems;
  bool Function(String, T) _queryMatcher;

  String query = '';
  List<T> values = [];
  T? selected = null;
  bool _dirty = true;
  void Function(List<T> values)? onValuesUpdated;

  SearchableList(List<T> initialItems, this._queryMatcher, {this.onValuesUpdated}): this._allItems = initialItems {
    search(query);
  }

  void addItem(T item) {
    this._allItems.add(item);
    _dirty = true;
    search(query);
  }

  void setAllItems(List<T> allItems) {
    if(this._allItems == allItems || ListEquality().equals(this._allItems, allItems)) return;

    this._allItems = allItems;
    _dirty = true;
    search(query);
  }

  void deselect() {
    selected = null;
  }

  void select(T selectedItem){
    if (_allItems.indexOf(selectedItem) < 0) throw Exception("Unknown selected item: $selectedItem");

    selected = selectedItem;
  }

  void search(String query) {
    if(this.query == query && !_dirty) return;

    this.query = query;
    values = _allItems.where((item) => _queryMatcher(query, item)).toList();
    selected = values.length == 1 ? values.first : null;
    _dirty = false;

    onValuesUpdated?.call(values);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchableList &&
          runtimeType == other.runtimeType &&
          _allItems == other._allItems &&
          _queryMatcher == other._queryMatcher &&
          query == other.query &&
          values == other.values &&
          selected == other.selected;

  @override
  int get hashCode => _allItems.hashCode ^ _queryMatcher.hashCode ^ query.hashCode ^ values.hashCode ^ selected.hashCode;
}

class AvailableScript {
  ScriptRef scriptRef;
  ScriptMetadata metadata;

  AvailableScript(this.scriptRef, this.metadata);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableScript && runtimeType == other.runtimeType && scriptRef == other.scriptRef && metadata == other.metadata;

  @override
  int get hashCode => scriptRef.hashCode ^ metadata.hashCode;

  @override
  String toString() {
    return 'AvailableScript{name: ${metadata.name}}';
  }
}

class _ScriptSelectorPageState extends BasePageState<ScriptSelectorPage> {
  final uuid = Uuid();

  IndexedTreeNode<AvailableScript> _treeData = IndexedTreeNode.root();

  SearchableList<AvailableScript> availableScripts = SearchableList<AvailableScript>(
    <AvailableScript>[],
    (query, availableScript) => availableScript.metadata.name.toLowerCase().contains(query.toLowerCase()),
  );
  bool _loadingScripts = true;

  TreeViewController<AvailableScript, IndexedTreeNode<AvailableScript>>? _treeController;

  void updateTreeData(List<AvailableScript> values) {
    _logger.debug(() => "Updating tree data from ${values.length} values");
    IndexedTreeNode<AvailableScript> updatedTreeData = IndexedTreeNode.root();
    values.forEach((availableScript) {
       final parentNode = _getOrCreateParentNode(updatedTreeData, availableScript);
       parentNode.add(IndexedTreeNode<AvailableScript>(key: availableScript.scriptRef.hashCode.toString(), data: availableScript));
    });
    setState(() {
      _treeData = updatedTreeData;
    });
  }

  IndexedTreeNode _getOrCreateParentNode(IndexedTreeNode<AvailableScript> rootNode, AvailableScript availableScript) {
    final group = availableScript.metadata.group;
    if(group == null) return rootNode;

    var parentNode = rootNode.children.firstWhereOrNull((node) => node.key == group) as IndexedTreeNode?;
    if(parentNode == null) {
      parentNode = IndexedTreeNode<AvailableScript>(key: group);
      rootNode.add(parentNode);
    }
    return parentNode;
  }

  void search(String query) => setState(() => availableScripts.search(query));

  AvailableScript? _getSelectedScript() => availableScripts.selected;

  @override
  void initState() {
    availableScripts.onValuesUpdated = (values) => updateTreeData(values);

    widget._rawScriptRepository.fetchAvailableScriptsMetadata().then((value) =>
      this.availableScripts.setAllItems(value.entries.map((e) => AvailableScript(e.key, e.value)).toList())
    ).whenComplete(() => setState(() {
      _loadingScripts = false;
    }));
    super.initState();
  }

  @override
  buildBody(BuildContext context) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: DefaultTabController(
          length: 2,
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
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                buildTabContent(context, true, buildButtonBar(context)),
                _isUserLoggedIn() ? buildTabContent(context, false, buildMyScriptsButtonBar(context)) : buildLoginRequiredTabContent(context),
              ],
            ),
          ),
        ),
      );
  }

  bool _isUserLoggedIn() => true; //TODO

  Widget buildTabContent(BuildContext context, bool readOnly, ButtonBar scriptButtonBar) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(),
      children: [buildScriptsList(context, readOnly), const Spacer(flex: 2), buildDetailsSection(context, scriptButtonBar)],
    );
  }

  String _buildNewScriptInitialContent(String scriptName, String scriptDescription) => """
    # Write your script here...
    name: $scriptName
    description: $scriptDescription 
    tags: []
    """.trimIndent();


  void _createScript() {
    var scriptRef = uuid.v4();
    final  newScriptRegExp = RegExp(r'New script (\d+)');

    widget._rawScriptRepository.fetchAvailableScriptsMetadata()
        .then((availableScriptsMetadata) {
          final nextIndex = availableScriptsMetadata.values
              .map((e) => newScriptRegExp.firstMatch(e.name)?.group(1)).nonNulls
              .map((e) => int.tryParse(e)).nonNulls.maxOrNull?.let((max) => max + 1) ?? 1;

          var scriptName = "New script $nextIndex";
          var scriptDescription = "... complete the 'New script $nextIndex' description";
          widget._rawScriptRepository.save(RawScript(scriptRef, _buildNewScriptInitialContent(scriptName, scriptDescription)));
          return ScriptMetadata(scriptName, scriptDescription, <String>{});
        })
        .then((scriptMetadata) => availableScripts.addItem(AvailableScript(scriptRef, scriptMetadata)));
    context.go("/scripts/$scriptRef/edit");
  }

  Widget buildScriptsList(BuildContext context, bool readOnly) {
      return Expanded(
          flex: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              readOnly
                  ? const SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: Text("Scripts")))
                  : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text("Scripts"),
                      Spacer(),
                      IconButton(onPressed: _createScript, icon: Icon(Icons.add_circle_outline), tooltip: "Create script", iconSize: 20),
                      IconButton(onPressed: null, icon: Icon(Icons.compare_arrows), tooltip: "Import scripts", iconSize: 20),
                      IconButton(onPressed: null, icon: Icon(Icons.import_export), tooltip: "Export scripts", iconSize: 20),
              ]),
              Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Material(
                      type: MaterialType.transparency,
                      child: _loadingScripts
                                ? Center(child: CircularProgressIndicator())
                                : availableScripts.values.length == 0 //Only root node
                                    ?  const Center(child: Text('No Results Found', style: TextStyle(fontSize: 18)))
                                    : _buildListView(availableScripts.values),
                  ))),
            ],
          ));
  }

  Widget _buildListView(List<AvailableScript> scripts) {
    return TreeView.indexed(showRootNode: false,
      tree: _treeData,
      onTreeReady: (controller) {
        _treeController = controller;
        controller.expandAllChildren(_treeData);
      },
      builder: (context, node) {
        return ListTile(
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(node.data?.metadata.name ?? node.key), //TODO stop using keys.. see how to represent "group" nodes
          selectedTileColor: Colors.blue.shade200,
          onTap: () {
            var data = node.data;
            if (data == null) {
              _treeController?.toggleExpansion(node);
              return;
            };
            setState(() {
              _logger.debug(() => "Tap on: ${data.metadata.name}");
              availableScripts.select(data);
            });
          },
          hoverColor: Colors.blue.shade100,
          selected: availableScripts.selected?.scriptRef != null && availableScripts.selected!.scriptRef == (node.data as AvailableScript?)?.scriptRef,
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
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: ExtendedMarkdownWidget(
                    data: _getSelectedScript()?.metadata.description ?? ""
                ),
              ),
            ),
            buttonBar
          ],
        ));
  }

  ButtonBar buildButtonBar(BuildContext context) {
    final selectedScriptRef = _getSelectedScript()?.scriptRef;
    return ButtonBar(
      children: [
        TextButton(onPressed: (() => {_showConfirmDialog(context, "clone the script")}).takeIfDef(selectedScriptRef), child: const Text("Clone")),
        TextButton(onPressed: (() => {widget.onViewPressed?.call(selectedScriptRef!)}).takeIfDef(selectedScriptRef), child: const Text("View")),
        ElevatedButton(onPressed: (() => {widget.onPlayPressed?.call(selectedScriptRef!)}).takeIfDef(selectedScriptRef), child: const Text("Play")),
      ].nonNulls.toList(),
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context) {
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "delete the script")}, child: const Text("Delete")),
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {widget.onViewPressed?.call(_getSelectedScript()!.scriptRef)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {widget.onPlayPressed?.call(_getSelectedScript()!.scriptRef)}, child: const Text("Play")),
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
