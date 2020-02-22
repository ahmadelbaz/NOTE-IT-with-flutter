import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/notes_provider.dart';
import '../screens/about_developer_screen.dart';
import '../screens/auth-screen.dart';
import '../screens/categories_screen.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<CategoriesProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final category = Provider.of<CategoriesProvider>(context);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              leading: new Container(),
              title: Text('Note It'),
            ),
            ListTile(
              leading: Icon(Icons.note),
              title: Text(
                'Notes',
                style: TextStyle(
//                  fontFamily: 'MontserratAlternates',
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<NotesProvider>(context).updateCategory('All Notes');
              },
            ),
            // divider to split between items
            Divider(
              thickness: deviceSize.height * 0.004,
            ),
            ListTile(
              leading: Icon(
                Icons.category,
              ),
              title: Text(
                'Categories',
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(CategoriesScreen.routeKey);
              },
            ),
            ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: category.items.length,
              itemBuilder: (ctx, index) => ListTile(
                title: Text(category.items[index].name),
                onTap: () {
                  Navigator.of(context).pop();
                  Provider.of<NotesProvider>(context)
                      .updateCategory(category.items[index].name);
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
              shrinkWrap: true,
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Category'),
              onTap: () {
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
              },
            ),
            // divider to split between items
            Divider(
              thickness: deviceSize.height * 0.004,
            ),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Sign-in'),
              onTap: () async {
                Navigator.of(context).pop();
                if (Provider.of<AuthProvider>(context, listen: false).isAuth) {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('You are signed in!'),
                            content: Text(
                                'You are signed in, if you want, you can logout and sign in again'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Okay'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              )
                            ],
                          ));
                } else {
                  Navigator.of(context).pushNamed(AuthScreen.routeKey);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Backup'),
              onTap: () async {
                try {
                  Navigator.of(context).pop();
                  if (Provider.of<AuthProvider>(context, listen: false)
                      .isAuth) {
                    Provider.of<NotesProvider>(context, listen: false)
                        .backupData();
                    // Navigator.of(context).pushNamed('/');
                  } else {
                    if (await Provider.of<AuthProvider>(context, listen: false)
                        .tryLogging()) {
                      await Provider.of<NotesProvider>(context, listen: false)
                          .backupData();
                    } else {
                      Navigator.of(context).pushNamed(AuthScreen.routeKey);
                    }
                  }
                } catch (error) {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('An error occured!'),
                            content: Text('Something went wrong!'),
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
            ListTile(
              leading: Icon(Icons.restore),
              title: Text('Restore'),
              onTap: () async {
                try {
                  Navigator.of(context).pop();
                  if (Provider.of<AuthProvider>(context, listen: false)
                      .isAuth) {
                    Provider.of<NotesProvider>(context, listen: false)
                        .restoreData();
                    // Navigator.of(context).pushNamed('/');
                  } else {
                    if (await Provider.of<AuthProvider>(context, listen: false)
                        .tryLogging()) {
                      await Provider.of<NotesProvider>(context, listen: false)
                          .restoreData();
                    } else {
                      Navigator.of(context).pushNamed(AuthScreen.routeKey);
                    }
                  }
                } catch (error) {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('An error occured!'),
                            content: Text('Something went wrong!'),
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
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share All Notes'),
              onTap: () {
                Navigator.of(context).pop();
                // Share all Notes external
                Provider.of<NotesProvider>(context).shareAllNote(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep),
              title: Text('Delete All Notes'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text('Are you sure ?'),
                          content:
                              Text('All notes will be deleted, are you sure ?'),
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
                                Navigator.of(ctx).pop();
                                Provider.of<NotesProvider>(context,
                                        listen: false)
                                    .deleteAllNotes();
                              },
                            ),
                          ],
                        ));
              },
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Change Theme'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (_) => ThemeConsumer(child: ThemeDialog()));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Developer'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to Developer Profile Screen
                Navigator.of(context).pushNamed(AboutDeveloper.routeKey);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Donate'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to Developer Profile Screen
                _launchURL();
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log out'),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://www.patreon.com/ahmadelbaz';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
