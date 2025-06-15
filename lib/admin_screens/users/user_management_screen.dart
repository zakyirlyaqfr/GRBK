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
      'phone': '+62 812-3456-7890',
      'joinDate': '15 Jan 2024',
      'totalOrders': 25,
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Sari Dewi',
      'email': 'sari.dewi@email.com',
      'phone': '+62 813-9876-5432',
      'joinDate': '22 Feb 2024',
      'totalOrders': 18,
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'phone': '+62 814-1122-3344',
      'joinDate': '05 Mar 2024',
      'totalOrders': 12,
      'isActive': false,
    },
    {
      'id': '4',
      'name': 'Maya Putri',
      'email': 'maya.putri@email.com',
      'phone': '+62 815-5566-7788',
      'joinDate': '10 Apr 2024',
      'totalOrders': 31,
      'isActive': true,
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Kelola Pengguna',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          Text(
            'Kelola daftar pengguna dan pengaturan admin',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.charcoalGray,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Bar
          Container(
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
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
              tabs: const [
                Tab(text: 'Daftar Pengguna'),
                Tab(text: 'Pengaturan Admin'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserListTab(),
                _buildAdminSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListTab() {
    return Column(
      children: [
        // Search and Stats
        Column(
          children: [
            Container(
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
                style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari pengguna...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray.withValues(alpha: 0.7), fontSize: 14),
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
            ),
            const SizedBox(height: 12),
            _buildUserStatsCard(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Users List
        Expanded(
          child: Container(
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
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
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
                          'Bergabung',
                          style: GoogleFonts.oswald(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Total Order',
                          style: GoogleFonts.oswald(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: GoogleFonts.oswald(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserRow(user, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatsCard() {
    final activeUsers = _users.where((user) => user['isActive']).length;
    final totalOrders = _users.fold<int>(0, (sum, user) => sum + (user['totalOrders'] as int));
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_rounded, color: Colors.white, size: 20),
              const Spacer(),
              Text(
                '${_users.length}',
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total Pengguna',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$activeUsers',
                      style: GoogleFonts.oswald(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Aktif',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalOrders',
                      style: GoogleFonts.oswald(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Orders',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: Row(
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
                      ),
                      Text(
                        user['email'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.charcoalGray,
                        ),
                      ),
                      Text(
                        user['phone'],
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Join Date
          Expanded(
            child: Text(
              user['joinDate'],
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppTheme.charcoalGray,
              ),
            ),
          ),
          
          // Total Orders
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warmBeige.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${user['totalOrders']} orders',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user['isActive'] ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user['isActive'] ? 'Aktif' : 'Nonaktif',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: user['isActive'] ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSettingsTab() {
    final nameController = TextEditingController(text: 'Admin GRBK');
    final emailController = TextEditingController(text: 'admin@grbk.com');
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
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
            // Profile Section
            Row(
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
            ),
            
            const SizedBox(height: 24),
            
            // Personal Information
            Text(
              'Informasi Pribadi',
              style: GoogleFonts.oswald(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: [
                _buildTextField('Nama Lengkap', nameController, Icons.person_rounded),
                const SizedBox(height: 12),
                _buildTextField('Email', emailController, Icons.email_rounded),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Password Section
            Text(
              'Ubah Password',
              style: GoogleFonts.oswald(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: [
                _buildTextField('Password Saat Ini', currentPasswordController, Icons.lock_rounded, isPassword: true),
                const SizedBox(height: 12),
                _buildTextField('Password Baru', newPasswordController, Icons.lock_outline_rounded, isPassword: true),
                const SizedBox(height: 12),
                _buildTextField('Konfirmasi Password', confirmPasswordController, Icons.lock_outline_rounded, isPassword: true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Column(
              children: [
                Container(
                  width: double.infinity,
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
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
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
        contentPadding: const EdgeInsets.all(12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}