// import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/icons/thanos_icons.dart';

IconData iconMap(String type) {
  switch (type) {
    case 'INVESTMENT':
      return ThanosIcons.productsInvestments;
    case 'INSURANCE':
      return ThanosIcons.productsInsuranceHealth;
    case 'MORTGAGE':
      return ThanosIcons.productsMortgages;
    case 'INVESTMENT_FUND':
      return ThanosIcons.productsInvestmentFunds;
    case 'BUSINESS_LOAN':
      return ThanosIcons.productsLoansBusiness;
    case 'PENSION_PLAN':
      return ThanosIcons.productsPenstionPlans;
    case 'SHORT_TERM':
      return ThanosIcons.productsInvestmentsShortTerm;
    case 'MEDIUM_TERM':
      return ThanosIcons.productsInvestmentsMediumTerm;
    case 'LONG_TERM':
      return ThanosIcons.productsInvestmentsLongTerm;
    case 'HOME':
      return ThanosIcons.productsMortgages;
    case 'CAR':
      return ThanosIcons.productsInsuranceCar;
    case 'HEALTH':
      return ThanosIcons.productsInsuranceHealth;
    case 'PET':
      return ThanosIcons.productsInsurancePets;
    case 'PHONE':
      return ThanosIcons.productsInsurancePhone;
    default:
      return ThanosIcons.productsInvestments;
  }
}
