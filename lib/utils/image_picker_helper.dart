import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ImagePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<Map<String, dynamic>?> pickImage() async {
    try {
      if (kIsWeb) {
        // Web platform
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        final completer = Completer<Map<String, dynamic>?>();

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final file = files[0];
            final reader = html.FileReader();
            
            reader.onLoadEnd.listen((e) {
              final result = reader.result as String;
              debugPrint('Web image picked: ${file.name}, size: ${file.size}');
              completer.complete({
                'type': 'web',
                'data': result,
                'filename': file.name,
                'size': file.size,
              });
            });
            
            reader.onError.listen((e) {
              debugPrint('Error reading file: $e');
              completer.complete(null);
            });
            
            reader.readAsDataUrl(file);
          } else {
            completer.complete(null);
          }
        });

        return completer.future;
      } else {
        // Mobile/Desktop platform
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        
        if (image != null) {
          final file = File(image.path);
          final size = await file.length();
          debugPrint('Mobile image picked: ${image.path}, size: $size');
          
          return {
            'type': 'mobile',
            'file': file,
            'filename': image.name,
            'size': size,
          };
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    
    return null;
  }
}
