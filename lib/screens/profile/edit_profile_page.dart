import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../services/azure_storage_service.dart';
import '../../services/config_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  
  const EditProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  
  File? _profileImage;
  bool _isLoading = false;
  late final AzureStorageService _azureStorageService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address);
    
    // Initialize Azure storage service
    _azureStorageService = AzureStorageService();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Maintain current photoURL unless we're uploading a new image
      String? photoURL = widget.user.photoURL;
      
      if (_profileImage != null) {
        debugPrint('Uploading profile image to Azure...');
        debugPrint('Image path: ${_profileImage!.path}');
        
        // Upload image to Azure Blob Storage
        final String? newPhotoUrl = await _azureStorageService.uploadProfileImage(
          _profileImage!, 
          widget.user.uid
        );
        
        if (newPhotoUrl != null) {
          debugPrint('Successfully uploaded image. New URL: $newPhotoUrl');
          
          // If user had a previous profile image, delete it from Azure
          if (widget.user.photoURL != null && widget.user.photoURL!.contains('blob.core.windows.net')) {
            debugPrint('Deleting previous profile image: ${widget.user.photoURL}');
            await _azureStorageService.deleteProfileImage(widget.user.photoURL!);
          } else {
            debugPrint('No previous Azure image to delete or not from Azure storage.');
          }
          
          // Update photo URL with the new one from Azure
          photoURL = newPhotoUrl;
        } else {
          debugPrint('Failed to upload image to Azure.');
          // If upload fails, show error but continue with profile update
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload profile image, but profile will be updated.')),
            );
          }
        }
      } else {
        debugPrint('No new profile image selected.');
      }
      
      debugPrint('Updating profile with photoURL: $photoURL');
      await authService.updateUserProfile(
        widget.user.uid,
        {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          if (photoURL != null) 'photoURL': photoURL,
        },
      );
      
      if (!mounted) return;
      
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('Exception during profile update: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (widget.user.photoURL != null
                                ? NetworkImage(widget.user.photoURL!)
                                : null) as ImageProvider?,
                        child: (_profileImage == null && widget.user.photoURL == null)
                            ? const Icon(Icons.person, size: 80, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
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
                
                const SizedBox(height: 32),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Address Field
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                
                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}