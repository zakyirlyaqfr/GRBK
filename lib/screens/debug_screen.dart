import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/pocketbase_debug.dart';
import '../utils/test_pocketbase.dart';
import '../utils/app_theme.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug PocketBase'),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PocketBase Debug Tools',
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () async {
                await PocketBaseDebug.debugPocketBase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debug info printed to console')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Debug PocketBase Connection',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () async {
                await TestPocketBase.runTests();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tests completed - check console')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Run PocketBase Tests',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.softWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warmBeige),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting Steps:',
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Make sure PocketBase is running on http://127.0.0.1:8090\n'
                    '2. Check that collections exist: users, products, cart, payment\n'
                    '3. Verify collection names match exactly (case-sensitive)\n'
                    '4. Check PocketBase admin panel for any errors\n'
                    '5. Ensure CORS is enabled with --origins="*"',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.charcoalGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
