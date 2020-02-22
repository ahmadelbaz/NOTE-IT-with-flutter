import 'package:flutter/material.dart';
import 'package:note/providers/categories_provider.dart';
import 'package:note/providers/notes_provider.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  // route key to navigate to this screen suing it
  static const routeKey = '/categories-screen';

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoriesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: <Widget>[
          // add new category
          IconButton(
              tooltip: 'Add Category',
              icon: Icon(Icons.add),
              onPressed: () {
                // Create new Category and add it to the category list
                var newCategoryController = TextEditingController();
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text('Create new Category'),
                          content: TextField(
                            autofocus: true,
                            controller: newCategoryController,
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            FlatButton(
                              child: Text('Okay'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                // isAdded bool var
                                final isAdded = Provider.of<CategoriesProvider>(
                                        context)
                                    .createCategory(newCategoryController.text);
                                if (!isAdded) {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            title: Text('An error occured!'),
                                            content: Text(
                                                'This Category is Already here!'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('Okay'),
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                              )
                                            ],
                                          ));
                                }
                              },
                            ),
                          ],
                        ));
              })
        ],
      ),
      body: ListView.builder(
        itemCount: category.items.length,
        itemBuilder: (ctx, index) => ListTile(
          leading: Text(category.items[index].name),
          onTap: () {
            // edit this Category in both category provider and in notes provider
            var _newCategoryController = TextEditingController();
            String _initialValue = category.items[index].name;
            _newCategoryController.text = category.items[index].name;
            showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text('Edit Category'),
                      content: TextField(
                        autofocus: true,
                        controller: _newCategoryController,
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('Okay'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            if (_newCategoryController.text == _initialValue) {
                              addingAlertDialog(context, 'An error occured!',
                                  'Nothing changed!');
                              return;
                            }
                            // change category name in categories provider
                            final isAdded =
                                Provider.of<CategoriesProvider>(context)
                                    .updateCategory(
                                        index, _newCategoryController.text);
                            if (!isAdded) {
                              addingAlertDialog(context, 'An error occured!',
                                  'This Category is Already here!');
                            } else {
                              // change category name in all notes
                              Provider.of<NotesProvider>(context)
                                  .updateNotesCategory(_initialValue,
                                      _newCategoryController.text);
                              // remove this category from all notes
                              Provider.of<NotesProvider>(context)
                                  .categoryDeleted(_initialValue);
                              // then view all notes to the user
                              Provider.of<NotesProvider>(context)
                                  .updateCategory('All Notes');
                            }
                          },
                        ),
                      ],
                    ));
          },
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete this dialog after confirmation from user with alert dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Are you sure ?'),
                  content: Text('This Category will be deleted!'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // remove this category from all notes
                        Provider.of<NotesProvider>(context)
                            .categoryDeleted(category.items[index].name);
                        // then delete the category
                        Provider.of<CategoriesProvider>(context)
                            .deleteCategory(index);
                        // then view all notes to the user
                        Provider.of<NotesProvider>(context)
                            .updateCategory('All Notes');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void addingAlertDialog(BuildContext context, String title, String subtitle) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }
}
