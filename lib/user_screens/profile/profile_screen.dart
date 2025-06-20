import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import '../../services/pocketbase_service.dart';
import '../../providers/payment_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _pocketbaseService = PocketBaseService();
  final ImagePicker _imagePicker = ImagePicker();
  
  Map<String, dynamic> _userProfile = {
    'name': 'Loading...',
    'email': 'Loading...',
    'joinDate': 'Loading...',
    'totalOrders': 0,
    'profileImage': null,
  };

  File? _profileImage;
  String? _webImageData;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = _pocketbaseService.currentUser;
    if (user != null) {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.loadPaymentsByUserId(user.id);
      
      final totalOrders = paymentProvider.payments
          .where((payment) => payment.isConfirmed)
          .length;
      
      setState(() {
        _userProfile = {
          'name': user.name,
          'email': user.email,
          'joinDate': _formatDate(user.created),
          'totalOrders': totalOrders,
          'profileImage': user.avatar,
        };
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildEnhancedHeader(),
              const SizedBox(height: 32),
              _buildMenuItems(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppTheme.lightCream,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.richBlack.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(56),
                    child: _buildProfileImage(),
                  ),
                ),
                
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.lightCream,
                        width: 2,
                      ),
                    ),
                    child: _isUpdatingProfile
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            _userProfile['name'],
            style: GoogleFonts.oswald(
              color: AppTheme.lightCream,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            _userProfile['email'],
            style: GoogleFonts.poppins(
              color: AppTheme.warmBeige,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Total Orders', '${_userProfile['totalOrders']}', Icons.shopping_bag_rounded),
                Container(
                  width: 1,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.lightCream.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                _buildStatItem('Member Since', _userProfile['joinDate'], Icons.calendar_today_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Priority: local selected image > web image data > server avatar > default icon
    if (_profileImage != null) {
      return Image.file(_profileImage!, fit: BoxFit.cover);
    }
    
    if (_webImageData != null) {
      return Image.network(_webImageData!, fit: BoxFit.cover);
    }
    
    final user = _pocketbaseService.currentUser;
    if (user != null && user.avatar != null && user.avatar!.isNotEmpty) {
      return Image.network(
        user.getAvatarUrl(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading avatar: $error');
          return Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.lightGradient,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 60,
              color: AppTheme.deepNavy,
            ),
          );
        },
      );
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.lightGradient,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 60,
        color: AppTheme.deepNavy,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.lightCream,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.oswald(
            color: AppTheme.lightCream,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.warmBeige,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildEnhancedMenuItem(
            Icons.person_outline_rounded,
            'Personal Information',
            'Update your profile details',
            AppTheme.primaryGradient,
            () => _showEditProfileDialog(),
          ),
          _buildEnhancedMenuItem(
            Icons.notifications_outlined,
            'Notifications',
            'Manage your notification preferences',
            AppTheme.accentGradient,
            () => _showNotificationSettings(),
          ),
          _buildEnhancedMenuItem(
            Icons.help_outline_rounded,
            'Help & Support',
            'Get help and contact support',
            AppTheme.neutralGradient,
            () => _showHelpDialog(),
          ),
          _buildEnhancedMenuItem(
            Icons.info_outline_rounded,
            'About GRBK',
            'Learn more about our coffee shop',
            AppTheme.lightGradient,
            () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuItem(
    IconData icon,
    String title,
    String subtitle,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.softWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated image picker with proper implementation
  Future<void> _pickImageForProfile() async {
    try {
      if (kIsWeb) {
        // Web platform
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files!.isNotEmpty) {
            final file = files[0];
            final reader = html.FileReader();
            
            reader.onLoadEnd.listen((e) {
              final result = reader.result as String;
              debugPrint('Web avatar selected: ${file.name}');
              debugPrint('Data URL length: ${result.length}');
              
              setState(() {
                _webImageData = result;
                _profileImage = null;
              });
              
              _updateProfileImage();
            });
            
            reader.onError.listen((e) {
              debugPrint('Error reading file: $e');
              _showErrorSnackBar('Gagal membaca file gambar');
            });
            
            reader.readAsDataUrl(file);
          }
        });
      } else {
        // Mobile/Desktop platform
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        
        if (image != null) {
          debugPrint('Mobile avatar selected: ${image.path}');
          setState(() {
            _profileImage = File(image.path);
            _webImageData = null;
          });
          
          _updateProfileImage();
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  // Update profile image
  Future<void> _updateProfileImage() async {
    if (_profileImage == null && (_webImageData == null || _webImageData!.isEmpty)) {
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      debugPrint('=== UPDATING PROFILE AVATAR ===');
      debugPrint('Has image file: ${_profileImage != null}');
      debugPrint('Has web image data: ${_webImageData != null && _webImageData!.isNotEmpty}');
      
      final result = await _pocketbaseService.updateProfile(
        avatarFile: _profileImage,
        webAvatarData: _webImageData,
      );

      if (result['success']) {
        _showSuccessSnackBar('Profile picture updated successfully!');
        _loadUserProfile(); // Reload profile data
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to update profile picture');
      }
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      _showErrorSnackBar('Error updating profile picture: $e');
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  void _showImagePickerOptions() {
    if (_isUpdatingProfile) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Update Profile Picture',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'Choose a new profile picture from your gallery.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.charcoalGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.charcoalGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageForProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Choose Image',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile['name']);
    final emailController = TextEditingController(text: _userProfile['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppTheme.charcoalGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await _pocketbaseService.updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
              
              Navigator.pop(context);
              
              if (result['success']) {
                _showSuccessSnackBar('Profile updated successfully!');
                _loadUserProfile();
              } else {
                _showErrorSnackBar(result['message'] ?? 'Failed to update profile');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Notification settings feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For support, please contact us at support@grbk.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About GRBK Coffee'),
        content: const Text('GRBK Coffee - Your premium coffee experience since 2024.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pocketbaseService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
