import 'package:flutter/material.dart';
import '../presentation/provider_list_screen/provider_list_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/provider_registration_screen/provider_registration_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/service_categories_screen/service_categories_screen.dart';
import '../presentation/provider_detail_screen/provider_detail_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String providerList = '/provider-list-screen';
  static const String splash = '/splash-screen';
  static const String providerRegistration = '/provider-registration-screen';
  static const String authentication = '/authentication-screen';
  static const String serviceCategories = '/service-categories-screen';
  static const String providerDetail = '/provider-detail-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    providerList: (context) => const ProviderListScreen(),
    splash: (context) => const SplashScreen(),
    providerRegistration: (context) => const ProviderRegistrationScreen(),
    authentication: (context) => const AuthenticationScreen(),
    serviceCategories: (context) => const ServiceCategoriesScreen(),
    providerDetail: (context) => const ProviderDetailScreen(),
    // TODO: Add your other routes here
  };
}
