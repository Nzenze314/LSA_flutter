import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Needed for ImageFilter
import 'package:lsa_app/src/features/chat/home_page.dart'; // Import the home page
import 'package:lsa_app/src/features/auth/signup_page.dart'; // Import the signup page
import 'package:lsa_app/src/utils/constants.dart'; // Import constants for Supabase
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for AuthException
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _saveCredentials(_emailController.text, _passwordController.text);
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
      body: _isLoading
          ? const Preloader()
          : Container(
              height: screenHeight,
              child: Stack(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           Image.asset(
                              'assets/images/botHello.png',
                              height: 150,
                            ),
                            const SizedBox(height: 10),
                          ClipRRect(
                            // borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
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
                                  children: [
                                    Text(
                                      'Welcome Back',
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9C27B0),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sign in to continue chatting',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: 'exampleemail@gmail.com',
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
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_isPasswordVisible,
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
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
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.poppins(color: Colors.white70),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _signIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF9C27B0),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Sign In',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(color: Colors.white30),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SignupPage()),
                                        );
                                      },
                                      child: Text(
                                        'Don\'t have an account? Sign Up',
                                        style: GoogleFonts.poppins(
                                          color: const Color.fromARGB(255, 250, 220, 255),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
