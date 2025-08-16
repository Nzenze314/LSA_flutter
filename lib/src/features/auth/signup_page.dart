import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; 
import 'package:lsa_app/src/features/chat/home_page.dart'; // Import the home page
import 'package:lsa_app/src/features/auth/login_page.dart'; // Import the login page
import 'package:lsa_app/src/utils/constants.dart'; // Import constants for Supabase
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for AuthException

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_usernameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _confirmPasswordController.text.trim().isEmpty) {
        if (mounted) {
          context.showSnackBar(message: 'All fields are required');
        }
        return;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
        if (mounted) {
          context.showSnackBar(message: 'Enter a valid email address');
        }
        return;
      }

      if (_passwordController.text.length < 6) {
        if (mounted) {
          context.showSnackBar(message: 'Password must be at least 6 characters long');
        }
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        if (mounted) {
          context.showSnackBar(message: 'Passwords do not match');
        }
        return;
      }

      final authResponse = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {'username': _usernameController.text},
      );
      await supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'username': _usernameController.text,
        'email': _emailController.text
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        context.showSnackBar(message: error.message);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
            child: Container(
                height: screenHeight,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/bgSup2.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Content
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              'assets/images/botHello.png',
                              height: 150,
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create Account',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF9C27B0),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Fill in your details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                          hintText: 'User name',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible = !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: !_isConfirmPasswordVisible,
                                        decoration: InputDecoration(
                                          hintText: 'Confirm Password',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.white70,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                      const SizedBox(height: 15),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _signUp,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF9C27B0),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  'Sign Up',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(color: Colors.white30),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                          );
                                        },
                                        child: Text(
                                          'Already have an account? Sign In',
                                          style: GoogleFonts.poppins(
                                            color: const Color.fromARGB(255, 249, 215, 255),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
