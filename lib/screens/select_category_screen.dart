import 'package:flutter/material.dart';
import 'package:note/screens/categories_screen.dart';
import '../providers/categories_provider.dart';
import '../providers/notes_provider.dart';
import 'package:provider/provider.dart';


// Screen to add and remove notes from categories
class SelectCategoryScreen extends StatefulWidget {
  static const routeKey = '/select-category';
  final String noteId;

  SelectCategoryScreen(this.noteId);

  @override
  _SelectCategoryScreenState createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
//  var _isChecked = false;
  List<bool> allValues = List();
  List<String> allCat = List();

//  var _isInit = false;

  @override
  void initState() {
    super.initState();
    int catLength =
        Provider.of<CategoriesProvider>(context, listen: false).items.length;
    allCat = List(catLength);
    for (int n = 0; n < catLength; n++) {
      allCat[n] =
          Provider.of<CategoriesProvider>(context, listen: false).items[n].name;
    }
    allValues = Provider.of<NotesProvider>(context, listen: false)
        .belongToCategory(widget.noteId, allCat);
  }

  Future<bool> _onWillPop() async {
    List<String> result = List();
    for (int n = 0; n < allValues.length; n++) {
      if (allValues[n]) {
        result.add(allCat[n]);
      }
    }
    Navigator.of(context).pop(result);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoriesProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Categories'),
          ),
          body: ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: category.items.length,
            itemBuilder: (ctx, index) => CheckboxListTile(
              title: Text(category.items[index].name),
              onChanged: (value) {
                setState(() {
                  allValues[index] = value;
                });
              },
              value: allValues[index],
            ),
          )),
    );
  }
}
