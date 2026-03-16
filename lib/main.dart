import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppointmentProvider()..initData()),
      ],
      child: MaterialApp(
        title: 'Appointment Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}