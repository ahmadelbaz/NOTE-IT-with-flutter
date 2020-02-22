import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:flutter/cupertino.dart';
import 'package:note/providers/note.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

class NotesProvider with ChangeNotifier {
  String token;
  String userId;

  NotesProvider([this.token, this.userId, this._notesList]);

  var uuid = Uuid();
  List<Note> _notesList = [];
  List<Note> _backupNotesList = [];
  bool isReversed = false;
  String dataType = 'All Notes';

  Future<void> reverseValue() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('reversed')) {
      isReversed = prefs.getBool('reversed');
    } else {
      isReversed = false;
    }
  }

  void updateCategory(String typeOfData) {
    dataType = typeOfData;
    notifyListeners();
  }

  void updateNotesCategory(String categoryName, String newName) {
    for (int n = 0; n < _notesList.length; n++) {
      if (_notesList[n].category.contains(categoryName)) {
        int nn = _notesList[n].category.indexOf(categoryName);
        print(_notesList[n].category[nn]);
        _notesList[n].category[nn] = newName; //.removeAt(nn);
      }
    }
    addToSharedpreferences();
    notifyListeners();
  }

  List<Note> get items {
    reverseValue();
    if (isReversed) {
      _notesList.sort((a, b) {
        var adate = a.dateTime; //before -> var adate = a.expiry;
        var bdate = b.dateTime; //var bdate = b.expiry;
        return -bdate.compareTo(adate);
      });
      if (dataType == 'All Notes') {
        return [..._notesList];
      } else if (dataType == 'fav') {
        return [..._notesList.where((note) => note.isFavorite).toList()];
      } else {
        return [
          ..._notesList
              .where((note) => note.category.contains(dataType))
              .toList()
        ];
      }
    } else {
      _notesList.sort((a, b) {
        var adate = a.dateTime; //before -> var adate = a.expiry;
        var bdate = b.dateTime; //var bdate = b.expiry;
        return -adate.compareTo(bdate);
      });
      if (dataType == 'All Notes') {
        return [..._notesList];
      } else if (dataType == 'fav') {
        return [..._notesList.where((note) => note.isFavorite).toList()];
      } else {
        return [
          ..._notesList
              .where((note) => note.category.contains(dataType))
              .toList()
        ];
      }
    }
  }

  List<Note> get favItems {
    reverseValue();
    if (isReversed) {
      _notesList.sort((a, b) {
        var adate = a.dateTime; //before -> var adate = a.expiry;
        var bdate = b.dateTime; //var bdate = b.expiry;
        return -bdate.compareTo(adate);
      });
      return [..._notesList.where((note) => note.isFavorite).toList()];
    } else {
      _notesList.sort((a, b) {
        var adate = a.dateTime; //before -> var adate = a.expiry;
        var bdate = b.dateTime; //var bdate = b.expiry;
        return -adate.compareTo(bdate);
      });
    }
    return [..._notesList.where((note) => note.isFavorite).toList()];
  }

  bool isFavoriteSelected(String id) {
    int currentIndex = _notesList.indexWhere((nt) => nt.id == id);
    return _notesList[currentIndex].isFavorite;
  }

  int get notesLength {
    return _notesList.length;
  }

  Note findById(String id) {
    return _notesList.firstWhere((note) => note.id == id);
  }

  Future<void> reverseList() async {
    isReversed = !isReversed;
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('reversed', isReversed);
    notifyListeners();
  }

  String generateRandomNum() {
    String finalRandom =
        uuid.v4(options: {'date': DateTime.now().toIso8601String()});
    for (int n = 0; n < _notesList.length; n++) {
      if (_notesList[n].id == finalRandom) {
        finalRandom = uuid.v4();
      }
    }
    return finalRandom;
  }

  Future<void> addNewNote(Note note) async {
    try {
      // await reverseValue();
      _notesList.insert(
        0,
        Note(
          id: generateRandomNum(),
          title: note.title,
          describtion: note.describtion,
          dateTime: note.dateTime,
          isFavorite: note.isFavorite,
          category: note.category,
        ),
      );
      addToSharedpreferences();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchData() async {
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('channel')) {
      prefs.setInt('channel', 0);
    }
    try {
      List<Note> fetchingList = [];
      var prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('notesList')) {
        return;
      } else {
        List<String> notesAsList = prefs.getStringList('notesList');
        for (int n = 0; n < notesAsList.length; n++) {
          var newId = (notesAsList[n].split('+'))[0];
          var newTitle = (notesAsList[n].split('+'))[1];
          var newDescribtion = (notesAsList[n].split('+'))[2];
          var newDate = DateTime.parse((notesAsList[n].split('+'))[3]);
          var newFavoriteString = (notesAsList[n].split('+'))[4];
          var newFavorite = false;
          if (newFavoriteString == 'true') {
            newFavorite = true;
          } else {
            newFavorite = false;
          }
          List<String> newCategory = List();
          if (prefs.containsKey('categoriesList$n')) {
            newCategory = prefs.getStringList('categoriesList$n');
          } else {
            newCategory = [];
          }
          fetchingList.add(Note(
            id: newId,
            title: newTitle,
            describtion: newDescribtion,
            dateTime: newDate,
            isFavorite: (newFavorite),
            category: newCategory,
          ));
        }
        _notesList = fetchingList;
        notifyListeners();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateNote(String id, Note note) async {
    try {
      int currentIndex = _notesList.indexWhere((nt) => nt.id == note.id);
      _notesList[currentIndex] = note;
      addToSharedpreferences();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteNote(String id) async {
    int currentIndex = _notesList.indexWhere((nt) => nt.id == id);
    try {
      _notesList.removeAt(currentIndex);
      notifyListeners();
      addToSharedpreferences();
      notifyListeners();
    } catch (error) {
      notifyListeners();
      throw error;
    }
  }

  Future<void> deleteAllNotes() async {
    _notesList.clear();
    addToSharedpreferences();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    var noteIndex = _notesList.indexWhere((note) => note.id == id);
    var currentFavorite = _notesList[noteIndex].isFavorite;
    try {
      if (noteIndex >= 0) {
        _notesList[noteIndex].isFavorite = !currentFavorite;
        addToSharedpreferences();
        notifyListeners();
      }
    } catch (error) {
      _notesList[noteIndex].isFavorite = currentFavorite;
    }
  }

  Future<void> backupData() async {
    try {
      final url =
          'ADD YOUR_API';

      await http.post(
        url,
        body: json.encode(
          _notesList
              .map((map) => {
                    'id': map.id,
                    'title': map.title,
                    'describtion': map.describtion,
                    'isFavorite': map.isFavorite,
                    'dateTime': map.dateTime.toIso8601String(),
                  })
              .toList(),
        ),
      );
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> restoreData() async {
    try {
      List<Note> fetchingList = _notesList;

      final url =
          'ADD YOUR_API';
      // --------------------------------------------------------------------
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final userData = json.decode(
        prefs.getString('userData'),
      ) as Map<String, Object>;
      final expiryDate = DateTime.parse(userData['expireDate']);

      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      token = userData['token'];
      userId = userData['userId'];

      // -----------------------------------------------------------------
      final response = await http.get(url);
      var currentMap = json.decode(response.body) as Map<String, dynamic>;
      if (currentMap == null) {
        return;
      }
      currentMap.values.toList()[0].forEach((noteData) {
        fetchingList.add(Note(
          id: noteData['id'],
          title: noteData['title'],
          describtion: noteData['describtion'],
          dateTime: DateTime.parse(noteData['dateTime']),
          isFavorite: noteData['isFavorite'],
        ));
      });
      _notesList = fetchingList;
      addToSharedpreferences();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addToSharedpreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('notesList');
    List<String> notesAsList = [];
    List<String> categoriesAsList = [];
    for (int n = 0; n < _notesList.length; n++) {
      String data =
          '${_notesList[n].id}+${_notesList[n].title}+${_notesList[n].describtion}+${_notesList[n].dateTime.toIso8601String()}+${_notesList[n].isFavorite}';
      notesAsList.add(data);
      categoriesAsList = _notesList[n].category;
      prefs.setStringList('categoriesList$n', categoriesAsList);
    }
    prefs.setStringList('notesList', notesAsList);
  }

  Future<void> searchNotes(String userInput) async {
    await fetchData();
    _backupNotesList = _notesList;
    _notesList = _notesList
        .where((note) =>
            note.title?.toLowerCase().contains(userInput?.toLowerCase()) ||
            note.describtion?.toLowerCase().contains(userInput?.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> stopSearching() async {
    fetchData();
    notifyListeners();
  }

  void shareNote(BuildContext context, String id) {
    int currentIndex = _notesList.indexWhere((nt) => nt.id == id);
    final RenderBox box = context.findRenderObject();
    final String text =
        '${_notesList[currentIndex].title}\n\n${_notesList[currentIndex].describtion}\n\n By \"NOTE IT\" App';
    Share.share(text,
        subject: _notesList[currentIndex].title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    notifyListeners();
  }

  void shareAllNote(BuildContext context) {
    String text = '';
    final RenderBox box = context.findRenderObject();
    for (int n = 0; n < _notesList.length; n++) {
      text +=
          'Note#${n + 1} : \n${_notesList[n].title}\n${_notesList[n].describtion}\n\n';
    }
    text += 'By \"NOTE IT\" App';
    Share.share(text,
        subject: 'My All Notes',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    print(text);
    notifyListeners();
  }

  List<bool> belongToCategory(String id, List<String> categoryList) {
    // Check if this note belongs to category
    int currentIndex = _notesList.indexWhere((nt) => nt.id == id);

    List<bool> allCat = List(categoryList.length);
    for (int n = 0; n < categoryList.length; n++) {
      if (currentIndex < 0) {
        print('Here is an index false');
        allCat[n] = false;
      } else if (_notesList[currentIndex].category == null) {
        allCat[n] = false;
        print('Here is category false');
      } else if (_notesList[currentIndex].category.contains(categoryList[n])) {
        allCat[n] = true;
      } else {
        allCat[n] = false;
      }
    }
    return allCat;
  }

  void categoryDeleted(String categoryName) {
    for (int n = 0; n < _notesList.length; n++) {
      if (_notesList[n].category.contains(categoryName)) {
        int nn = _notesList[n].category.indexOf(categoryName);
        print(_notesList[n].category[nn]);
        _notesList[n].category.removeAt(nn);
      }
    }
    addToSharedpreferences();
    notifyListeners();
  }
}
