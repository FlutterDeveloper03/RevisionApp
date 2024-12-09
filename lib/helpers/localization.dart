import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations>  delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/language/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String? translate(String key) {
    return _localizedStrings[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'tk'].contains(locale.languageCode);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async{
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// MaterialLocalizations delegate for tk-TM language ///////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//region MaterialLocalization
class _TkMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _TkMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tk'].contains(locale.languageCode);
  }

  @override
  Future<MaterialLocalizations> load (Locale locale) async {
    const String localeName = 'en_US';
    return SynchronousFuture<MaterialLocalizations>(
      TkMaterialLocalizations(
        localeName: localeName,
        fullYearFormat: intl.DateFormat('y', localeName),
        compactDateFormat: intl.DateFormat('yMd', localeName),
        shortDateFormat: intl.DateFormat('yMMMd', localeName),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', localeName),
        longDateFormat: intl.DateFormat('EEEE, MMMMM d, y', localeName),
        yearMonthFormat: intl.DateFormat('MMMM y', localeName),
        shortMonthDayFormat: intl.DateFormat('MMM d'),
        decimalFormat: intl.NumberFormat('#,##0.###', localeName),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', localeName),
      ),
    );
  }

  @override
  bool shouldReload(_TkMaterialLocalizationsDelegate old) {
    return false;
  }
}

