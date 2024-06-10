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

  const ScriptSelectorPage(
      this._publicRawScriptRepository,
      this._myRawScriptRepository,
      {super.key, this.openScriptInPlayer, this.openScriptInEditor}
  ): super(RouteName);

  final Future<void> Function(String)? openScriptInPlayer;
  final Future<void> Function(String)? openScriptInEditor;
  final RawScriptRepository _publicRawScriptRepository;
  final RawScriptRepository _myRawScriptRepository;

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

  IndexedTreeNode<AvailableScript> _publicScriptsTreeData = IndexedTreeNode.root();
  SearchableList<AvailableScript> _publicAvailableScripts = SearchableList<AvailableScript>(
    <AvailableScript>[],
    (query, availableScript) => availableScript.metadata.name.toLowerCase().contains(query.toLowerCase()),
  );
  bool _loadingPublicScripts = true;
  TreeViewController<AvailableScript, IndexedTreeNode<AvailableScript>>? _publicScriptsTreeController;
  TextEditingController _publicScriptsTextEditingController = TextEditingController();

  IndexedTreeNode<AvailableScript> _myScriptsTreeData = IndexedTreeNode.root();
  SearchableList<AvailableScript> _myAvailableScripts = SearchableList<AvailableScript>(
    <AvailableScript>[],
        (query, availableScript) => availableScript.metadata.name.toLowerCase().contains(query.toLowerCase()),
  );
  bool _loadingMyScripts = true;
  TreeViewController<AvailableScript, IndexedTreeNode<AvailableScript>>? _myScriptsTreeController;
  TextEditingController _myScriptsTextEditingController = TextEditingController();

  IndexedTreeNode<AvailableScript> _buildTreeData(List<AvailableScript> values) {
    _logger.debug(() => "Building tree data from ${values.length} values");
    IndexedTreeNode<AvailableScript> treeData = IndexedTreeNode.root();
    values.forEach((availableScript) {
       final parentNode = _getOrCreateParentNode(treeData, availableScript);
       parentNode.add(IndexedTreeNode<AvailableScript>(key: availableScript.scriptRef.hashCode.toString(), data: availableScript));
    });
    return treeData;
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

  void search(String query, SearchableList<AvailableScript> availableScripts) => setState(() => availableScripts.search(query));

  AvailableScript? _getSelectedScript(SearchableList<AvailableScript> availableScripts) => availableScripts.selected;

  @override
  void initState() {
    _publicAvailableScripts.onValuesUpdated = (values) => setState(() => _publicScriptsTreeData = _buildTreeData(values));
    widget._publicRawScriptRepository.fetchAvailableScriptsMetadata().then((value) =>
      this._publicAvailableScripts.setAllItems(value.entries.map((e) => AvailableScript(e.key, e.value)).toList())
    ).whenComplete(() => setState(() {
      _loadingPublicScripts = false;
    }));

    _myAvailableScripts.onValuesUpdated = (values) => setState(() => _myScriptsTreeData = _buildTreeData(values));
    loadMyAvailableScripts();

    super.initState();
  }

  Future<void> loadMyAvailableScripts() {
    _logger.trace(() => "Loading my available scripts");
    return widget._myRawScriptRepository.fetchAvailableScriptsMetadata().then((value) =>
        this._myAvailableScripts.setAllItems(value.entries.map((e) => AvailableScript(e.key, e.value)).toList())
    ).whenComplete(() => setState(() {
      _loadingMyScripts = false;
    }));
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
                buildTabContent(context, true, buildButtonBar(context, _publicAvailableScripts), _loadingPublicScripts, _publicAvailableScripts, _publicScriptsTreeData, _publicScriptsTreeController, _publicScriptsTextEditingController),
                _isUserLoggedIn() ? buildTabContent(context, false, buildMyScriptsButtonBar(context, _myAvailableScripts), _loadingMyScripts, _myAvailableScripts, _myScriptsTreeData, _myScriptsTreeController, _myScriptsTextEditingController) : buildLoginRequiredTabContent(context),
              ],
            ),
          ),
        ),
      );
  }

  bool _isUserLoggedIn() => true; //TODO

  Widget buildTabContent(BuildContext context, bool readOnly, ButtonBar scriptButtonBar, bool loadingScripts,
      SearchableList<AvailableScript> availableScripts,
      IndexedTreeNode<AvailableScript> treeData,
      TreeViewController<AvailableScript, IndexedTreeNode<AvailableScript>>? treeController,
      TextEditingController textEditingController) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(availableScripts, textEditingController),
      children: [buildScriptsList(context, readOnly, loadingScripts, availableScripts, treeData, treeController),
        const Spacer(flex: 2), buildDetailsSection(context, scriptButtonBar, availableScripts)],
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

    widget._myRawScriptRepository.fetchAvailableScriptsMetadata()
        .then((availableScriptsMetadata) {
          final nextIndex = availableScriptsMetadata.values
              .map((e) => newScriptRegExp.firstMatch(e.name)?.group(1)).nonNulls
              .map((e) => int.tryParse(e)).nonNulls.maxOrNull?.let((max) => max + 1) ?? 1;

          var scriptName = "New script $nextIndex";
          var scriptDescription = "... complete the 'New script $nextIndex' description";
          widget._myRawScriptRepository.save(RawScript(scriptRef, _buildNewScriptInitialContent(scriptName, scriptDescription)));
          return ScriptMetadata(scriptName, scriptDescription, <String>{});
        })
        .then((scriptMetadata) => _myAvailableScripts.addItem(AvailableScript(scriptRef, scriptMetadata)));

    _openScriptInEditor(scriptRef);
  }

  void _openScriptInEditor(String scriptRef) {
    _loadingMyScripts = true;
    widget.openScriptInEditor?.call(scriptRef)
        .then((value) => loadMyAvailableScripts())
        .whenComplete(() => setState((){}));
  }

  void _openScriptInPlayer(String scriptRef) {
    _loadingMyScripts = true;
    widget.openScriptInPlayer?.call(scriptRef)
        .then((value) => loadMyAvailableScripts())
        .whenComplete(() => setState((){}));
  }

  Widget buildScriptsList(BuildContext context, bool readOnly, bool loadingScripts, SearchableList<AvailableScript> availableScripts, IndexedTreeNode<AvailableScript> treeData, TreeViewController<AvailableScript, IndexedTreeNode<AvailableScript>>? treeController) {
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
                      child: loadingScripts
                                ? Center(child: CircularProgressIndicator())
                                : availableScripts.values.length == 0 //Only root node
                                    ?  const Center(child: Text('No Results Found', style: TextStyle(fontSize: 18)))
                                    : _buildListView(availableScripts, treeData, treeController),
                  ))),
            ],
          ));
  }

  Widget _buildListView(SearchableList<AvailableScript> availableScripts, IndexedTreeNode<AvailableScript> _treeData, _treeController) {
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

  Widget buildSearchBar(SearchableList<AvailableScript> availableScripts, TextEditingController controller) {
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
                  controller: controller,
                  onChanged: (query) => search(query, availableScripts),
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search scripts...')),
            ),
            TagsWidget(),
          ],
        ));
  }

  Expanded buildDetailsSection(BuildContext context, ButtonBar buttonBar, SearchableList<AvailableScript> availableScripts) {
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
                    data: _getSelectedScript(availableScripts)?.metadata.description ?? ""
                ),
              ),
            ),
            buttonBar
          ],
        ));
  }

  ButtonBar buildButtonBar(BuildContext context, SearchableList<AvailableScript> availableScripts) {
    final selectedScriptRef = _getSelectedScript(availableScripts)?.scriptRef;
    return ButtonBar(
      children: [
        TextButton(onPressed: (() => {_showConfirmDialog(context, "clone the script")}).takeIfDef(selectedScriptRef), child: const Text("Clone")),
        TextButton(onPressed: (() => { _openScriptInEditor(selectedScriptRef!)}).takeIfDef(selectedScriptRef), child: const Text("View")),
        ElevatedButton(onPressed: (() => {_openScriptInPlayer(selectedScriptRef!)}).takeIfDef(selectedScriptRef), child: const Text("Play")),
      ].nonNulls.toList(),
    );
  }

  ButtonBar buildMyScriptsButtonBar(BuildContext context, SearchableList<AvailableScript> availableScripts) {
    final selectedScriptRef = _getSelectedScript(availableScripts)?.scriptRef;
    return ButtonBar(
      children: [
        TextButton(onPressed: () => {_showConfirmDialog(context, "delete the script")}, child: const Text("Delete")),
        TextButton(onPressed: () => {_showConfirmDialog(context, "clone the script")}, child: const Text("Clone")),
        TextButton(onPressed: () => {_openScriptInEditor(selectedScriptRef!)}, child: const Text("View")),
        ElevatedButton(onPressed: () => {_openScriptInPlayer(selectedScriptRef!)}, child: const Text("Play")),
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