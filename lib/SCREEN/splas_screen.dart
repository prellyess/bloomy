import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../widgets/buttons.dart';
import 'register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background 
            Positioned(
              top: -size.height * 0.15,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.15,
              child: Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary.withOpacity(0.06),
                      AppColors.primary.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Image.asset(
                    'assets/logoBloomy.png', 
                    height: 180,
                    width: 180,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'bloomy',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Find your perfect bloom',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: AppColors.textMedium.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const Spacer(flex: 2),
                  const SizedBox(height: 24),


                  // Seller Button
                  PrimaryButton(
                    label: 'Masuk',
                    onPressed: () => _navigateToAuth(context),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Version indicator
            Positioned(
              bottom: 20,
              right: 24,
              child: Text(
                'v1.0.0',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textMedium.withOpacity(0.3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _navigateToAuth(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const RegisterScreen(),
    ), // MaterialPageRoute
  );
}
}