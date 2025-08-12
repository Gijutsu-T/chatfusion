import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/chat-list');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Sign in failed: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signInWithGoogle();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/chat-list');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Google sign in failed: ${error.toString()}'),
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
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 8.h),

                          // Logo and Title
                          Center(
                              child: Column(children: [
                            CustomImageWidget(imageUrl: '', height: 12.h, width: 12.h),
                            SizedBox(height: 3.h),
                            Text('Welcome to ChatFusion',
                                style: GoogleFonts.inter(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface)),
                            SizedBox(height: 1.h),
                            Text('Sign in to continue',
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant)),
                          ])),

                          SizedBox(height: 6.h),

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
                                if (!value!.contains('@'))
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
                                  hintText: 'Enter your password',
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

                          SizedBox(height: 1.h),

                          // Forgot Password
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/forgot-password');
                                  },
                                  child: Text('Forgot Password?',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.lightTheme.colorScheme
                                              .primary)))),

                          SizedBox(height: 3.h),

                          // Sign In Button
                          ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignIn,
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
                                  : Text('Sign In',
                                      style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600))),

                          SizedBox(height: 3.h),

                          // Divider
                          Row(children: [
                            Expanded(child: Divider()),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text('or',
                                    style: GoogleFonts.inter(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant))),
                            Expanded(child: Divider()),
                          ]),

                          SizedBox(height: 3.h),

                          // Google Sign In
                          OutlinedButton.icon(
                              onPressed:
                                  _isLoading ? null : _handleGoogleSignIn,
                              icon: Icon(Icons.g_mobiledata, size: 24),
                              label: Text('Continue with Google',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500)),
                              style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 4.w),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)))),

                          Spacer(),

                          // Sign Up Link
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ",
                                    style: GoogleFonts.inter(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant)),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/signup');
                                    },
                                    child: Text('Sign Up',
                                        style: GoogleFonts.inter(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            fontWeight: FontWeight.w600))),
                              ]),
                        ])))));
  }
}