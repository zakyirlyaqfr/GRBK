import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/app_theme.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'All',
    'Kopi Susu',
    'Basic Espresso',
    'Sparkling Fruity',
    'Milk Base',
    'Tea Series',
    'Food'
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'GRBK Special Blend',
      'price': 35000,
      'image': 'assets/images/coffee1.jpg', // Changed to image path
      'category': 'Kopi Susu',
      'description': 'Our signature specialty coffee blend with notes of chocolate and caramel',
      'isAvailable': true,
    },
    {
      'id': '2',
      'name': 'Single Origin Americano',
      'price': 25000,
      'image': 'assets/images/coffee2.jpg',
      'category': 'Basic Espresso',
      'description': 'Bold and smooth americano from single origin beans',
      'isAvailable': false,
    },
    {
      'id': '3',
      'name': 'Matcha Latte',
      'price': 30000,
      'image': 'assets/images/matcha.jpg',
      'category': 'Milk Base',
      'description': 'Premium matcha with creamy milk foam',
      'isAvailable': true,
    },
    {
      'id': '4',
      'name': 'Lemon Mint Refresher',
      'price': 28000,
      'image': 'assets/images/lemon.jpg',
      'category': 'Sparkling Fruity',
      'description': 'Fresh lemon with mint leaves, perfect for hot days',
      'isAvailable': true,
    },
    {
      'id': '5',
      'name': 'Earl Grey Tea',
      'price': 22000,
      'image': 'assets/images/tea.jpg',
      'category': 'Tea Series',
      'description': 'Classic earl grey with bergamot essence',
      'isAvailable': true,
    },
    {
      'id': '6',
      'name': 'Artisan Croissant',
      'price': 18000,
      'image': 'assets/images/croissant.jpg',
      'category': 'Food',
      'description': 'Buttery croissant baked fresh daily',
      'isAvailable': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredMenuItems {
    List<Map<String, dynamic>> filtered = _menuItems;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) => item['category'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((item) => 
        item['name'].toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(constraints.maxWidth > 600 ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Responsive
              _buildResponsiveHeader(constraints),
              
              SizedBox(height: constraints.maxHeight > 700 ? 24 : 16),
              
              // Search and Filter - Responsive
              _buildSearchAndFilter(constraints),
              
              SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
              
              // Menu List - Responsive with proper constraints
              Expanded(
                child: _buildMenuList(constraints),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveHeader(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      // Mobile layout - Stack vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Menu',
            style: GoogleFonts.oswald(
              fontSize: constraints.maxWidth < 400 ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambah, edit, dan hapus menu produk',
            style: GoogleFonts.poppins(
              fontSize: constraints.maxWidth < 400 ? 11 : 12,
              color: AppTheme.charcoalGray,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildAddButton(constraints),
          ),
        ],
      );
    } else {
      // Desktop layout - Side by side
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Menu',
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepNavy,
                  ),
                ),
                Text(
                  'Tambah, edit, dan hapus menu produk',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.charcoalGray,
                  ),
                ),
              ],
            ),
          ),
          _buildAddButton(constraints),
        ],
      );
    }
  }

  Widget _buildAddButton(BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: _showAddMenuDialog,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
        label: Text(
          'Tambah Menu',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: constraints.maxWidth < 400 ? 11 : 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 400 ? 12 : 16, 
            vertical: constraints.maxWidth < 400 ? 8 : 10
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      // Mobile - Stack vertically
      return Column(
        children: [
          _buildSearchField(constraints),
          const SizedBox(height: 12),
          _buildCategoryFilter(constraints),
        ],
      );
    } else {
      // Desktop - Side by side
      return Row(
        children: [
          Expanded(flex: 2, child: _buildSearchField(constraints)),
          const SizedBox(width: 16),
          Expanded(child: _buildCategoryFilter(constraints)),
        ],
      );
    }
  }

  Widget _buildSearchField(BoxConstraints constraints) {
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
          fontWeight: FontWeight.w500,
          fontSize: constraints.maxWidth < 400 ? 13 : 14,
        ),
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          hintStyle: GoogleFonts.poppins(
            color: AppTheme.charcoalGray.withValues(alpha: 0.7),
            fontSize: constraints.maxWidth < 400 ? 13 : 14,
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

  Widget _buildCategoryFilter(BoxConstraints constraints) {
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
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        onChanged: (value) => setState(() => _selectedCategory = value!),
        decoration: InputDecoration(
          labelText: 'Kategori',
          labelStyle: GoogleFonts.poppins(
            color: AppTheme.charcoalGray,
            fontSize: constraints.maxWidth < 400 ? 11 : 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: GoogleFonts.poppins(
                color: AppTheme.deepNavy,
                fontWeight: FontWeight.w500,
                fontSize: constraints.maxWidth < 400 ? 13 : 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuList(BoxConstraints constraints) {
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
            padding: EdgeInsets.all(constraints.maxWidth < 400 ? 12 : 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.lightGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _buildTableHeader(constraints),
          ),
          
          // Content with proper scrolling
          Expanded(
            child: _filteredMenuItems.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(constraints.maxWidth < 400 ? 12 : 16),
                    itemCount: _filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredMenuItems[index];
                      return _buildMenuRow(item, index, constraints);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Menu Item',
              style: GoogleFonts.oswald(
                fontSize: constraints.maxWidth < 400 ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Harga',
              style: GoogleFonts.oswald(
                fontSize: constraints.maxWidth < 400 ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'Aksi',
              style: GoogleFonts.oswald(
                fontSize: constraints.maxWidth < 400 ? 10 : 12,
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
              'Menu Item',
              style: GoogleFonts.oswald(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Kategori',
              style: GoogleFonts.oswald(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Harga',
              style: GoogleFonts.oswald(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'Aksi',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 64,
            color: AppTheme.charcoalGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada menu ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.charcoalGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau tambah menu baru',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.charcoalGray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(Map<String, dynamic> item, int index, BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(constraints.maxWidth < 400 ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: constraints.maxWidth < 600 
          ? _buildMobileMenuRow(item, constraints)
          : _buildDesktopMenuRow(item, constraints),
    );
  }

  Widget _buildMobileMenuRow(Map<String, dynamic> item, BoxConstraints constraints) {
    return Column(
      children: [
        Row(
          children: [
            // Image
            Container(
              width: constraints.maxWidth < 400 ? 35 : 40,
              height: constraints.maxWidth < 400 ? 35 : 40,
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMenuImage(item['image']),
              ),
            ),
            const SizedBox(width: 8),
            // Menu Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontSize: constraints.maxWidth < 400 ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['category'],
                    style: GoogleFonts.poppins(
                      fontSize: constraints.maxWidth < 400 ? 9 : 10,
                      color: AppTheme.charcoalGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Price
            Expanded(
              child: Text(
                'Rp ${item['price']}',
                style: GoogleFonts.oswald(
                  fontSize: constraints.maxWidth < 400 ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
            ),
            // Actions
            _buildActionMenu(item),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopMenuRow(Map<String, dynamic> item, BoxConstraints constraints) {
    return Row(
      children: [
        // Menu Item Info
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.lightGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildMenuImage(item['image']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.charcoalGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Category
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.warmBeige.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item['category'],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepNavy,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        
        // Price
        Expanded(
          child: Text(
            'Rp ${item['price']}',
            style: GoogleFonts.oswald(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
        ),
        
        // Actions
        _buildActionMenu(item),
      ],
    );
  }

  Widget _buildMenuImage(String imagePath) {
    // For demo purposes, show a placeholder. In real app, use Image.file() or Image.network()
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warmBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_rounded,
        color: AppTheme.charcoalGray,
        size: 20,
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> item) {
    return SizedBox(
      width: 40,
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, item),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_rounded, size: 16, color: AppTheme.charcoalGray),
                const SizedBox(width: 6),
                Text(
                  'Edit',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.charcoalGray),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  'Hapus',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.charcoalGray),
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'edit':
        _showEditMenuDialog(item);
        break;
      case 'delete':
        _showDeleteConfirmDialog(item);
        break;
    }
  }

  Future<void> _pickImage(Function(String) onImageSelected) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Kopi Susu';
    String? selectedImagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Menu Baru',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                          Text(
                            'Lengkapi informasi menu',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppTheme.charcoalGray),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.softWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.warmBeige),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
                                ),
                                child: selectedImagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(selectedImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_rounded,
                                        size: 40,
                                        color: AppTheme.charcoalGray,
                                      ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _pickImage((path) {
                                  setDialogState(() {
                                    selectedImagePath = path;
                                  });
                                }),
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: Text(
                                  selectedImagePath != null ? 'Ganti Gambar' : 'Pilih Gambar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.deepNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Form Fields
                        _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setDialogState(() => selectedCategory = value!),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 14),
                            prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.warmBeige),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.deepNavy, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          items: _categories.skip(1).map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.charcoalGray),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: AppTheme.charcoalGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty && 
                              priceController.text.isNotEmpty &&
                              selectedImagePath != null) {
                            setState(() {
                              _menuItems.add({
                                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                                'name': nameController.text,
                                'price': int.tryParse(priceController.text) ?? 0,
                                'image': selectedImagePath!,
                                'category': selectedCategory,
                                'description': descriptionController.text,
                                'isAvailable': true,
                              });
                            });
                            Navigator.pop(context);
                            _showSuccessSnackBar('Menu baru berhasil ditambahkan!');
                          } else {
                            _showErrorSnackBar('Mohon lengkapi semua field dan pilih gambar');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tambah Menu',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMenuDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: item['price'].toString());
    final descriptionController = TextEditingController(text: item['description']);
    String selectedCategory = item['category'];
    String? selectedImagePath = item['image'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Menu',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepNavy,
                            ),
                          ),
                          Text(
                            'Perbarui informasi menu',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.charcoalGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppTheme.charcoalGray),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Form (same structure as add dialog)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Upload Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.softWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.warmBeige),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
                                ),
                                child: selectedImagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: selectedImagePath!.startsWith('assets/')
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.warmBeige.withValues(alpha: 0.3),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.image_rounded,
                                                  size: 40,
                                                  color: AppTheme.charcoalGray,
                                                ),
                                              )
                                            : Image.file(
                                                File(selectedImagePath!),
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    : const Icon(
                                        Icons.image_rounded,
                                        size: 40,
                                        color: AppTheme.charcoalGray,
                                      ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _pickImage((path) {
                                  setDialogState(() {
                                    selectedImagePath = path;
                                  });
                                }),
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: Text(
                                  'Ganti Gambar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.deepNavy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Form Fields
                        _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setDialogState(() => selectedCategory = value!),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 14),
                            prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.warmBeige),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.deepNavy, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          items: _categories.skip(1).map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.charcoalGray),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: AppTheme.charcoalGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty && 
                              priceController.text.isNotEmpty &&
                              selectedImagePath != null) {
                            setState(() {
                              item['name'] = nameController.text;
                              item['price'] = int.tryParse(priceController.text) ?? 0;
                              item['description'] = descriptionController.text;
                              item['category'] = selectedCategory;
                              item['image'] = selectedImagePath!;
                            });
                            Navigator.pop(context);
                            _showSuccessSnackBar('Menu berhasil diperbarui!');
                          } else {
                            _showErrorSnackBar('Mohon lengkapi semua field');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.delete_rounded, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Hapus Menu',
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin menghapus "${item['name']}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.charcoalGray),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _menuItems.removeWhere((menuItem) => menuItem['id'] == item['id']);
                        });
                        Navigator.pop(context);
                        _showSuccessSnackBar('Menu berhasil dihapus!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: AppTheme.deepNavy, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.charcoalGray, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.warmBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.deepNavy, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
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