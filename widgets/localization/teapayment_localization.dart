import 'package:starter_architecture_flutter_firebase/widgets/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'teapayment_localization_controller.dart';

class TeapaymentLocalization extends StatefulWidget {
  // TODO Implement ErrorWidget
  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  // final Widget Function(FlutterError? message)? errorWidget;

  TeapaymentLocalization({
    super.key,
    required this.child,
    required this.supportedLocales,
    // required this.path,
    this.fallbackLocale,
    this.startLocale,
    this.useFallbackTranslations = false,
    // TODO Implement Asset Loader
    // this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    // TODO Implement Error widget
    // this.errorWidget,
  }) : assert(supportedLocales.isNotEmpty) {
    // TODO Implement logger
    // EasyLocalization.logger.debug('Start');
  }

  /// Place for main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  final bool useFallbackTranslations;

  // TODO Implement
  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  // final String path;

  // TODO Implement Asset Loader
  /// Class loader for localization files.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  // final assetLoader;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  @override
  State createState() => _TeapaymentLocalizationState();

  // ignore: library_private_types_in_public_api
  static _TeapaymentLocalizationProvider? of(BuildContext context) =>
      _TeapaymentLocalizationProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async =>
      TeapaymentLocalizationController.initLocalization();

  /// Customizable logger
  // static EasyLogger logger = EasyLogger(name: '🌎 Easy Localization');
}

class _TeapaymentLocalizationState extends State<TeapaymentLocalization> {
  _TeapaymentLocalizationDelegate? delegate;
  TeapaymentLocalizationController? localizationController;
  FlutterError? translationsLoadError;

  @override
  void initState() {
    // EasyLocalization.logger.debug('Init state');
    localizationController = TeapaymentLocalizationController(
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      // assetLoader: widget.assetLoader,
      // useOnlyLangCode: widget.useOnlyLangCode,
      useFallbackTranslations: widget.useFallbackTranslations,
      // path: widget.path,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO Handle error
    // EasyLocalization.logger.debug('Build');
    // if (translationsLoadError != null) {
    //   return widget.errorWidget != null
    //       ? widget.errorWidget!(translationsLoadError)
    //       : ErrorWidget(translationsLoadError!);
    // }
    return _TeapaymentLocalizationProvider(
      widget,
      localizationController!,
      delegate: _TeapaymentLocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
      ),
    );
  }
}

class _TeapaymentLocalizationProvider extends InheritedWidget {
  _TeapaymentLocalizationProvider(
    this.parent,
    this._localeState, {
    required this.delegate,
  })  : currentLocale = _localeState.locale,
        super(child: parent.child) {
    // EasyLocalization.logger.debug('Init provider');
  }
  final TeapaymentLocalization parent;
  final TeapaymentLocalizationController _localeState;
  final Locale? currentLocale;
  final _TeapaymentLocalizationDelegate delegate;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  // Future<void> deleteSaveLocale() async {
  //   await _localeState.deleteSaveLocale();
  // }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_TeapaymentLocalizationProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _TeapaymentLocalizationProvider? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_TeapaymentLocalizationProvider>();
}

class _TeapaymentLocalizationDelegate
    extends LocalizationsDelegate<Localization> {
  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _TeapaymentLocalizationDelegate({
    this.localizationController,
    this.supportedLocales,
  }) {
    // EasyLocalization.logger.debug('Init Localization Delegate');
  }
  final List<Locale>? supportedLocales;
  final TeapaymentLocalizationController? localizationController;

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    // EasyLocalization.logger.debug('Load Localization Delegate');
    if (localizationController!.translations == null) {
      await localizationController!.loadTranslations();
    }

    Localization.load(
      value,
      translations: localizationController!.translations,
      fallbackTranslations: localizationController!.fallbackTranslations,
    );
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}

extension BuildContextEasyLocalizationExtension on BuildContext {
  /// Get current locale
  Locale get locale => TeapaymentLocalization.of(this)!.locale;

  /// Change app locale
  Future<void> setLocale(Locale val) async =>
      TeapaymentLocalization.of(this)!.setLocale(val);

  /// Get List of supported locales.
  List<Locale> get supportedLocales =>
      TeapaymentLocalization.of(this)!.supportedLocales;

  /// Get fallback locale
  Locale? get fallbackLocale => TeapaymentLocalization.of(this)!.fallbackLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// return
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates =>
      TeapaymentLocalization.of(this)!.delegates;

  /// Clears a saved locale from device storage
  // Future<void> deleteSaveLocale() =>
  //     Localizations.of(this)!.deleteSaveLocale();

  /// Getting device locale from platform
  Locale get deviceLocale => TeapaymentLocalization.of(this)!.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => TeapaymentLocalization.of(this)!.resetLocale();
}

extension StringTranslateExtension on String {
  /// {@macro tr}
  String t([dynamic valuesToBeReplacedInTranslation]) {
    if (valuesToBeReplacedInTranslation is Map<String, dynamic> ||
        valuesToBeReplacedInTranslation == null) {
      return Localization.instance.t(this, valuesToBeReplacedInTranslation);
    }
    throw Exception(
      'Values to be replaced in translation key "$this" doesn\'t have a Map<String, dynamic> type.',
    );
  }
}
