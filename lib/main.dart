import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'data_entry_page.dart';
import 'dashboard_page.dart';
import 'daily_expenditure_page.dart';
import 'monthly_expenditure_page.dart';
import 'total_expenditure_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/data-entry': (context) => DataEntryPage(
              userEmail: '',
            ),
        '/dashboard': (context) => DashboardPage(
              userEmail: '',
            ),
        '/daily-expenditure': (context) => DailyExpenditurePage(
              userEmail: '',
            ),
        '/monthly-expenditure': (context) => MonthlyExpenditurePage(
              userEmail: '',
            ),
        '/total-expenditure': (context) => TotalExpenditurePage(
              userEmail: '',
            ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // User is signed in
          User? user = snapshot.data;
          return DashboardPage(userEmail: user!.email!);
        } else {
          // User is not signed in
          return LoginPage();
        }
      },
    );
  }
}
