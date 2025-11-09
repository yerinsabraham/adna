import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/partner_api_service.dart';
import 'data/services/mock_partner_api_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/merchant_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/email_verification_screen.dart';
import 'presentation/screens/onboarding/onboarding_wrapper.dart';
import 'presentation/screens/onboarding/pending_approval_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.lightOverlayStyle);

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AdnaApp());
}

class AdnaApp extends StatelessWidget {
  const AdnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize partner API service
    // Use MockPartnerApiService for development
    // Swap to QuidaxApiService when ready for production
    final partnerApi = MockPartnerApiService();

    return MultiProvider(
      providers: [
        // Services
        Provider<PartnerApiService>.value(value: partnerApi),
        
        // Providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider(partnerApi)),
      ],
      child: MaterialApp(
        title: 'Adna',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/onboarding': (context) => const OnboardingWrapper(),
          '/pending-approval': (context) => const PendingApprovalScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
