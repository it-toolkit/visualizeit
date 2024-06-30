import 'package:collection/collection.dart';


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

  void addItems(List<T> items) {
    this._allItems.addAll(items);
    _dirty = true;
    search(query);
  }

  void setAllItems(List<T> allItems) {
    if(this._allItems == allItems || ListEquality().equals(this._allItems, allItems)) return;

    this._allItems = List.from(allItems);
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

  bool delete(T item) {
    if (this._allItems.remove(item)) {
      _dirty = true;
      search(query);
      return true;
    }

    return false;
  }
}