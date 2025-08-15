import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsa_app/src/features/auth/login_page.dart';
import 'package:lsa_app/src/features/profile/about_page.dart';
import 'package:lsa_app/src/models/profile.dart';
import 'package:lsa_app/src/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? _profile;
  bool _isLoading = true;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();
      setState(() {
        _profile = Profile.fromMap(data);
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error loading profile');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error signing out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PROFILE',
          style: GoogleFonts.poppins(
            color: const Color(0xFF9C27B0),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          AssetImage('assets/images/fox.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile?.username ?? 'Ebong Lovis',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3E5F5),
                        foregroundColor: const Color(0xFF9C27B0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInfoCard(),
                    const SizedBox(height: 30),
                    _buildSignOutButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileInfoItem(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: supabase.auth.currentUser?.email ?? 'ebongloveis@gmail.com',
          ),
          const Divider(),
          _buildProfileInfoItem(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Buea, Cameroon',
          ),
          const Divider(),
          _buildProfileInfoItem(
            icon: Icons.school_outlined,
            title: 'University',
            subtitle: 'Landmark',
          ),
          const Divider(),
          _buildClickableItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          const Divider(),
          _buildClickableItem(
            icon: Icons.star_outline,
            title: 'Rate this app',
            onTap: () {
              _showReviewDialog(context);
            },
          ),
          const Divider(),
          _buildClickableItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClickableItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: _signOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Sign-out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int currentStars = _stars;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send a Review'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return ListBody(
                  children: <Widget>[
                    const Text('We appreciate your feedback!'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < currentStars
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                          onPressed: () {
                            dialogSetState(() {
                              currentStars = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        hintText: 'Enter your review here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 5,
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (reviewController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a review before submitting.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final userId = supabase.auth.currentUser!.id;
                  await supabase.from('feedbacks').insert({
                    'user_id': userId,
                    'text': reviewController.text,
                    'rating': currentStars,
                  });

                  setState(() {
                    _stars = 0;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit feedback. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  reviewController.dispose();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
