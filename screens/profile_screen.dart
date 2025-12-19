import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../data/user_profile_data.dart';
import 'package:animate_do/animate_do.dart';
import 'settings_screen.dart'; // To navigate if needed, or just standard flow

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileData _userProfile = UserProfileData();
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("classifications");

  // Editing controllers
  bool _isEditing = false;
  late TextEditingController _nameController;
  
  // Stats
  int _totalScans = 0;
  int _uniqueSpecies = 0;
  bool _loadingStats = true;

  // Theme Colors
  final Color primaryColor = const Color(0xFF4ADE80);
  final Color cyanColor = const Color(0xFF22D3EE);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userProfile.name);
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int scans = data.length;
        Set<String> speciesSet = {};

        data.forEach((key, value) {
          if (value is Map && value['label'] != null) {
            String label = value['label'].toString().replaceAll(RegExp(r'[0-9]'), '').trim();
            speciesSet.add(label);
          }
        });

        if (mounted) {
          setState(() {
            _totalScans = scans;
            _uniqueSpecies = speciesSet.length;
            _loadingStats = false;
          });
        }
      } else {
         if (mounted) setState(() => _loadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _userProfile.updateProfile(newImagePath: image.path);
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Save changes - Name Only
        _userProfile.updateProfile(
          newName: _nameController.text,
          // Not updating email at all as requested
        );
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          )
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.9), backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, const Color(0xFF0D0D0D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // Profile Picture
              FadeInDown(
                child: Center(
                  child: GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ]
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: const Color(0xFF1E1E1E),
                            backgroundImage: _userProfile.imagePath != null
                                ? (kIsWeb
                                    ? NetworkImage(_userProfile.imagePath!) as ImageProvider
                                    : FileImage(File(_userProfile.imagePath!)))
                                : null,
                            child: _userProfile.imagePath == null
                                ? Icon(Icons.person, size: 70, color: Colors.grey[800])
                                : null,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Name Only (No Email)
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "Enter Name",
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80))),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4ADE80), width: 2)),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          _userProfile.name,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        // Email display removed
                      ],
                    ),
              ),

              const SizedBox(height: 40),

              // Stats Section
              FadeInUp(
                 delay: const Duration(milliseconds: 300),
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 40),
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: cardColor,
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: Colors.white.withOpacity(0.08)),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _buildStatItem("Scans", _loadingStats ? "..." : "$_totalScans"),
                       Container(width: 1, height: 40, color: Colors.white12),
                       _buildStatItem("Species", _loadingStats ? "..." : "$_uniqueSpecies"),
                     ],
                   ),
                 ),
              ),
              
              const SizedBox(height: 50),

              // Action Button - Edit Profile
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    onPressed: _toggleEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing ? primaryColor : Colors.transparent,
                      foregroundColor: _isEditing ? Colors.black : primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: primaryColor),
                      elevation: _isEditing ? 5 : 0,
                    ),
                    child: Text(_isEditing ? "SAVE CHANGES" : "EDIT PROFILE", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1)),
      ],
    );
  }
}
