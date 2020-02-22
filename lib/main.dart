import 'package:flutter/material.dart';
import './providers/auth_provider.dart';
import './providers/categories_provider.dart';
import './providers/notes_provider.dart';
import './screens/about_developer_screen.dart';
import './screens/auth-screen.dart';
import './screens/categories_screen.dart';
import './screens/edit_notes_screen.dart';
import './screens/tab_screen.dart';

import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
          ChangeNotifierProvider.value(
            value: CategoriesProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, NotesProvider>(
            builder: (ctx, auth, notesProvider) => NotesProvider(
                auth.isValidToken,
                auth.isValidUser,
                notesProvider == null ? [] : notesProvider.items),
          ),
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => ThemeProvider(
            saveThemesOnChange: true,
            loadThemeOnInit: true,
            themes: <AppTheme>[
              AppTheme.dark().copyWith(
                data: ThemeData(
                  fontFamily: 'Montserrat',
                  brightness: Brightness.dark,
                ),
                id: "default_dark_theme",
                description: "Android Default Dark Theme",
              ),
              customAppTheme(),
              customOldAppTheme(),
            ],
            child: MaterialApp(
              theme: ThemeData(
                // Define the default brightness and colors.
                brightness: Brightness.dark,

                // Define the default font family.
                fontFamily: 'Montserrat',
              ),
              debugShowCheckedModeBanner: false,
              title: 'Note It',
              home: ThemeConsumer(child: TabScreen()),
              routes: {
                AuthScreen.routeKey: (ctx) =>
                    auth.isAuth ? '/' : ThemeConsumer(child: AuthScreen()),
                EditNotesScreen.routeKey: (ctx) =>
                    ThemeConsumer(child: EditNotesScreen()),
                AboutDeveloper.routeKey: (ctx) =>
                    ThemeConsumer(child: AboutDeveloper()),
                CategoriesScreen.routeKey: (ctx) =>
                    ThemeConsumer(child: CategoriesScreen()),
              },
            ),
          ),
        ));
  }
}

AppTheme customAppTheme() {
  return AppTheme(
    id: "light_theme",
    description: "Default Light Theme",
    data: ThemeData(
      fontFamily: 'Montserrat',
      accentColor: Colors.amber,
      primaryColor: Colors.blue,
      buttonColor: Colors.amber,
      dialogBackgroundColor: Colors.yellow[100],
    ),
  );
}

AppTheme customOldAppTheme() {
  return AppTheme(
    id: "pink_theme",
    description: "Pink-White Scheme",
    data: ThemeData(
      fontFamily: 'Montserrat',
      accentColor: Colors.blue,
      primaryColor: Colors.pink,
      buttonColor: Colors.blue,
      dialogBackgroundColor: Colors.yellow[100],
    ),
  );
}
