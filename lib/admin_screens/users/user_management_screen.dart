import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Ahmad Rizki',
      'email': 'ahmad.rizki@email.com',
      'joinDate': '15 Jan 2024',
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Sari Dewi',
      'email': 'sari.dewi@email.com',
      'joinDate': '22 Feb 2024',
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'joinDate': '05 Mar 2024',
      'isActive': false,
    },
    {
      'id': '4',
      'name': 'Maya Putri',
      'email': 'maya.putri@email.com',
      'joinDate': '10 Apr 2024',
      'isActive': true,
    },
    {
      'id': '5',
      'name': 'Doni Pratama',
      'email': 'doni.pratama@email.com',
      'joinDate': '18 May 2024',
      'isActive': true,
    },
    {
      'id': '6',
      'name': 'Lisa Anggraini',
      'email': 'lisa.anggraini@email.com',
      'joinDate': '25 Jun 2024',
      'isActive': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchController.text.isEmpty) {
      return _users;
    }
    return _users.where((user) => 
      user['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
      user['email'].toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        
        return Container(
          padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Responsive
              _buildResponsiveHeader(constraints),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Tab Bar - Responsive
              _buildResponsiveTabBar(constraints),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Tab Content - Responsive with proper constraints
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserListTab(constraints),
                    _buildAdminSettingsTab(constraints),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveHeader(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelola Pengguna',
          style: GoogleFonts.oswald(
            fontSize: isVerySmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola daftar pengguna dan pengaturan admin',
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 11 : 12,
            color: AppTheme.charcoalGray,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveTabBar(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.charcoalGray,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600, 
          fontSize: isVerySmallScreen ? 11 : 12
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500, 
          fontSize: isVerySmallScreen ? 11 : 12
        ),
        tabs: const [
          Tab(text: 'Daftar Pengguna'),
          Tab(text: 'Pengaturan Admin'),
        ],
      ),
    );
  }

  Widget _buildUserListTab(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    // ignore: unused_local_variable
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Column(
      children: [
        // Search and Stats - Responsive
        Column(
          children: [
            _buildSearchField(constraints),
            SizedBox(height: isSmallScreen ? 10 : 12),
            _buildUserStatsCard(constraints),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Users List - Responsive with proper constraints
        Expanded(
          child: _buildUsersList(constraints),
        ),
      ],
    );
  }

  Widget _buildSearchField(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        style: GoogleFonts.poppins(
          color: AppTheme.deepNavy, 
          fontSize: isVerySmallScreen ? 13 : 14
        ),
        decoration: InputDecoration(
          hintText: 'Cari pengguna...',
          hintStyle: GoogleFonts.poppins(
            color: AppTheme.charcoalGray.withValues(alpha: 0.7), 
            fontSize: isVerySmallScreen ? 13 : 14
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.charcoalGray, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildUserStatsCard(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isVerySmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_rounded, 
            color: Colors.white, 
            size: isVerySmallScreen ? 18 : 20
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pengguna',
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 11 : 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_users.length} pengguna terdaftar',
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 9 : 10,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_users.length}',
            style: GoogleFonts.oswald(
              fontSize: isVerySmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BoxConstraints constraints) {
    // ignore: unused_local_variable
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.lightGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _buildTableHeader(constraints),
          ),
          
          // Content with proper scrolling
          Expanded(
            child: _filteredUsers.isEmpty 
                ? _buildEmptyState(constraints)
                : ListView.builder(
                    padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserRow(user, index, constraints);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    if (isSmallScreen) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Pengguna',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Bergabung',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Pengguna',
              style: GoogleFonts.oswald(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Email',
              style: GoogleFonts.oswald(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Bergabung',
              style: GoogleFonts.oswald(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildEmptyState(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: isVerySmallScreen ? 48 : 64,
            color: AppTheme.charcoalGray.withValues(alpha: 0.5),
          ),
          SizedBox(height: isVerySmallScreen ? 12 : 16),
          Text(
            'Tidak ada pengguna ditemukan',
            style: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 14 : 16,
              color: AppTheme.charcoalGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 6 : 8),
          Text(
            'Coba ubah kata kunci pencarian',
            style: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 11 : 12,
              color: AppTheme.charcoalGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int index, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: isSmallScreen 
          ? _buildMobileUserRow(user, constraints)
          : _buildDesktopUserRow(user, constraints),
    );
  }

  Widget _buildMobileUserRow(Map<String, dynamic> user, BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Column(
      children: [
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: isVerySmallScreen ? 14 : 16,
              backgroundColor: AppTheme.primaryGradient.colors.first,
              child: Text(
                user['name'][0].toUpperCase(),
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isVerySmallScreen ? 12 : 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // User Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user['email'],
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 9 : 10,
                      color: AppTheme.charcoalGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Join Date
            Expanded(
              child: Text(
                user['joinDate'],
                style: GoogleFonts.poppins(
                  fontSize: isVerySmallScreen ? 9 : 10,
                  color: AppTheme.charcoalGray,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopUserRow(Map<String, dynamic> user, BoxConstraints constraints) {
    return Row(
      children: [
        // User Info
        Expanded(
          flex: 2,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryGradient.colors.first,
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${user['id']}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Email
        Expanded(
          child: Text(
            user['email'],
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.charcoalGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Join Date
        Expanded(
          child: Text(
            user['joinDate'],
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.charcoalGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSettingsTab(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    final nameController = TextEditingController(text: 'Admin GRBK');
    final emailController = TextEditingController(text: 'admin@grbk.com');
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 20), // Prevent bottom overflow
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section - Responsive
            _buildProfileSection(constraints),
            
            SizedBox(height: isSmallScreen ? 20 : 24),
            
            // Personal Information
            _buildPersonalInfoSection(nameController, emailController, constraints),
            
            SizedBox(height: isSmallScreen ? 20 : 24),
            
            // Password Section
            _buildPasswordSection(
              currentPasswordController, 
              newPasswordController, 
              confirmPasswordController, 
              constraints
            ),
            
            SizedBox(height: isSmallScreen ? 20 : 24),
            
            // Action Buttons - Responsive
            _buildActionButtons(constraints),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    if (isSmallScreen) {
      return Column(
        children: [
          Container(
            width: isVerySmallScreen ? 50 : 60,
            height: isVerySmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepNavy.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: isVerySmallScreen ? 24 : 30,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Text(
                'Pengaturan Admin',
                style: GoogleFonts.oswald(
                  fontSize: isVerySmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola informasi akun administrator',
                style: GoogleFonts.poppins(
                  fontSize: isVerySmallScreen ? 11 : 12,
                  color: AppTheme.charcoalGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepNavy.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan Admin',
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                Text(
                  'Kelola informasi akun administrator',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPersonalInfoSection(TextEditingController nameController, TextEditingController emailController, BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Pribadi',
          style: GoogleFonts.oswald(
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildTextField('Nama Lengkap', nameController, Icons.person_rounded, constraints),
            const SizedBox(height: 12),
            _buildTextField('Email', emailController, Icons.email_rounded, constraints),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection(
    TextEditingController currentPasswordController,
    TextEditingController newPasswordController,
    TextEditingController confirmPasswordController,
    BoxConstraints constraints
  ) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubah Password',
          style: GoogleFonts.oswald(
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepNavy,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildTextField('Password Saat Ini', currentPasswordController, Icons.lock_rounded, constraints, isPassword: true),
            const SizedBox(height: 12),
            _buildTextField('Password Baru', newPasswordController, Icons.lock_outline_rounded, constraints, isPassword: true),
            const SizedBox(height: 12),
            _buildTextField('Konfirmasi Password', confirmPasswordController, Icons.lock_outline_rounded, constraints, isPassword: true),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSuccessSnackBar('Informasi pribadi berhasil diperbarui!');
              },
              icon: Icon(Icons.save_rounded, color: Colors.white, size: isVerySmallScreen ? 16 : 18),
              label: Text(
                'Simpan Perubahan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isVerySmallScreen ? 12 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepNavy,
                padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSuccessSnackBar('Password berhasil diubah!');
              },
              icon: Icon(Icons.security_rounded, color: Colors.white, size: isVerySmallScreen ? 16 : 18),
              label: Text(
                'Ubah Password',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isVerySmallScreen ? 12 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showSuccessSnackBar('Informasi pribadi berhasil diperbarui!');
              },
              icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
              label: Text(
                'Simpan Perubahan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepNavy,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showSuccessSnackBar('Password berhasil diubah!');
              },
              icon: const Icon(Icons.security_rounded, color: Colors.white, size: 18),
              label: Text(
                'Ubah Password',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, BoxConstraints constraints, {bool isPassword = false}) {
    final isVerySmallScreen = constraints.maxWidth < 400;
    
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
        color: AppTheme.deepNavy, 
        fontSize: isVerySmallScreen ? 13 : 14
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: AppTheme.charcoalGray, 
          fontSize: isVerySmallScreen ? 11 : 12
        ),
        prefixIcon: Icon(icon, color: AppTheme.charcoalGray, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.warmBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.deepNavy, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.softWhite,
        contentPadding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}