import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:bloom_app/theme.dart';

const String _cloudinaryCloudName = 'cvri8lee';
const String _cloudinaryUploadPreset = 'll87jkjj';

class EditProfileScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final String? imagePath;

  const EditProfileScreen({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.imagePath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isDataReady = false; 

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name ?? '');
    _emailController = TextEditingController(text: widget.email ?? '');
    _phoneController = TextEditingController(text: widget.phone ?? '');
    _bioController = TextEditingController(text: widget.bio ?? '');

    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _isDataReady = true);
      return;
    }

    try {
      final doc =
          await _firestore.collection('profiles').doc(currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (_imageBytes == null) {
          _imageUrl = data['profileImageUrl'] as String?;
        }
        if (_nameController.text.isEmpty && data['fullName'] != null) {
          _nameController.text = data['fullName'];
        }
        if (_emailController.text.isEmpty && data['email'] != null) {
          _emailController.text = data['email'];
        }
        if (_phoneController.text.isEmpty && data['phone'] != null) {
          _phoneController.text = data['phone'];
        }
        if (_bioController.text.isEmpty && data['bio'] != null) {
          _bioController.text = data['bio'];
        }
      } else if (_emailController.text.isEmpty && currentUser.email != null) {
        _emailController.text = currentUser.email!;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal load data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDataReady = true);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<String> _uploadToCloudinary(Uint8List bytes, String uid) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );

    final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
    final publicId = 'profile_images/${uid}_$uniqueSuffix';

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['public_id'] = publicId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$publicId.jpg',
        ),
      );

    final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Upload timeout, cek koneksi internet'),
        );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Upload ke Cloudinary gagal: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali isian form kamu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _imageUrl;

      if (_imageBytes != null) {
        finalImageUrl = await _uploadToCloudinary(_imageBytes!, user.uid);
      }

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final bio = _bioController.text.trim();

      await _firestore.collection('profiles').doc(user.uid).set({
        'fullName': name,
        'email': email,
        'phone': phone,
        'bio': bio,
        if (finalImageUrl != null) 'profileImageUrl': finalImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, {
        'name': name,
        'email': email,
        'phone': phone,
        'bio': bio,
        'profileImageUrl': finalImageUrl,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Color.fromARGB(255, 232, 231, 231))),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surface,
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!) as ImageProvider
                            : _imageUrl != null
                                ? NetworkImage(_imageUrl!) as ImageProvider
                                : const AssetImage(
                                    'assets/images/default_admin.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 16),
              _buildBioField(),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: (_isLoading || !_isDataReady) ? null : _saveChanges,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: (!_isDataReady)
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isDataReady ? 'Save Changes' : 'Memuat data...',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
        labelStyle: GoogleFonts.dmSans(color: AppColors.textMedium),
      ),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? 'Nama tidak boleh kosong'
          : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: GoogleFonts.dmSans(color: AppColors.textMedium),
      ),
      validator: (value) =>
          (value == null || !value.contains('@')) ? 'Email tidak valid' : null,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'No. Telepon',
        labelStyle: GoogleFonts.dmSans(color: AppColors.textMedium),
      ),
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Bio',
        alignLabelWithHint: true,
        labelStyle: GoogleFonts.dmSans(color: AppColors.textMedium),
      ),
    );
  }
}