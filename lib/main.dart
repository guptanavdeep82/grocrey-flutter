import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_grocery/common/enums/data_source_enum.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/features/order/providers/image_note_provider.dart';
import 'package:flutter_grocery/features/order_track/providers/tracker_provider.dart';
import 'package:flutter_grocery/features/review/providers/review_provider.dart';
import 'package:flutter_grocery/firebase_options.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/home/providers/banner_provider.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/chat/providers/chat_provider.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
import 'package:flutter_grocery/common/providers/language_provider.dart';
import 'package:flutter_grocery/common/providers/localization_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/common/providers/news_letter_provider.dart';
import 'package:flutter_grocery/features/notification/providers/notification_provider.dart';
import 'package:flutter_grocery/features/onboarding/providers/onboarding_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/search/providers/search_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/common/providers/theme_provider.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/providers/wallet_provider.dart';
import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_grocery/theme/dark_theme.dart';
import 'package:flutter_grocery/theme/light_theme.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/common/widgets/third_party_chat_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'di_container.dart' as di;
import 'helper/notification_helper.dart';
import 'localization/app_localization.dart';
import 'common/widgets/cookies_widget.dart';
import 'package:universal_html/html.dart' as html;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

late AndroidNotificationChannel channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print(details.exceptionAsString());
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('$error\n$stack');
    }
    return true;
  };

  try {
    await _bootstrap();
  } catch (e, stack) {
    runApp(_LaunchErrorApp(error: e, stack: stack));
  }
}

Future<void> _bootstrap() async {
  setPathUrlStrategy();

  // ✅ Replace your current try/catch with this
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      if (kDebugMode) print('Firebase init error: $e');
    }
  } catch (e) {
    if (kDebugMode) print('Firebase init error: $e');
  }

  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      FirebaseMessaging.instance.requestPermission();

      /// firebase crashlytics
    }
  } else {
    // Check if Firebase is already initialized before initializing again
    // try {
    //   if (Firebase.apps.isEmpty) {
    //     await Firebase.initializeApp(options: const FirebaseOptions(
    //         apiKey: "AIzaSyBCtDfdfPqxXDO6rDNlmQC1VJSHOtuyo3w",
    //         authDomain: "gem-b5006.firebaseapp.com",
    //         projectId: "gem-b5006",
    //         storageBucket: "gem-b5006.firebasestorage.app",
    //         messagingSenderId: "384321080318",
    //         appId: "1:384321080318:web:65a2e979404705cc2c0eaf"
    //     ));
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('Firebase already initialized or error: ${e.toString()}');
    //   }
    // }

    // if(AppConstants.appMode != AppMode.demo) {
    //   await FacebookAuth.instance.webAndDesktopInitialize(
    //     appId: "1216934565526698",
    //     cookie: true,
    //     xfbml: true,
    //     version: "v15.0",
    //   );
    // }
  }

  await di.init();
  try {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications', importance: Importance.high);
    }

    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      channel,
    );
  } catch (e) {
    if (kDebugMode) {
      print('error---> ${e.toString()}');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocalizationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OnBoardingProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<NewsLetterProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<WalletAndLoyaltyProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<FlashDealProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ReviewProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<VerificationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderImageNoteProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<TrackerProvider>()),
      ],
      child: MyApp(isWeb: !kIsWeb),
    ),
  );
}

class MyApp extends StatefulWidget {
  final int? orderID;
  final bool isWeb;
  const MyApp({super.key, this.orderID, required this.isWeb});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    RouteHelper.setupRouter();

    if (kIsWeb) {
      Provider.of<SplashProvider>(context, listen: false).initSharedData();
      Provider.of<CartProvider>(context, listen: false).getCartData();
      _route();
    }
  }

  void _route() {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    splashProvider.initConfig(source: DataSourceEnum.local).then((value) async {
      if (value != null) {
        splashProvider.getDeliveryInfo();
        // splashProvider.initializeScreenList(Get.context!);
        if (Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn()) {
          Provider.of<AuthProvider>(Get.context!, listen: false).updateToken();
        }
      }
      _onRemoveLoader();
    });
  }

  void _onRemoveLoader() {
    final preloader = html.document.querySelector('.preloader');
    if (preloader != null) {
      Future.delayed(const Duration(seconds: 10)).then((_) {
        preloader.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }

    return Consumer<SplashProvider>(
      builder: (context, splashProvider, child) {
        return (kIsWeb && splashProvider.configModel == null)
            ? const SizedBox()
            : MaterialApp(
                navigatorObservers: [routeObserver],
                title: splashProvider.configModel != null ? splashProvider.configModel!.ecommerceName ?? '' : AppConstants.appName,
                initialRoute: ResponsiveHelper.isMobilePhone()
                    ? widget.orderID == null
                          ? RouteHelper.getSplashRoute()
                          : RouteHelper.getOrderDetailsRoute('${widget.orderID}')
                    : RouteHelper.isMaintenance(splashProvider.configModel!)
                    ? RouteHelper.getMaintenanceRoute()
                    : RouteHelper.menu,
                onGenerateRoute: RouteHelper.router.generator,
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                theme: Provider.of<ThemeProvider>(context).darkTheme ? dark : light,
                locale: Provider.of<LocalizationProvider>(context).locale,
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: locals,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
                ),
                builder: (context, widget) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(MediaQuery.sizeOf(context).width < 380 ? 0.8 : 1)),
                  child: Material(
                    child: SafeArea(
                      top: false,
                      bottom: !kIsWeb && Platform.isAndroid,
                      child: Stack(
                        children: [
                          widget!,

                          if (ResponsiveHelper.isDesktop(context))
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                                  child: ThirdPartyChatWidget(configModel: splashProvider.configModel!),
                                ),
                              ),
                            ),
                          if (kIsWeb &&
                              splashProvider.configModel!.cookiesManagement != null &&
                              splashProvider.configModel!.cookiesManagement!.status! &&
                              !splashProvider.getAcceptCookiesStatus(splashProvider.configModel!.cookiesManagement!.content) &&
                              splashProvider.cookiesShow)
                            const Positioned.fill(
                              child: Align(alignment: Alignment.bottomCenter, child: CookiesWidget()),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}

class _LaunchErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stack;
  const _LaunchErrorApp({required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text('$error\n\n$stack', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ),
    );
  }
}
