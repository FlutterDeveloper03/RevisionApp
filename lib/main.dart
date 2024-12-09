import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:revision_app/Pages/LoginPage.dart';
import 'package:revision_app/bloc/CountedPageBloc.dart';
import 'package:revision_app/bloc/CountedProductsBloc.dart';
import 'package:revision_app/bloc/CurrentCountsPageBloc.dart';
import 'package:revision_app/bloc/LanguageBloc.dart';
import 'package:revision_app/bloc/ListDataPageBloc.dart';
import 'package:revision_app/bloc/ListPageBLoc.dart';
import 'package:revision_app/bloc/LoginPageBloc.dart';
import 'package:revision_app/bloc/MaterialBloc.dart';
import 'package:revision_app/bloc/ProductCountsPageBloc.dart';
import 'package:revision_app/bloc/SettingsPageBloc.dart';
import 'package:revision_app/bloc/UncountedProductsBloc.dart';
import 'package:revision_app/helpers/localization.dart';
import 'package:revision_app/provider/GlobalVarsProvider.dart';
import 'package:revision_app/theme.dart';

class SimpleBlocObserver extends BlocObserver{
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint(event.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint(error.toString());
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider<GlobalVarsProvider>(
    key: UniqueKey(),
    create: (context) => GlobalVarsProvider(),
    child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginPageBloc()),
          BlocProvider(create: (_) => LanguageBloc()..add(LanguageLoadStarted())),
          BlocProvider(create: (_) => SettingsPageBloc()..add(LoadSettingsPageEvent())),
          BlocProvider(create: (context) => MaterialBloc(Provider.of<GlobalVarsProvider>(context, listen: false))),
          BlocProvider(create: (_)=> ListDataPageBloc()..add(LoadListDataEvent())),
          BlocProvider(create: (context)=> ListPageBloc(Provider.of<GlobalVarsProvider>(context, listen: false))),
          BlocProvider(create: (_)=> CountedPageBloc()..add(LoadInvHeadsEvent())),
          BlocProvider(create: (context)=> CountedProductsBloc()),
          BlocProvider(create: (_)=> UncountedProductsBloc()),
          BlocProvider(create: (_)=> CurrentCountsBloc()),
          BlocProvider(create: (_)=> ProductCountsPageBloc())
        ],
        child: const MyApp()
    ),
  ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, languageState) {
                return MaterialApp(
                  home: const LoginPage(),
                  theme: themeProvider.getTheme(),
                  locale: languageState.locale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    TkMaterialLocalizations.delegate,
                    AppLocalizations.delegate
                  ],
                  supportedLocales: const [
                    Locale('en','US'),
                    Locale('ru','RU'),
                    Locale('tk','TM'),
                  ],
                );
              }
          );
        }
    );
  }
}


