import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lsa_app/src/features/auth/login_page.dart';
import 'package:lsa_app/src/features/profile/about_page.dart';
import 'package:lsa_app/src/models/profile.dart';
import 'package:lsa_app/src/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty
                          ? NetworkImage(_profile!.avatarUrl!)
                          : const AssetImage('assets/images/fox.png') as ImageProvider,
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
                      onPressed: () {
                        _showEditProfileDialog(context);
                      },
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
            onTap: () {
              _showChangePasswordDialog(context);
            },
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isCurrentPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during loading
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return WillPopScope(
              onWillPop: () async => !isLoading, // Prevent back button during loading
              child: AlertDialog(
                title: Text(
                  'Change Password',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentPasswordController,
                        obscureText: !isCurrentPasswordVisible,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isCurrentPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                            ),
                            onPressed: isLoading ? null : () {
                              dialogSetState(() {
                                isCurrentPasswordVisible = !isCurrentPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: newPasswordController,
                        obscureText: !isNewPasswordVisible,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                            ),
                            onPressed: isLoading ? null : () {
                              dialogSetState(() {
                                isNewPasswordVisible = !isNewPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordVisible 
                                  ? Icons.visibility 
                                  : Icons.visibility_off,
                            ),
                            onPressed: isLoading ? null : () {
                              dialogSetState(() {
                                isConfirmPasswordVisible = !isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () {
                      currentPasswordController.dispose();
                      newPasswordController.dispose();
                      confirmPasswordController.dispose();
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      // Validate inputs
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New passwords do not match'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password must be at least 6 characters long'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Set loading state
                      dialogSetState(() {
                        isLoading = true;
                      });

                      try {
                        // Update password using Supabase
                        await supabase.auth.updateUser(
                          UserAttributes(password: newPasswordController.text),
                        );

                        // Close dialog first
                        currentPasswordController.dispose();
                        newPasswordController.dispose();
                        confirmPasswordController.dispose();
                        Navigator.of(dialogContext).pop();

                        // Then show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (error) {
                        // Reset loading state on error
                        if (mounted) {
                          dialogSetState(() {
                            isLoading = false;
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update password: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Password',
                            style: GoogleFonts.poppins(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final usernameController = TextEditingController(text: _profile?.username ?? '');
    bool isLoading = false;
    File? selectedImage;
    Uint8List? webImage;
    String? imageUrl = _profile?.avatarUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return WillPopScope(
              onWillPop: () async => !isLoading,
              child: AlertDialog(
                title: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Image Section
                      GestureDetector(
                        onTap: (isLoading || kIsWeb) ? null : () async {
                          await _pickImage(dialogSetState, (File? file, Uint8List? bytes, String? url) {
                            selectedImage = file;
                            webImage = bytes;
                            imageUrl = url;
                          });
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _getImageProvider(selectedImage, webImage, imageUrl),
                            ),
                            if (!kIsWeb) // Only show camera icon on mobile
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF9C27B0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        kIsWeb 
                            ? 'Image upload not supported on web'
                            : 'Tap to change profile picture',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: kIsWeb ? Colors.red : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Username Section
                      TextField(
                        controller: usernameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () {
                      usernameController.dispose();
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (usernameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Username cannot be empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      dialogSetState(() {
                        isLoading = true;
                      });

                      try {
                        final userId = supabase.auth.currentUser!.id;
                        String? newAvatarUrl = imageUrl;

                        // Upload image if a new one was selected
                        if (selectedImage != null || webImage != null) {
                          newAvatarUrl = await _uploadProfileImage(userId, selectedImage, webImage);
                        }

                        // Update profile in database
                        await supabase.from('profiles').update({
                          'username': usernameController.text.trim(),
                          if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
                        }).eq('id', userId);

                        // Update local profile
                        setState(() {
                          if (_profile != null) {
                            _profile = Profile(
                              id: _profile!.id,
                              username: usernameController.text.trim(),
                              avatarUrl: newAvatarUrl,
                              createdAt: _profile!.createdAt,
                            );
                          }
                        });

                        usernameController.dispose();
                        Navigator.of(dialogContext).pop();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (error) {
                        if (mounted) {
                          dialogSetState(() {
                            isLoading = false;
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update profile: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(StateSetter dialogSetState, Function(File?, Uint8List?, String?) onImageSelected) async {
    try {
      if (kIsWeb) {
        // For web, show a message that image upload is not supported yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload is not supported on web. Please use the mobile app to upload images.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final File file = File(image.path);
        dialogSetState(() {
          onImageSelected(file, null, null);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ImageProvider _getImageProvider(File? file, Uint8List? bytes, String? url) {
    if (file != null && !kIsWeb) {
      return FileImage(file);
    } else if (bytes != null) {
      return MemoryImage(bytes);
    } else if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/fox.png');
    }
  }

  Future<String?> _uploadProfileImage(String userId, File? file, Uint8List? bytes) async {
    try {
      final fileName = 'profile';
      final filePath = '$userId/$fileName';

      if (file != null && !kIsWeb) {
        await supabase.storage.from('proPics').upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
      } else {
        throw Exception('Image upload not supported on web platform');
      }

      // Get public URL
      final String publicUrl = supabase.storage.from('proPics').getPublicUrl(filePath);
      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload image: ${error.toString()}');
    }
  }
}
