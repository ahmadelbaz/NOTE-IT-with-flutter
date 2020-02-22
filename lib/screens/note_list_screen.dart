import 'package:flutter/material.dart';
import '../providers/notes_provider.dart';
import '../widgets/notes_list.dart';
import 'package:provider/provider.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';

// The Home screen of the app that show list of user notes

class NoteListScreen extends StatelessWidget {
  final String typeOfData;

  NoteListScreen(this.typeOfData);

  Future<void> _refreshToFetch(BuildContext context) async {
    await Provider.of<NotesProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Please click BACK again to exit'),
        ),
        child: RefreshIndicator(
            onRefresh: () => _refreshToFetch(context),
            child: NotesList(typeOfData)),
      ),
    );
  }
}
