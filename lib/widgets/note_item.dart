import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../screens/edit_notes_screen.dart';
import 'package:provider/provider.dart';

// the template of one note to show in the list of the notes
class NoteItem extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int index;

  NoteItem(this.id, this.title, this.description, this.dateTime, this.index);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final note = Provider.of<NotesProvider>(context, listen: false);
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure ?'),
            content: Text('This note will be deleted!'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  return Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  return Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        note.deleteNote(id);
      },
      child: Column(
        children: <Widget>[
          Container(
            margin:  EdgeInsets.all(deviceSize.width * 0.02),
            padding: EdgeInsets.all(deviceSize.width * 0.009),
            child: ListTile(
                onTap: () {
                  // stop searching if user was, to avoid problems like removing any notes
                  Provider.of<NotesProvider>(context).stopSearching();

                  // Navigate to editScreen to edit that note
                  Navigator.of(context)
                      .pushNamed(EditNotesScreen.routeKey, arguments: id)
                      .then((_) {
                    Provider.of<NotesProvider>(context).fetchData();
                  });
                },

                // if user used long press it will let him share this note externally
                // or copy it to clipboard
                onLongPress: () {
                  Provider.of<NotesProvider>(context).shareNote(context, id);
                },
                title: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: deviceSize.width * 0.045,
                  ),
                ),
                // added max lines to subtitle to format the item.
                subtitle: Text(
                  description,
                  maxLines: 1,
                ),
                // using intel lib to format the date in two lines,
                // First line has the date, second line has the time.
                trailing: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Text('${DateFormat.yMMMd().format(dateTime)}\n'),
                    ),
                    Flexible(
                      flex: 1,
                      child: Consumer<NotesProvider>(
                        builder: (c, note, child) => IconButton(
                          color: Theme.of(context).accentColor,
                          icon: Icon(note.isFavoriteSelected(id)
                              ? Icons.favorite
                              : Icons.favorite_border),
                          onPressed: () {
                            note.toggleFavorite(id);
                          },
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          // Divider to separate between items
          Divider(),
        ],
      ),
    );
  }
}
