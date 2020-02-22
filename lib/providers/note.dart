// the class of the note that has the data of each note
import 'package:flutter/foundation.dart';

class Note with ChangeNotifier {
  final String id;
  final String title;
  final String describtion;
  final DateTime dateTime;
  List<String> category;
  bool isFavorite;

  Note({
    @required this.id,
    @required this.title,
    @required this.describtion,
    @required this.dateTime,
    @required this.category,
    @required this.isFavorite,
  });
}
