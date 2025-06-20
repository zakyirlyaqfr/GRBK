import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../utils/image_picker_helper.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File?, String?) onImageSelected;
  final double size;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.size = 100,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedFile;
  String? _webImageData;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warmBeige.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageDisplay(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _pickImage,
          icon: _isLoading 
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt_rounded, size: 18),
          label: Text(
            _hasImage() ? 'Ganti Gambar' : 'Pilih Gambar',
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
    );
  }

  Widget _buildImageDisplay() {
    if (_selectedFile != null) {
      return Image.file(_selectedFile!, fit: BoxFit.cover);
    }
    
    if (_webImageData != null) {
      return Image.network(_webImageData!, fit: BoxFit.cover);
    }
    
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_rounded,
            size: 40,
            color: AppTheme.charcoalGray,
          );
        },
      );
    }
    
    return const Icon(
      Icons.image_rounded,
      size: 40,
      color: AppTheme.charcoalGray,
    );
  }

  bool _hasImage() {
    return _selectedFile != null || 
           _webImageData != null || 
           (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await ImagePickerHelper.pickImage();
      
      if (result != null) {
        setState(() {
          if (result['type'] == 'mobile') {
            _selectedFile = result['file'] as File;
            _webImageData = null;
          } else if (result['type'] == 'web') {
            _webImageData = result['data'] as String;
            _selectedFile = null;
          }
        });
        
        widget.onImageSelected(_selectedFile, _webImageData);
      }
    } catch (e) {
      debugPrint('Error in image picker widget: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
