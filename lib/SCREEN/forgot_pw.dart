import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/buttons.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.lock_reset_outlined, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 24),
            Text('Reset Password',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text("Enter your email and we'll send you a link to reset your password.",
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMedium, height: 1.6)),
            const SizedBox(height: 36),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight, size: 20),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Send Reset Link',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Reset link sent!', style: GoogleFonts.dmSans()),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}