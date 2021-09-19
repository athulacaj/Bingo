import 'dart:async';

import 'package:bingo/screens/GameScreen/scoreCalculator.dart';
import 'package:bingo/utility/gameCompProvider.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'screens/GameScreen/gameScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/StreamHome.dart';
import 'screens/StreamSocket.dart';
import 'test.dart';
import 'utility/gameControllerProvider.dart';
import 'utility/gameUserProvider.dart';

main() async {
  // connectAndListen();
  WidgetsFlutterBinding.ensureInitialized();
  FlareCache.doesPrune = false;
  preCache();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => GameControllerProvider()),
    ChangeNotifierProvider(create: (context) => GameUserProvider()),
    ChangeNotifierProvider(create: (context) => GameComputerProvider()),
    ChangeNotifierProvider(create: (context) => ScoreCalculator()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClearIt server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xff7f86ff),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        tabBarTheme: TabBarTheme(
            labelColor: Colors.black, unselectedLabelColor: Colors.grey),
      ),

      // home: GameScreen(),
      initialRoute: '/HomeScreen',
      routes: {
        '/HomeScreen': (context) => HomeScreen(),
        '/StreamHomeScreen': (context) => StreamHomeScreen(),
      },
    );
  }
}

void preCache() async {
  await cachedActor(
    AssetFlare(bundle: rootBundle, name: 'assets/flare/firework.flr'),
  );

  // await cachedActor(
  //   AssetFlare(bundle: rootBundle, name: 'images/coin.flr'),
  // );
}
