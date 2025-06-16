import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocketbase_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _pocketbaseService = PocketBaseService();

  List<UserModel> _users = [];
  UserModel? _currentAdmin;
  bool _isLoading = false;
  Map<String, int> _userStats = {'total': 0, 'active': 0};

  List<UserModel> get _filteredUsers {
    if (_searchController.text.isEmpty) {
      return _users;
    }
    return _users
        .where((user) =>
            user.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            user.email
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentAdmin = _pocketbaseService.currentUser;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _pocketbaseService.getUsers();
      final stats = await _pocketbaseService.getUserStats();
      setState(() {
        _users = users;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load data');
    }
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
            fontWeight: FontWeight.w600, fontSize: isVerySmallScreen ? 11 : 12),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500, fontSize: isVerySmallScreen ? 11 : 12),
        tabs: const [
          Tab(text: 'Daftar Pengguna'),
          Tab(text: 'Pengaturan Admin'),
        ],
      ),
    );
  }

  Widget _buildUserListTab(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;

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
          child:
              _isLoading ? _buildLoadingWidget() : _buildUsersList(constraints),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.deepNavy,
      ),
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
            color: AppTheme.deepNavy, fontSize: isVerySmallScreen ? 13 : 14),
        decoration: InputDecoration(
          hintText: 'Cari pengguna...',
          hintStyle: GoogleFonts.poppins(
              color: AppTheme.charcoalGray.withValues(alpha: 0.7),
              fontSize: isVerySmallScreen ? 13 : 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.charcoalGray, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Icon(Icons.people_rounded,
              color: Colors.white, size: isVerySmallScreen ? 18 : 20),
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
                  '${_userStats['total']} pengguna terdaftar',
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 9 : 10,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_userStats['total']}',
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

    return Row(
      children: [
        Expanded(
          flex: isSmallScreen ? 3 : 2,
          child: Text(
            'Email',
            style: GoogleFonts.oswald(
              fontSize: isVerySmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Bergabung',
            style: GoogleFonts.oswald(
              fontSize: isVerySmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
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

  Widget _buildUserRow(UserModel user, int index, BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Email
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: GoogleFonts.poppins(
                    fontSize: isVerySmallScreen ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.name.isNotEmpty)
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: isVerySmallScreen ? 11 : 12,
                      color: AppTheme.charcoalGray,
                      fontWeight: FontWeight.w500,
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
              _formatDate(user.created),
              style: GoogleFonts.poppins(
                fontSize: isVerySmallScreen ? 11 : 12,
                color: AppTheme.charcoalGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildAdminSettingsTab(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;

    final nameController =
        TextEditingController(text: _currentAdmin?.name ?? 'Admin GRBK');
    final emailController =
        TextEditingController(text: _currentAdmin?.email ?? 'admin@gmail.com');
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Center(
      // Wrap with Center widget
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: isSmallScreen
              ? double.infinity
              : 600, // Limit width on larger screens
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

              // Admin Info Display
              _buildAdminInfoSection(constraints),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Personal Information
              _buildPersonalInfoSection(
                  nameController, emailController, constraints),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Password Section
              _buildPasswordSection(
                  currentPasswordController,
                  newPasswordController,
                  confirmPasswordController,
                  constraints),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Action Buttons - Responsive
              _buildActionButtons(
                  nameController,
                  emailController,
                  currentPasswordController,
                  newPasswordController,
                  confirmPasswordController,
                  constraints),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminInfoSection(BoxConstraints constraints) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return Center(
      // Memusatkan secara horizontal dan vertikal
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
        constraints: BoxConstraints(
            maxWidth:
                400), // Batasi lebar maksimum untuk memastikan konten terpusat
        decoration: BoxDecoration(
          gradient: AppTheme.lightGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Memusatkan vertikal
          crossAxisAlignment:
              CrossAxisAlignment.center, // Memusatkan horizontal
          children: [
            Text(
              'Informasi Admin Saat Ini',
              style: GoogleFonts.oswald(
                fontSize: isVerySmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
              textAlign: TextAlign.center, // Memusatkan teks
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Memusatkan horizontal
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Memusatkan vertikal
              children: [
                Icon(
                  Icons.person_rounded,
                  color: AppTheme.charcoalGray,
                  size: isVerySmallScreen ? 16 : 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  // Ganti Expanded dengan Flexible untuk mengontrol lebar
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Tetap start untuk teks
                    children: [
                      Text(
                        'Nama: ${_currentAdmin?.name ?? 'Admin GRBK'}',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepNavy,
                        ),
                        textAlign:
                            TextAlign.center, // Memusatkan teks di dalam kolom
                      ),
                      Text(
                        'Email: ${_currentAdmin?.email ?? 'admin@gmail.com'}',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 11 : 12,
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign:
                            TextAlign.center, // Memusatkan teks di dalam kolom
                      ),
                      Text(
                        'Role: ${_currentAdmin?.admin == true ? 'Administrator' : 'User'}',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 11 : 12,
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign:
                            TextAlign.center, // Memusatkan teks di dalam kolom
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;

    if (isSmallScreen) {
      return Center(
        // Memusatkan secara horizontal dan vertikal
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Memusatkan vertikal
          crossAxisAlignment:
              CrossAxisAlignment.center, // Memusatkan horizontal
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
              mainAxisAlignment:
                  MainAxisAlignment.center, // Memusatkan vertikal
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Memusatkan horizontal
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
        ),
      );
    } else {
      return Center(
        // Memusatkan secara horizontal dan vertikal
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Memusatkan horizontal
          crossAxisAlignment: CrossAxisAlignment.center, // Memusatkan vertikal
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
      );
    }
  }

  Widget _buildPersonalInfoSection(TextEditingController nameController,
      TextEditingController emailController, BoxConstraints constraints) {
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
            _buildTextField('Nama Lengkap', nameController,
                Icons.person_rounded, constraints),
            const SizedBox(height: 12),
            _buildTextField(
                'Email', emailController, Icons.email_rounded, constraints),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection(
      TextEditingController currentPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      BoxConstraints constraints) {
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
            _buildTextField('Password Saat Ini', currentPasswordController,
                Icons.lock_rounded, constraints,
                isPassword: true),
            const SizedBox(height: 12),
            _buildTextField('Password Baru', newPasswordController,
                Icons.lock_outline_rounded, constraints,
                isPassword: true),
            const SizedBox(height: 12),
            _buildTextField('Konfirmasi Password', confirmPasswordController,
                Icons.lock_outline_rounded, constraints,
                isPassword: true),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController currentPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final isVerySmallScreen = constraints.maxWidth < 400;

    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Validate inputs
                if (nameController.text.trim().isEmpty) {
                  _showErrorSnackBar('Nama tidak boleh kosong');
                  return;
                }

                if (emailController.text.trim().isEmpty ||
                    !emailController.text.contains('@')) {
                  _showErrorSnackBar('Email tidak valid');
                  return;
                }

                // Show loading state
                setState(() => _isLoading = true);

                try {
                  final result = await _pocketbaseService.updateAdminProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );

                  if (result['success']) {
                    setState(() {
                      _currentAdmin = result['user'];
                      _isLoading = false;
                    });
                    _showSuccessSnackBar(
                        'Informasi pribadi berhasil diperbarui!');

                    // Refresh the admin info display
                    setState(() {});
                  } else {
                    setState(() => _isLoading = false);
                    _showErrorSnackBar(
                        result['message'] ?? 'Gagal memperbarui profil');
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Terjadi kesalahan: $e');
                }
              },
              icon: Icon(Icons.save_rounded,
                  color: Colors.white, size: isVerySmallScreen ? 16 : 18),
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
                padding:
                    EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
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
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  _showErrorSnackBar('Password confirmation does not match');
                  return;
                }

                final result = await _pocketbaseService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );

                if (result['success']) {
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  confirmPasswordController.clear();
                  _showSuccessSnackBar('Password berhasil diubah!');
                } else {
                  _showErrorSnackBar(
                      result['message'] ?? 'Password change failed');
                }
              },
              icon: Icon(Icons.security_rounded,
                  color: Colors.white, size: isVerySmallScreen ? 16 : 18),
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
                padding:
                    EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
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
              onPressed: () async {
                // Validate inputs
                if (nameController.text.trim().isEmpty) {
                  _showErrorSnackBar('Nama tidak boleh kosong');
                  return;
                }

                if (emailController.text.trim().isEmpty ||
                    !emailController.text.contains('@')) {
                  _showErrorSnackBar('Email tidak valid');
                  return;
                }

                // Show loading state
                setState(() => _isLoading = true);

                try {
                  final result = await _pocketbaseService.updateAdminProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );

                  if (result['success']) {
                    setState(() {
                      _currentAdmin = result['user'];
                      _isLoading = false;
                    });
                    _showSuccessSnackBar(
                        'Informasi pribadi berhasil diperbarui!');

                    // Refresh the admin info display
                    setState(() {});
                  } else {
                    setState(() => _isLoading = false);
                    _showErrorSnackBar(
                        result['message'] ?? 'Gagal memperbarui profil');
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Terjadi kesalahan: $e');
                }
              },
              icon:
                  const Icon(Icons.save_rounded, color: Colors.white, size: 18),
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
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  _showErrorSnackBar('Password confirmation does not match');
                  return;
                }

                final result = await _pocketbaseService.changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );

                if (result['success']) {
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  confirmPasswordController.clear();
                  _showSuccessSnackBar('Password berhasil diubah!');
                } else {
                  _showErrorSnackBar(
                      result['message'] ?? 'Password change failed');
                }
              },
              icon: const Icon(Icons.security_rounded,
                  color: Colors.white, size: 18),
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

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, BoxConstraints constraints,
      {bool isPassword = false}) {
    final isVerySmallScreen = constraints.maxWidth < 400;

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
          color: AppTheme.deepNavy, fontSize: isVerySmallScreen ? 13 : 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            color: AppTheme.charcoalGray,
            fontSize: isVerySmallScreen ? 11 : 12),
        prefixIcon: Icon(icon, color: AppTheme.charcoalGray, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.warmBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.deepNavy, width: 2),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
