import 'package:flutter/material.dart';
import 'helpers/StorageManager.dart';

class ThemeProvider with ChangeNotifier{
 final lightTheme = ThemeData(
  brightness: Brightness.light,
     scaffoldBackgroundColor: const Color(0xffF6F6F6),
     primaryColor: const Color(0xff01A9B4),
     cardColor: Colors.white,
     dividerColor: const Color(0xffD9D9D9),
     highlightColor: const Color(0xffC5FCFF),
   focusColor: Colors.red,
   textTheme: const TextTheme(
     bodyMedium: TextStyle(color: Colors.black)
   ),
);

 final darkTheme = ThemeData(
  brightness: Brightness.dark,
     scaffoldBackgroundColor: const Color(0xffF6F6F6),
     primaryColor: const Color(0xff01A9B4),
     cardColor: Colors.white,
     dividerColor: const Color(0xffD9D9D9),
     highlightColor: const Color(0xffC5FCFF),
   colorScheme: const ColorScheme.dark(
     onSecondaryContainer: Color(0xff0398A2)
   ),
);

ThemeData? _theme;
ThemeData? getTheme() => _theme;

ThemeProvider() {
  StorageManager.readData("theme").then((value) {
    var themeMode = value ?? 'light';
    if (themeMode == 'light') {
      _theme = lightTheme;
    } else {
      _theme = darkTheme;
    }
    notifyListeners();
  });
}


void setDarkMode() async {
  _theme = darkTheme;
  StorageManager.saveData("theme", 'dark');
  notifyListeners();
}

void setLightMode() async {
  _theme = lightTheme;
  StorageManager.saveData("theme", 'light');
  notifyListeners();
}
}