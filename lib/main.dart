import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:sistem_parkir/providers/park_provider.dart';

// Providers
import 'providers/report_provider.dart';
import 'providers/parking_report_provider.dart';
import 'providers/auth_provider.dart';

// Services
import 'services/token_storage.dart';

// Screens Petugas
import 'screens/auth/login_petugas.dart';
// import 'screens/report/form_report.dart';
// import 'screens/record/record_screen.dart';
import 'screens/record/succes_submit_report.dart';

// Screens Mahasiswa & Dosen
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/info_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/main_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/auth/login_user_screen.dart';
import 'screens/auth/register_user_screen.dart';
import 'screens/home/home_page.dart';
import 'screens/park_view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await TokenStorage.getToken();
  final role = await TokenStorage.getRole();
  final isExpired = token == null ? true : _isTokenExpired(token);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ReportProvider()),
          ChangeNotifierProvider(create: (_) => ParkingReportProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ParkingProvider()),
          
        ],
        child: FasParkApp(
          isLoggedIn: !isExpired && role != null,
          role: role,
        ),
      ),
    ),
  );
}

// ✅ Cek kadaluwarsa token (dari field 'exp' JWT)
bool _isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = json.decode(
      utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      ),
    );

    final exp = payload['exp'];
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  } catch (e) {
    return true;
  }
}

class FasParkApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const FasParkApp({super.key, required this.isLoggedIn, this.role});

  @override
  Widget build(BuildContext context) {
        String initialRoute;

    if (!isLoggedIn) {
      initialRoute = '/splash';
    } else {
      final normalizedRole = role?.toLowerCase();

      if (normalizedRole == 'petugas') {
        initialRoute = '/home'; // ✅ Petugas ke halaman home 
      } else if (normalizedRole == 'mahasiswa' || normalizedRole == 'dosen') {
        initialRoute = '/main'; // ✅ Mahasiswa/dosen ke menu utama 
      } else {
        initialRoute = '/role';
      }

      print("Auto-login dengan role: $normalizedRole → Arahkan ke $initialRoute");
    }


    return MaterialApp(
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      debugShowCheckedModeBanner: false,
      title: 'FasPark',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: const Color(0xFFF3EFCB),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {  
          case '/splash':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/info':
            return MaterialPageRoute(builder: (_) => InfoScreen());
          case '/location':
            return MaterialPageRoute(builder: (_) => LocationPermissionScreen());
          case '/role':
            return MaterialPageRoute(builder: (_) => RoleSelectionScreen());
          case '/login-petugas':
            return MaterialPageRoute(builder: (_) => LoginPetugas());
          case '/main':
            return MaterialPageRoute(builder: (_) => MainScreen());
          case '/profile-user':
            return MaterialPageRoute(builder: (_) => ProfileScreen());
          case '/register-user':
            return MaterialPageRoute(builder: (_) => RegisterUserScreen());
          case '/login-user':
            return MaterialPageRoute(builder: (_) => LoginUserScreen());
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => EditProfileScreen());
          // case '/form':
          //   return MaterialPageRoute(builder: (_) => FormReportPage());
          case '/record':
            final args = settings.arguments;
            if (args != null) {
              return MaterialPageRoute(builder: (_) => RecordScreen(id: args.toString()));
            }
            return _errorRoute("ID tidak valid");
          // case '/success-submit':
          //   return MaterialPageRoute(builder: (_) => SuccessSubmitReport());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/map':
            return MaterialPageRoute(builder: (_) => ParkViewScreen());
          default:
            return _errorRoute("Halaman tidak ditemukan");
        }
      },
    );
  }

  MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}
