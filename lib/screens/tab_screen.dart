import 'package:flutter/material.dart';
import '../providers/notes_provider.dart';
import '../screens/edit_notes_screen.dart';
import '../screens/note_list_screen.dart';
import '../widgets/main_drawer.dart';
import 'package:provider/provider.dart';

// Home screen that allow user to switch between all notes and favorite notes
class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _selectedIndex = 0;


  List<Map<String, Object>> _pages = List(2);

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _pages = [
      {'page': NoteListScreen('all'), 'title': Provider.of<NotesProvider>(context).dataType},
      {'page': NoteListScreen('fav'), 'title': 'Favorits'}
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Icon customIcon = Icon(Icons.search);
  Widget customWidget = Text('Note It');

  var isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: isSearch ? customWidget : Text(_pages[_selectedIndex]['title']),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              isSearch = !isSearch;
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = Icon(Icons.cancel);
                  customWidget = TextField(
                    onChanged: (userInput) {
                      Provider.of<NotesProvider>(context)
                          .searchNotes(userInput);
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Search...'),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                } else {
                  customIcon = Icon(Icons.search);
                  customWidget = Text('Note It');
                  Provider.of<NotesProvider>(context).stopSearching();
                }
              });
            },
            icon: customIcon,
          ),
          IconButton(
            tooltip: 'Rearrange',
            icon: Icon(Icons.list),
            onPressed: () {
              Provider.of<NotesProvider>(context, listen: false).reverseList();
            },
          ),
          IconButton(
            tooltip: 'Add Note',
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditNotesScreen.routeKey);
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        selectedIconTheme: IconThemeData(color: Theme.of(context).accentColor),
        selectedItemColor: Theme.of(context).accentColor,
        unselectedItemColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.category,
            ),
            title: Text(
              Provider.of<NotesProvider>(context).dataType,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
            ),
            title: Text('Favorites'),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(EditNotesScreen.routeKey);
          },
        )
    );
  }
}
