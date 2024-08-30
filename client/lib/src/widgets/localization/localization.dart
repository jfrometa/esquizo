import 'package:starter_architecture_flutter_firebase/models/translations_model.dart'
    '';
import 'package:flutter/widgets.dart';

class Localization {
  Localization();
  Translations? _translations, _fallbackTranslations;

  static Localization? _instance;
  static Localization get instance => _instance ?? (_instance = Localization());
  static Localization? of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);

  static bool load(
    Locale locale, {
    Translations? translations,
    Translations? fallbackTranslations,
  }) {
    instance._translations = translations;
    instance._fallbackTranslations = fallbackTranslations;
    return translations == null ? false : true;
  }

  String t(
    String translationKey,
    Map<String, dynamic>? valuesToBeReplacedInTranslation,
  ) {
    final translations = _translations ?? _fallbackTranslations;

    if (valuesToBeReplacedInTranslation == null) {
      String? value = translations?.get(translationKey);
      if (value.isEmpty) {
        return _fallbackTranslations?.get(translationKey) ?? translationKey;
      }

      return value;
    }

    var translatedValue = translations?.get(translationKey);
    if (translatedValue != null && translatedValue.isEmpty) {
      translatedValue =
          _fallbackTranslations?.get(translationKey) ?? translationKey;
    }

    for (var key in valuesToBeReplacedInTranslation.keys) {
      translatedValue = translatedValue?.replaceFirst(
        '{{$key}}',
        valuesToBeReplacedInTranslation[key],
      );
    }

    return translatedValue ?? translationKey;
  }
}
