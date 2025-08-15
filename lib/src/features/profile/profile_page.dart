import 'package:flutter/material.dart';
import 'package:lsa_app/src/utils/constants.dart';
import 'package:lsa_app/src/models/profile.dart';
import 'package:lsa_app/src/features/auth/login_page.dart'; // Import login page for sign out

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _stars = 0; // State for the selected number of stars
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase.from('profiles').select().eq('id', userId).single();
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar(message: 'Error signing out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Preloader());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromARGB(255, 168, 118, 255),
                backgroundImage: _profile?.avatarUrl != null
                    ? const AssetImage('assets/images/fox.png') // ✅ Fix: use AssetImage
                    : null,
                child: _profile?.avatarUrl == null && _profile?.username != null
                    ? Text(
                        _profile!.username.isNotEmpty
                            ? _profile!.username.substring(0, 1).toUpperCase()
                            : '',
                        style: const TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                _profile?.username ?? 'NzenTech',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile button pressed!')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 209, 183, 255), backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 10), // Add some spacing between buttons
              ElevatedButton.icon(
                onPressed: () {
                  _showReviewDialog(context);
                },
                icon: const Icon(Icons.star),
                label: const Text('Send Review'),
                style: ElevatedButton.styleFrom(
                  foregroundColor:const Color.fromARGB(255, 209, 183, 255), backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileInfoCard(
                icon: Icons.email,
                title: 'Email',
                subtitle: supabase.auth.currentUser?.email ?? 'nzeninco@gmail.com',
              ),
              const SizedBox(height: 15),
              _buildProfileInfoCard(
                icon: Icons.location_on,
                title: 'Location',
                subtitle: 'Buea, Cameroon',
              ),
              const SizedBox(height: 15),
              _buildProfileInfoCard(
                icon: Icons.school,
                title: 'University',
                subtitle: 'Landmark',
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      color: const Color.fromARGB(181, 255, 251, 251),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int currentStars = _stars; // Declare currentStars outside StatefulBuilder

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
                            index < currentStars ? Icons.star : Icons.star_border,
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
              onPressed: () {
                // Update the _stars state of the ProfilePage when submitting
                setState(() {
                  _stars = currentStars;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Review submitted with $_stars stars!')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
