import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grmilica_version_2/providers/user_provider.dart';
import 'package:grmilica_version_2/responsive/mobile_screen_layout.dart';
import 'package:grmilica_version_2/responsive/responsive_layout_screen.dart';
import 'package:grmilica_version_2/responsive/web_screen_layout.dart';
import 'package:grmilica_version_2/screens/login_screen.dart';
import 'package:grmilica_version_2/screens/signup_screen.dart';
import 'package:grmilica_version_2/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyA-ICI1zQXkCMY62-RmoKXfOK8O09DJRZs",
          projectId: "grmilica-339d7",
          messagingSenderId: "460398743675",
          appId: "1:460398743675:web:d247a217c9de1f763d12de",
          storageBucket: "grmilica-339d7.appspot.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Grmilica',
          theme: ThemeData.light()
              .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  return const ResponsiveLayout(
                    webScreenLayout: WebScreenLayout(),
                    mobileScreenLayout: MobileScreenLayout(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: primaryColor,
                ));
              }
              return const LoginScreen();
            },
          ),
        ));
  }
}
