import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Category {
  final String name;

  Category({
    @required this.name,
  });
}

class CategoriesProvider with ChangeNotifier {
  List<Category> _items = [];

  List<Category> get items {
    return [..._items];
  }

  Future<void> fetchData() async {
    var prefs = await SharedPreferences.getInstance();
    List<Category> catList = List();
    if (!prefs.containsKey('allcategories')) {
      return;
    }
    List<String> stList = prefs.getStringList('allcategories');
    for (int n = 0; n < stList.length; n++) {
      catList.add(Category(name: stList[n]));
    }
    _items = catList;
    notifyListeners();
  }

  bool createCategory(String inputName) {
    for (int n = 0; n < _items.length; n++) {
      if (_items[n].name == inputName) {
        return false;
      }
    }
    final newCategory = Category(name: inputName);
    _items.add(newCategory);
    addToSharedPrefs();
    notifyListeners();
    return true;
  }

  bool updateCategory(int index, String inputName) {
    for (int n = 0; n < _items.length; n++) {
      if (_items[n].name == inputName) {
        return false;
      }
    }
    _items[index] = Category(name: inputName);
    addToSharedPrefs();
    notifyListeners();
    return true;
  }

  void deleteCategory(int categoryIndex) {
    _items.removeAt(categoryIndex);
    addToSharedPrefs();
    notifyListeners();
  }

  Future<void> addToSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> categoriesAsList = List();
    for (int n = 0; n < _items.length; n++) {
      categoriesAsList.add(_items[n].name);
    }
    prefs.remove('allcategories');
    prefs.setStringList('allcategories', categoriesAsList);
  }
}
