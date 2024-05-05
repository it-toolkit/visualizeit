import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visualizeit/common/ui/base_page.dart';
import 'package:visualizeit/extension/domain/extension_repository.dart';

import '../../common/ui/adaptive_container_widget.dart';
import '../../fake_data.dart';

class ExtensionPage extends StatefulBasePage {
  static const RouteName = "extensions";

  final ExtensionRepository _repository;

  const ExtensionPage(ExtensionRepository repository, {super.key}): this._repository = repository, super(RouteName);

  @override
  State<StatefulWidget> createState() {
    return _ExtensionPageState();
  }
}

class Extension {
  final String name;
  final String documentation;

  Extension(this.name, this.documentation);
}

class _ExtensionPageState extends BasePageState<ExtensionPage> {
  //TODO implement extensions model
  final List<Extension> _extensions = fakeExtensions;

  List<Extension> _filteredExtensions = [];
  int? _selectedIndex;
  String _query = '';

  void search(String query) {
    setState(
      () {
        _query = query;
        _filteredExtensions = _extensions.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
        if (_filteredExtensions.length == 1) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = null;
        }
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return AdaptiveContainerWidget(
      header: buildSearchBar(),
      children: [buildScriptsList(), const Spacer(flex: 2), buildDetailsSection(context)],
    );
  }

  Expanded buildScriptsList() {
    return Expanded(
        flex: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Extensions"),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: Material(
                        type: MaterialType.transparency,
                        child: _filteredExtensions.isNotEmpty || _query.isNotEmpty
                            ? _filteredExtensions.isEmpty
                                ? const Center(child: Text('No Results Found', style: TextStyle(fontSize: 18)))
                                : _buildListView(_filteredExtensions)
                            : _buildListView(_extensions)))),
          ],
        ));
  }

  Widget _buildListView(List<Extension> extensions) {
    return ListView.builder(
      itemCount: extensions.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          dense: true,
          titleAlignment: ListTileTitleAlignment.top,
          title: Text(extensions[index].name),
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 200,
            height: 40,
            child: TextField(
                onChanged: search,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(suffixIcon: Icon(Icons.search), hintText: 'Search extensions...')),
          ),
        ));
  }

  Expanded buildDetailsSection(BuildContext context) {
    final selectedExtension = _selectedIndex != null
        ? _filteredExtensions.isEmpty
            ? _extensions[_selectedIndex!]
            : _filteredExtensions[_selectedIndex!]
        : null;
    final detailsWidget = selectedExtension != null
        ? SingleChildScrollView(physics: const ClampingScrollPhysics(), child: MarkdownBody(data: selectedExtension.documentation))
        : null;

    return Expanded(
        flex: 58,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Details"),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: detailsWidget),
            ),
          ],
        ));
  }
}
