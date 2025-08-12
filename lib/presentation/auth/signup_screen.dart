import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please accept the terms and conditions')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Account created successfully! Please check your email to verify your account.'),
            backgroundColor: Colors.green));
        Navigator.of(context).pop(); // Go back to login screen
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sign up failed: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop())),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          SizedBox(height: 4.h),

                          // Logo and Title
                          Center(
                              child: Column(children: [
                            CustomImageWidget(imageUrl: '', height: 10.h, width: 10.h),
                            SizedBox(height: 2.h),
                            Text('Create Account',
                                style: GoogleFonts.inter(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface)),
                            SizedBox(height: 1.h),
                            Text('Join ChatFusion today',
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant)),
                          ])),

                          SizedBox(height: 4.h),

                          // Full Name Field
                          TextFormField(
                              controller: _fullNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icon(Icons.person_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Full name is required';
                                if (value!.trim().length < 2)
                                  return 'Name must be at least 2 characters';
                                return null;
                              }),

                          SizedBox(height: 2.h),

                          // Email Field
                          TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Email is required';
                                if (!value!.contains('@') ||
                                    !value.contains('.'))
                                  return 'Invalid email format';
                                return null;
                              }),

                          SizedBox(height: 2.h),

                          // Password Field
                          TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                  prefixIcon: Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Password is required';
                                if (value!.length < 6)
                                  return 'Password must be at least 6 characters';
                                return null;
                              }),

                          SizedBox(height: 2.h),

                          // Confirm Password Field
                          TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Confirm your password',
                                  prefixIcon: Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              validator: (value) {
                                if (value?.isEmpty ?? true)
                                  return 'Please confirm your password';
                                if (value != _passwordController.text)
                                  return 'Passwords do not match';
                                return null;
                              }),

                          SizedBox(height: 2.h),

                          // Terms and Conditions
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) => setState(
                                        () => _acceptTerms = value ?? false)),
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () => setState(
                                            () => _acceptTerms = !_acceptTerms),
                                        child: Text(
                                            'I agree to the Terms of Service and Privacy Policy',
                                            style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant)))),
                              ]),

                          SizedBox(height: 3.h),

                          // Sign Up Button
                          ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  foregroundColor:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  padding: EdgeInsets.symmetric(vertical: 4.w),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Create Account',
                                      style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600))),

                          SizedBox(height: 3.h),

                          // Sign In Link
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account? ",
                                    style: GoogleFonts.inter(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant)),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('Sign In',
                                        style: GoogleFonts.inter(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            fontWeight: FontWeight.w600))),
                              ]),
                        ]))))));
  }
}