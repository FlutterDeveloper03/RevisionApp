// ignore_for_file: file_names

import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

//region Events
abstract class LanguageEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LanguageLoadStarted extends LanguageEvent {}

class LanguageSelected extends LanguageEvent {
  final String languageCode;

  LanguageSelected(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}
//endRegion Events

//region States

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

//endRegion

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  String loadedLanguageCode = 'tk';

  LanguageBloc() : super(const LanguageState(Locale('tk', 'TM'))){
    on<LanguageLoadStarted>(_mapLanguageLoadStartedToState);
    on<LanguageSelected>(_mapLanguageSelectedToState);
  }

  void _mapLanguageSelectedToState(LanguageSelected event, Emitter<LanguageState> emit) async {
    final sharedPref = await SharedPreferences.getInstance();
    loadedLanguageCode = sharedPref.getString('language') ?? "tk";
    Locale locale;
    if (event.languageCode == 'en' && loadedLanguageCode != 'en') {
      locale = const Locale('en', 'US');
      await sharedPref.setString('language', locale.languageCode);
      emit(LanguageState(locale));
    } else if (event.languageCode == 'ru' && loadedLanguageCode != 'ru') {
      locale = const Locale ('ru', 'RU');
      await sharedPref.setString('language', locale.languageCode);
      emit(LanguageState(locale));
    } else if (event.languageCode == 'tk' && loadedLanguageCode != 'tk') {
      locale = const Locale('tk', 'TM');
      await sharedPref.setString('language', locale.languageCode);
      emit(LanguageState(locale));
    }
  }

  void _mapLanguageLoadStartedToState(LanguageLoadStarted event, Emitter<LanguageState> emit) async {
    final sharedPref = await SharedPreferences.getInstance();
    loadedLanguageCode = sharedPref.getString('language') ?? "tk";

    Locale locale;
    locale = Locale(loadedLanguageCode);
    emit(LanguageState(locale));
  }
}