class TkMaterialLocalizations extends GlobalMaterialLocalizations {
  const TkMaterialLocalizations({
    super.localeName = 'tk',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  static const LocalizationsDelegate<MaterialLocalizations> delegate = _TkMaterialLocalizationsDelegate();

  @override
  String get alertDialogLabel => 'Alert';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get backButtonTooltip => 'Yza';

  @override
  String get calendarModeButtonLabel => 'Kalendara geç';

  @override
  String get cancelButtonLabel => 'CANCEL';

  @override
  String get closeButtonLabel => 'Ýap';

  @override
  String get closeButtonTooltip => 'Ýap';

  @override
  String get collapsedIconTapHint => 'Expand';

  @override
  String get continueButtonLabel => 'Dowam et';

  @override
  String get copyButtonLabel => 'Kopýala';

  @override
  String get cutButtonLabel => 'Kesip al';

  @override
  String get dateHelpText => 'dd.mm.YYYY';

  @override
  String get dateInputLabel => 'Senäni giriz';

  @override
  String get dateOutOfRangeLabel => 'Out of range.';

  @override
  String get datePickerHelpText => 'Senäni saýla';

  @override
  String get dateRangeEndLabel => 'Soňky senesi';

  @override
  String get dateRangePickerHelpText => 'Aralyk saýla';

  @override
  String get dateRangeStartDateSemanticLabelRaw => r'Baş sene $fullDate';

  @override
  String get dateRangeStartLabel => 'Baş sene';

  @override
  String get dateSeparator => '/';

  @override
  String get dialModeButtonLabel => 'Switch to dial picker mode';

  @override
  String get dialogLabel => 'Dialog';

  @override
  String get drawerLabel => 'Navigation menu';

  @override
  String get expandedIconTapHint => 'Collapse';

  @override
  String get firstPageTooltip => 'First page';

  @override
  String get hideAccountsLabel => 'Hide accounts';

  @override
  String get inputDateModeButtonLabel => 'Switch to input';

  @override
  String get inputTimeModeButtonLabel => 'Switch to text input mode';

  @override
  String get invalidDateFormatLabel => 'Nädogry görnüş.';

  @override
  String get invalidDateRangeLabel => 'Nädogry aralyk.';

  @override
  String get invalidTimeLabel => 'Dogry wagty ýaz';

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyAltGraph => 'AltGr';

  @override
  String get keyboardKeyBackspace => 'Backspace';

  @override
  String get keyboardKeyCapsLock => 'Caps Lock';

  @override
  String get keyboardKeyChannelDown => 'Channel Down';

  @override
  String get keyboardKeyChannelUp => 'Channel Up';

  @override
  String get keyboardKeyControl => 'Ctrl';

  @override
  String get keyboardKeyDelete => 'Del';

  @override
  String get keyboardKeyEject => 'Eject';

  @override
  String get keyboardKeyEnd => 'End';

  @override
  String get keyboardKeyEscape => 'Esc';

  @override
  String get keyboardKeyFn => 'Fn';

  @override
  String get keyboardKeyHome => 'Home';

  @override
  String get keyboardKeyInsert => 'Insert';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyMetaMacOs => 'Command';

  @override
  String get keyboardKeyMetaWindows => 'Win';

  @override
  String get keyboardKeyNumLock => 'Num Lock';

  @override
  String get keyboardKeyNumpad0 => 'Num 0';

  @override
  String get keyboardKeyNumpad1 => 'Num 1';

  @override
  String get keyboardKeyNumpad2 => 'Num 2';

  @override
  String get keyboardKeyNumpad3 => 'Num 3';

  @override
  String get keyboardKeyNumpad4 => 'Num 4';

  @override
  String get keyboardKeyNumpad5 => 'Num 5';

  @override
  String get keyboardKeyNumpad6 => 'Num 6';

  @override
  String get keyboardKeyNumpad7 => 'Num 7';

  @override
  String get keyboardKeyNumpad8 => 'Num 8';

  @override
  String get keyboardKeyNumpad9 => 'Num 9';

  @override
  String get keyboardKeyNumpadAdd => 'Num +';

  @override
  String get keyboardKeyNumpadComma => 'Num ,';

  @override
  String get keyboardKeyNumpadDecimal => 'Num .';

  @override
  String get keyboardKeyNumpadDivide => 'Num /';

  @override
  String get keyboardKeyNumpadEnter => 'Num Enter';

  @override
  String get keyboardKeyNumpadEqual => 'Num =';

  @override
  String get keyboardKeyNumpadMultiply => 'Num *';

  @override
  String get keyboardKeyNumpadSubtract => 'Num -';

  @override
  String get keyboardKeyPageDown => 'PgDown';

  @override
  String get keyboardKeyPageUp => 'Pg Up';

  @override
  String get keyboardKeyPower => 'Power';

  @override
  String get keyboardKeyPowerOff => 'Power Off';

  @override
  String get keyboardKeyPrintScreen => 'Print Screen';

  @override
  String get keyboardKeyScrollLock => 'Scroll Lock';

  @override
  String get keyboardKeySelect => 'Select';

  @override
  String get keyboardKeySpace => 'Space';

  @override
  String get lastPageTooltip => 'Soňky sahypa';

  @override
  String? get licensesPackageDetailTextFew => null;

  @override
  String? get licensesPackageDetailTextMany => null;

  @override
  String? get licensesPackageDetailTextOne => '1 license';

  @override
  String get licensesPackageDetailTextOther => r'$licenseCount licenses';

  @override
  String? get licensesPackageDetailTextTwo => null;

  @override
  String? get licensesPackageDetailTextZero => 'No licenses';

  @override
  String get licensesPageTitle => 'Licenses';


  @override
  String get modalBarrierDismissLabel => 'Dismiss';

  @override
  String get nextMonthTooltip => 'Indiki aý';

  @override
  String get nextPageTooltip => 'Indiki sahypa';

  @override
  String get openAppDrawerTooltip => 'Open navigation menu';

  @override
  String get pageRowsInfoTitleRaw => r'$firstRow-$lastRow of $rowCount';

  @override
  String get pageRowsInfoTitleApproximateRaw => r'$firstRow-$lastRow of about $rowCount';

  @override
  String get pasteButtonLabel => 'Ýelme';

  @override
  String get popupMenuLabel => 'Popup menu';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get previousMonthTooltip => 'Geçen aý';

  @override
  String get previousPageTooltip => 'Geçen sahypa';

  @override
  String get refreshIndicatorSemanticLabel => 'Täzele';

  @override
  String? get remainingTextFieldCharacterCountFew => null;

  @override
  String? get remainingTextFieldCharacterCountMany => null;

  @override
  String get remainingTextFieldCharacterCountOne => '1 character remaining';

  @override
  String get remainingTextFieldCharacterCountOther => r'$remainingCount characters remaining';

  @override
  String get reorderItemLeft => 'Move left';

  @override
  String get reorderItemRight => 'Move right';

  @override
  String get reorderItemToEnd => 'Move to the end';

  @override
  String get reorderItemToStart => 'Move to the start';

  @override
  String get reorderItemUp => 'Move up';

  @override
  String get rowsPerPageTitle => 'Rows per page:';

  @override
  String get saveButtonLabel => 'Ýatla';

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  @override
  String get searchFieldLabel => 'Gözle';

  @override
  String get selectAllButtonLabel => 'Ählisini saýla';

  @override
  String get selectYearSemanticsLabel => 'Select year';

  @override
  String? get selectedRowCountTitleOne => '1 item selected';

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount items selcted';

  @override
  String? get selectedRowCountTitleTwo => null;

  @override
  String? get selectedRowCountTitleZero => 'Hiç zat saýlanmady';

  @override
  String get showAccountsLabel => 'Show accounts';

  @override
  String get showMenuTooltip => 'Show menu';

  @override
  String get signedInLabel => 'Signed in';

  @override
  String get tabLabelRaw => r'Tab $tabIndex of $tabCount';

  @override
  String get timePickerDialHelpText => 'WAGT SAÝLA';

  @override
  String get timePickerHourLabel => 'Hour';

  @override
  String get timePickerHourModeAnnouncement => 'Select hours';

  @override
  String get timePickerInputHelpText => "WAGT GIRIZ";

  @override
  String get timePickerMinuteLabel => 'Minut';

  @override
  String get timePickerMinuteModeAnnouncement => 'Select minutes';

  @override
  String get unspecifiedDate => 'Sene';

  @override
  String get unspecifiedDateRange => 'Sene aralyk';

  @override
  String get viewLicensesButtonLabel => 'VIEW LICENSES';

  @override
  String get menuBarMenuLabel => 'Menu bar menu';

  @override
  String get bottomSheetLabel => 'Aşakdaky tablisa';

  @override
  String get currentDateLabel => 'Şu gün';

  @override
  String get keyboardKeyShift => 'Şift';

  @override
  String get scrimOnTapHintRaw => '';

  @override
  String get collapsedHint => 'Açyk';

  @override
  String get expandedHint => 'Ýapyk';

  @override
  String get expansionTileCollapsedHint => 'Açmak üçin iki gezek bas';

  @override
  String get expansionTileExpandedHint => 'Ýapmak üçin 2 gezek bas';

  @override
  String get expansionTileExpandedTapHint => 'Ýap';

  @override
  String get scanTextButtonLabel => 'Teksti skanirle';

  @override
  String get lookUpButtonLabel => 'Look Up';

  @override
  String get menuDismissLabel => 'Dismiss menu';

  @override
  String get searchWebButtonLabel => 'WEB Gözle';

  @override
  String get aboutListTileTitleRaw => r'Hakynda $applocationName';

  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Soňky senesi $fullDate';

  @override
  String get deleteButtonTooltip => 'Poz';

  @override
  String get expansionTileCollapsedTapHint => "Giňişleyin görmek üçin aç";

  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';

  @override
  String get keyboardKeyNumpadParenRight => 'Num )';

  @override
  String get moreButtonTooltip => "Ýene";

  @override
  String get okButtonLabel => 'OK';

  @override
  String get reorderItemDown => "Move down";

  @override
  String get scrimLabel => 'scrim';

  @override
  String get shareButtonLabel => 'Paýlaş...';

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.h_colon_mm_space_a;
}