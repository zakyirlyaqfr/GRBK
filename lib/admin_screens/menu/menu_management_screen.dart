import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../../../utils/app_theme.dart';
import '../../../providers/product_provider.dart';
import '../../../models/product_model.dart';

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
    'Food'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
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
              _buildResponsiveHeader(constraints),
              SizedBox(height: constraints.maxHeight > 700 ? 24 : 16),
              _buildSearchAndFilter(constraints),
              SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
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
      return Column(
        children: [
          _buildSearchField(constraints),
          const SizedBox(height: 12),
          _buildCategoryFilter(constraints),
        ],
      );
    } else {
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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${productProvider.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredProducts = _getFilteredProducts(productProvider.products);

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
              Container(
                padding: EdgeInsets.all(constraints.maxWidth < 400 ? 12 : 16),
                decoration: const BoxDecoration(
                  gradient: AppTheme.lightGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _buildTableHeader(constraints),
              ),
              Expanded(
                child: filteredProducts.isEmpty 
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(constraints.maxWidth < 400 ? 12 : 16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildMenuRow(product, index, constraints);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    List<ProductModel> filtered = products;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.name.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
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

  Widget _buildMenuRow(ProductModel product, int index, BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(constraints.maxWidth < 400 ? 10 : 12),
      decoration: BoxDecoration(
        color: AppTheme.softWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.3)),
      ),
      child: constraints.maxWidth < 600 
          ? _buildMobileMenuRow(product, constraints)
          : _buildDesktopMenuRow(product, constraints),
    );
  }

  Widget _buildMobileMenuRow(ProductModel product, BoxConstraints constraints) {
    return Column(
      children: [
        Row(
          children: [
            _buildProductImage(product, constraints.maxWidth < 400 ? 35 : 40),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: constraints.maxWidth < 400 ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.category,
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
            Expanded(
              child: Text(
                'Rp ${product.price}',
                style: GoogleFonts.oswald(
                  fontSize: constraints.maxWidth < 400 ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepNavy,
                ),
              ),
            ),
            _buildActionMenu(product),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopMenuRow(ProductModel product, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              _buildProductImage(product, 40),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.description,
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
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.warmBeige.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.category,
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
        Expanded(
          child: Text(
            'Rp ${product.price}',
            style: GoogleFonts.oswald(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepNavy,
            ),
          ),
        ),
        _buildActionMenu(product),
      ],
    );
  }

  Widget _buildProductImage(ProductModel product, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.lightGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: product.image != null && product.image!.isNotEmpty
            ? Image.network(
                context.read<ProductProvider>().getImageUrl(product),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_rounded,
                    color: AppTheme.charcoalGray,
                    size: 20,
                  );
                },
              )
            : const Icon(
                Icons.image_rounded,
                color: AppTheme.charcoalGray,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildActionMenu(ProductModel product) {
    return SizedBox(
      width: 40,
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, product),
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

  void _handleMenuAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        _showEditMenuDialog(product);
        break;
      case 'delete':
        _showDeleteConfirmDialog(product);
        break;
    }
  }

  // Updated image picker method with improved web support
  Future<void> _pickImageForDialog(Function(File?, String?) onImageSelected) async {
    try {
      if (kIsWeb) {
        // Web platform - use HTML file input
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
              debugPrint('Web image selected: ${file.name}');
              debugPrint('Data URL length: ${result.length}');
              debugPrint('Data URL preview: ${result.substring(0, 50)}...');
              onImageSelected(null, result);
            });
            
            reader.onError.listen((e) {
              debugPrint('Error reading file: $e');
              _showErrorSnackBar('Gagal membaca file gambar');
            });
            
            reader.readAsDataUrl(file);
          }
        });
      } else {
        // Mobile/Desktop platform - use ImagePicker
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        
        if (image != null) {
          debugPrint('Mobile image selected: ${image.path}');
          onImageSelected(File(image.path), null);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Kopi Susu';
    File? selectedImageFile;
    String? webImageData;

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
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: selectedImageFile != null
                                    ? Image.file(
                                        selectedImageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : webImageData != null
                                      ? Image.network(
                                          webImageData!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            debugPrint('Error loading web image: $error');
                                            return const Icon(
                                              Icons.image_rounded,
                                              size: 40,
                                              color: AppTheme.charcoalGray,
                                            );
                                          },
                                        )
                                      : const Icon(
                                          Icons.image_rounded,
                                          size: 40,
                                          color: AppTheme.charcoalGray,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _pickImageForDialog((file, webData) {
                                  debugPrint('Image picked - File: ${file?.path}, WebData length: ${webData?.length}');
                                  setDialogState(() {
                                    selectedImageFile = file;
                                    webImageData = webData;
                                  });
                                }),
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: Text(
                                  (selectedImageFile != null || webImageData != null) ? 'Ganti Gambar' : 'Pilih Gambar',
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
                        
                        _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setDialogState(() => selectedCategory = value!),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 14),
                            prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.warmBeige),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.deepNavy, width: 2),
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
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.charcoalGray),
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
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          return ElevatedButton(
                            onPressed: productProvider.isLoading ? null : () async {
                              if (nameController.text.isNotEmpty && 
                                  priceController.text.isNotEmpty) {
                                
                                debugPrint('=== CREATING PRODUCT ===');
                                debugPrint('Name: ${nameController.text}');
                                debugPrint('Price: ${priceController.text}');
                                debugPrint('Category: $selectedCategory');
                                debugPrint('Description: ${descriptionController.text}');
                                debugPrint('Has image file: ${selectedImageFile != null}');
                                debugPrint('Has web image data: ${webImageData != null && webImageData!.isNotEmpty}');
                                if (webImageData != null) {
                                  debugPrint('Web image data length: ${webImageData!.length}');
                                  debugPrint('Web image data preview: ${webImageData!.substring(0, 50)}...');
                                }
                                
                                final success = await productProvider.createProduct(
                                  name: nameController.text,
                                  price: int.tryParse(priceController.text) ?? 0,
                                  category: selectedCategory,
                                  description: descriptionController.text,
                                  imageFile: selectedImageFile,
                                  webImageData: webImageData, // IMPORTANT: Pass webImageData
                                );
                                
                                if (success) {
                                  Navigator.pop(context);
                                  _showSuccessSnackBar('Menu baru berhasil ditambahkan!');
                                } else {
                                  _showErrorSnackBar(productProvider.error ?? 'Gagal menambahkan menu');
                                }
                              } else {
                                _showErrorSnackBar('Mohon lengkapi semua field wajib');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepNavy,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: productProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Tambah Menu',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          );
                        },
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

  void _showEditMenuDialog(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final descriptionController = TextEditingController(text: product.description);
    String selectedCategory = product.category;
    File? selectedImageFile;
    String? webImageData;

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
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: selectedImageFile != null
                                    ? Image.file(
                                        selectedImageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : webImageData != null
                                      ? Image.network(
                                          webImageData!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image_rounded,
                                              size: 40,
                                              color: AppTheme.charcoalGray,
                                            );
                                          },
                                        )
                                      : (product.image != null && product.image!.isNotEmpty
                                          ? Image.network(
                                              context.read<ProductProvider>().getImageUrl(product),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_rounded,
                                                  size: 40,
                                                  color: AppTheme.charcoalGray,
                                                );
                                              },
                                            )
                                          : const Icon(
                                              Icons.image_rounded,
                                              size: 40,
                                              color: AppTheme.charcoalGray,
                                            )),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _pickImageForDialog((file, webData) {
                                  setDialogState(() {
                                    selectedImageFile = file;
                                    webImageData = webData;
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
                        
                        _buildDialogTextField('Nama Menu', nameController, Icons.restaurant_menu_rounded),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Harga', priceController, Icons.attach_money_rounded, isNumber: true),
                        const SizedBox(height: 16),
                        
                        _buildDialogTextField('Deskripsi', descriptionController, Icons.description_rounded, maxLines: 3),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          onChanged: (value) => setDialogState(() => selectedCategory = value!),
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: GoogleFonts.poppins(color: AppTheme.charcoalGray, fontSize: 14),
                            prefixIcon: const Icon(Icons.category_rounded, color: AppTheme.charcoalGray, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.warmBeige),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.deepNavy, width: 2),
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
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.charcoalGray),
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
                      child: Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          return ElevatedButton(
                            onPressed: productProvider.isLoading ? null : () async {
                              if (nameController.text.isNotEmpty && 
                                  priceController.text.isNotEmpty) {
                                
                                debugPrint('=== UPDATING PRODUCT ===');
                                debugPrint('ID: ${product.id}');
                                debugPrint('Name: ${nameController.text}');
                                debugPrint('Has image file: ${selectedImageFile != null}');
                                debugPrint('Has web image data: ${webImageData != null && webImageData!.isNotEmpty}');
                                
                                final success = await productProvider.updateProduct(
                                  id: product.id,
                                  name: nameController.text,
                                  price: int.tryParse(priceController.text) ?? 0,
                                  category: selectedCategory,
                                  description: descriptionController.text,
                                  imageFile: selectedImageFile,
                                  webImageData: webImageData, // IMPORTANT: Pass webImageData
                                );
                                
                                if (success) {
                                  Navigator.pop(context);
                                  _showSuccessSnackBar('Menu berhasil diperbarui!');
                                } else {
                                  _showErrorSnackBar(productProvider.error ?? 'Gagal memperbarui menu');
                                }
                              } else {
                                _showErrorSnackBar('Mohon lengkapi semua field wajib');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepNavy,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: productProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Simpan Perubahan',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          );
                        },
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

  void _showDeleteConfirmDialog(ProductModel product) {
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
                'Apakah Anda yakin ingin menghapus "${product.name}"? Tindakan ini tidak dapat dibatalkan.',
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
                          side: const BorderSide(color: AppTheme.charcoalGray),
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
                    child: Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        return ElevatedButton(
                          onPressed: productProvider.isLoading ? null : () async {
                            final success = await productProvider.deleteProduct(product.id);
                            
                            if (success) {
                              Navigator.pop(context);
                              _showSuccessSnackBar('Menu berhasil dihapus!');
                            } else {
                              _showErrorSnackBar(productProvider.error ?? 'Gagal menghapus menu');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: productProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Hapus',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        );
                      },
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
          borderSide: const BorderSide(color: AppTheme.warmBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.deepNavy, width: 2),
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
