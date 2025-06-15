import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

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
      'image': '☕',
      'category': 'Kopi Susu',
      'description': 'Our signature specialty coffee blend with notes of chocolate and caramel',
      'isAvailable': true,
    },
    {
      'id': '2',
      'name': 'Single Origin Americano',
      'price': 25000,
      'image': '☕',
      'category': 'Basic Espresso',
      'description': 'Bold and smooth americano from single origin beans',
      'isAvailable': false,
    },
    {
      'id': '3',
      'name': 'Matcha Latte',
      'price': 30000,
      'image': '🍵',
      'category': 'Milk Base',
      'description': 'Premium matcha with creamy milk foam',
      'isAvailable': true,
    },
    {
      'id': '4',
      'name': 'Lemon Mint Refresher',
      'price': 28000,
      'image': '🍋',
      'category': 'Sparkling Fruity',
      'description': 'Fresh lemon with mint leaves, perfect for hot days',
      'isAvailable': true,
    },
    {
      'id': '5',
      'name': 'Earl Grey Tea',
      'price': 22000,
      'image': '🫖',
      'category': 'Tea Series',
      'description': 'Classic earl grey with bergamot essence',
      'isAvailable': true,
    },
    {
      'id': '6',
      'name': 'Artisan Croissant',
      'price': 18000,
      'image': '🥐',
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
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
              Container(
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
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Search and Filter
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
                  style: GoogleFonts.poppins(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari menu...',
                    hintStyle: GoogleFonts.poppins(
                      color: AppTheme.charcoalGray.withValues(alpha: 0.7),
                      fontSize: 14,
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
              ),
              const SizedBox(height: 12),
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
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: GoogleFonts.poppins(
                      color: AppTheme.charcoalGray,
                      fontSize: 12,
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
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Menu List
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
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredMenuItems[index];
                        return _buildMenuRow(item, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(Map<String, dynamic> item, int index) {
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
                  child: Center(
                    child: Text(
                      item['image'],
                      style: const TextStyle(fontSize: 20),
                    ),
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
          
          // Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item['isAvailable'] 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['isAvailable'] ? 'Tersedia' : 'Habis',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item['isAvailable'] ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Actions
          SizedBox(
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
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        item['isAvailable'] ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 16,
                        color: AppTheme.charcoalGray,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['isAvailable'] ? 'Nonaktifkan' : 'Aktifkan',
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
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'edit':
        _showEditMenuDialog(item);
        break;
      case 'toggle':
        setState(() {
          item['isAvailable'] = !item['isAvailable'];
        });
        _showSuccessSnackBar('${item['name']} ${item['isAvailable'] ? 'diaktifkan' : 'dinonaktifkan'}');
        break;
      case 'delete':
        _showDeleteConfirmDialog(item);
        break;
    }
  }

  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Kopi Susu';
    String selectedEmoji = '☕';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tambah Menu Baru',
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.charcoalGray),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                      const SizedBox(height: 12),
                      _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                      const SizedBox(height: 12),
                      _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                      const SizedBox(height: 12),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (value) => selectedCategory = value!,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
                          prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
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
                      
                      const SizedBox(height: 12),
                      
                      // Emoji Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.softWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.warmBeige),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Icon',
                              style: GoogleFonts.poppins(
                                color: AppTheme.charcoalGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['☕', '🍵', '🥤', '🍋', '🫖', '🥐', '🍰', '🧁'].map((emoji) {
                                return GestureDetector(
                                  onTap: () => selectedEmoji = emoji,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selectedEmoji == emoji 
                                          ? AppTheme.deepNavy.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selectedEmoji == emoji 
                                            ? AppTheme.deepNavy 
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.charcoalGray),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                          setState(() {
                            _menuItems.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'name': nameController.text,
                              'price': int.tryParse(priceController.text) ?? 0,
                              'image': selectedEmoji,
                              'category': selectedCategory,
                              'description': descriptionController.text,
                              'isAvailable': true,
                            });
                          });
                          Navigator.pop(context);
                          _showSuccessSnackBar('Menu baru berhasil ditambahkan!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Tambah Menu',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  void _showEditMenuDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: item['price'].toString());
    final descriptionController = TextEditingController(text: item['description']);
    String selectedCategory = item['category'];
    String selectedEmoji = item['image'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Menu',
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.charcoalGray),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Form (same as add dialog)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                      const SizedBox(height: 12),
                      _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                      const SizedBox(height: 12),
                      _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                      const SizedBox(height: 12),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (value) => selectedCategory = value!,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 12),
                          prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
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
                      
                      const SizedBox(height: 12),
                      
                      // Emoji Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.softWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.warmBeige),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Icon',
                              style: GoogleFonts.poppins(
                                color: AppTheme.charcoalGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['☕', '🍵', '🥤', '🍋', '🫖', '🥐', '🍰', '🧁'].map((emoji) {
                                return GestureDetector(
                                  onTap: () => selectedEmoji = emoji,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selectedEmoji == emoji 
                                          ? AppTheme.deepNavy.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selectedEmoji == emoji 
                                            ? AppTheme.deepNavy 
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.charcoalGray),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                          setState(() {
                            item['name'] = nameController.text;
                            item['price'] = int.tryParse(priceController.text) ?? 0;
                            item['description'] = descriptionController.text;
                            item['category'] = selectedCategory;
                            item['image'] = selectedEmoji;
                          });
                          Navigator.pop(context);
                          _showSuccessSnackBar('Menu berhasil diperbarui!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  void _showDeleteConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.delete_rounded, color: Colors.red, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Menu',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus "${item['name']}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.charcoalGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.charcoalGray),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: AppTheme.charcoalGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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