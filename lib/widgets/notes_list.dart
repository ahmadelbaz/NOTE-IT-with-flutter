import 'package:flutter/material.dart';
import '../providers/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_item.dart';
import 'package:provider/provider.dart';

class NotesList extends StatefulWidget {
  final String typeOfData;

  NotesList(this.typeOfData);

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();
    try {
      Provider.of<NotesProvider>(context, listen: false).fetchData().then((_) {
        _isLoading = false;
      });
    } catch (error) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occured!'),
                content: Text('Something went wrong!\n$error'),
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

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final notesData = Provider.of<NotesProvider>(context);
    List<Note> notesList = notesData.items;
    if (widget.typeOfData == 'fav') {
      notesList = notesData.favItems;
    }
    return Provider.of<NotesProvider>(context, listen: false).items.length < 1
        ? Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.note_add,
                    size: deviceSize.width * .5,
                  ),
                  Text('No Notes... Write One!')
                ],
              ),
            ),
          )
        : _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).accentColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin:
                    EdgeInsets.symmetric(horizontal: deviceSize.width * .06),
                child: ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: ((ctx, index) {
                    return ChangeNotifierProvider.value(
                      value: notesList[index],
                      child: NoteItem(
                        notesList[index].id,
                        notesList[index].title,
                        notesList[index].describtion,
                        notesList[index].dateTime,
                        index,
                      ),
                    );
                  }),
                ),
              );
  }
}
