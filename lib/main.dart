// main.dart — VERSION ANDROID/iOS
import 'package:flutter/material.dart';
import './database/create_table/create_table_temoin.dart';
import 'routers/router.dart';
import 'widgets/global/app_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await CreateTableTemoin.init();
  } catch (e, stack) {
    debugPrint('ERREUR INIT DB: $e');
    debugPrint('STACK: $stack');
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                     'Mon Application',
      debugShowCheckedModeBanner: false,
      theme:                     buildAppTheme(),
      routerConfig:              router,
    );
  }
}
