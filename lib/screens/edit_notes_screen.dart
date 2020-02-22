import 'package:flutter/material.dart';
import '../providers/categories_provider.dart';
import '../providers/note.dart';
import '../providers/notes_provider.dart';

import '../screens/select_category_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class EditNotesScreen extends StatefulWidget {
  static const routeKey = '/edit-note-screen';

  @override
  _EditNotesScreenState createState() => _EditNotesScreenState();
}

class _EditNotesScreenState extends State<EditNotesScreen> {
  final _descriptionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _newNote = Note(
    id: null,
    title: '',
    describtion: '',
    dateTime: DateTime.now(),
    isFavorite: false,
    category: [''],
  );
  var _initValues = {
    'title': '',
    'describtion': '',
  };
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  DateTime userTime = DateTime.now();
  var _psController = TextEditingController();

  var _isInit = true;

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  var _isLoading = false;
  var _isLocked = false;

//***************************************************************

  @override
  void initState() {
    super.initState();
    Provider.of<CategoriesProvider>(context, listen: false).fetchData();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  showNotification() async {
    String groupKey = 'com.android.example.WORK_EMAIL';
    String groupChannelId = 'grouped channel id';
    String groupChannelName = 'grouped channel name';
    String groupChannelDescription = 'grouped channel description';
    int noteId = 0;
    var prefs = await SharedPreferences.getInstance();
    noteId = prefs.getInt('channel');
    if (prefs.getInt('channel') == 10) {
      prefs.setInt('channel', 0);
    } else {
      prefs.setInt('channel', noteId + 1);
    }

    // First notification
    AndroidNotificationDetails firstNotificationAndroidSpecifics =
        new AndroidNotificationDetails(
            groupChannelId, groupChannelName, groupChannelDescription,
            importance: Importance.Max,
            priority: Priority.High,
            groupKey: groupKey);
    NotificationDetails firstNotificationPlatformSpecifics =
        new NotificationDetails(firstNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.schedule(noteId, _newNote.title,
        _psController.text, userTime, firstNotificationPlatformSpecifics);
  }

  Future onSelectNotification(String payload) async {
    // You can add here any thing to happen after selecting the notification from the user
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final noteId = ModalRoute.of(context).settings.arguments as String;
      if (noteId != null) {
        _newNote =
            Provider.of<NotesProvider>(context, listen: false).findById(noteId);
        _initValues = {
          // 'id': _newNote.id,
          'title': _newNote.title,
          'describtion': _newNote.describtion,
        };
      }
    }
    _isInit = false;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState.save();
    if (_newNote.id != null) {
      await Provider.of<NotesProvider>(context, listen: false)
          .updateNote(_newNote.id, _newNote);
    } else {
      try {
        await Provider.of<NotesProvider>(context, listen: false)
            .addNewNote(_newNote)
            .then((_) {
          setState(() {
            _isLoading = true;
          });
        });
      } catch (error) {
        await showDialog(
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
    }
    Navigator.of(context).pop();
  }

  Future<void> addNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(new Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Note It'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // show dialog to user to add his own note with the current title
              // and to confirm on this reminder
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('Add Reminder'),
                        content: TextField(
                          autofocus: true,
                          controller: _psController,
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
                              // add Date & time picker
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime.now(),
                                  maxTime:
                                      DateTime.now().add(Duration(days: 180)),
                                  onConfirm: (date) {
                                userTime = date;
                                showNotification();
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                          ),
                        ],
                      ));
            },
//            showNotification,
            icon: Icon(Icons.notifications),
            tooltip: 'Add Reminder',
          ),
          IconButton(
            tooltip: 'Reading Mode',
            onPressed: () {
              setState(() {
                _isLocked = !_isLocked;
                if(_isLocked == false){
                  print(_isLocked);
                  FocusScope.of(context)
                      .requestFocus(_descriptionFocusNode);
                }
              });
            },
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open),
          ),
          IconButton(
            tooltip: 'Categories',
            icon: Icon(Icons.category),
            onPressed: () async {
              final thenResult = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SelectCategoryScreen(
                      ModalRoute.of(context).settings.arguments),
                ),
              );
              _newNote.category = thenResult;
            },
          ),
          IconButton(
            tooltip: 'Save',
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(deviceSize.width * 0.025),
                        child: TextFormField(
                          enabled: _isLocked ? false : true,
                          initialValue: _initValues['title'],
                          onChanged: (value) {
                            _newNote = Note(
                              title: value,
                              describtion: _newNote.describtion,
                              id: _newNote.id,
                              isFavorite: _newNote.isFavorite,
                              dateTime: _newNote.dateTime,
                              category: _newNote.category,
                            );
                          },
//                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide(),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          textCapitalization: TextCapitalization.sentences,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter note title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _newNote = Note(
                              title: value,
                              describtion: _newNote.describtion,
                              id: _newNote.id,
                              isFavorite: _newNote.isFavorite,
                              dateTime: _newNote.dateTime,
                              category: _newNote.category,
                            );
                          },
                        ),
                      ),
                      TextFormField(
                        enabled: _isLocked ? false : true,
                        initialValue: _initValues['describtion'],
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(),
                          ),
                        ),
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _newNote = Note(
                            title: _newNote.title,
                            describtion: value,
                            id: _newNote.id,
                            isFavorite: _newNote.isFavorite,
                            dateTime: _newNote.dateTime,
                            category: _newNote.category,
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Switch Favorite',
                        icon: Icon(_newNote.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        onPressed: () {
                          setState(() {
                            _newNote.isFavorite = !_newNote.isFavorite;
                          });
                        },
                      ),
                    ],
                  )),
            ),
    );
  }
}
