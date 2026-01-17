import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hardware_provider.dart';

class AdminNotifier extends StateNotifier<bool> {
  AdminNotifier(this.ref) : super(false);

  final Ref ref;
  final _supabase = Supabase.instance.client;

  // Add Item (Kept the same)
  Future<void> addItem({
    required String name,
    required double price,
    required String brand,
    required String type,
    required String description,
    required File imageFile,
  }) async {
    state = true;
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = '/$fileName';

      await _supabase.storage
          .from('hardware_items')
          .upload(filePath, imageFile);
      final imageUrl = _supabase.storage
          .from('hardware_items')
          .getPublicUrl(filePath);

      await _supabase.from('hardware').insert({
        'name': name,
        'price': price,
        'brand': brand,
        'type': type,
        'description': description,
        'image_url': imageUrl,
      });

      ref.invalidate(hardwareProvider);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  // --- NEW: DELETE FUNCTION ---
  Future<void> deleteItem(int id, String imageUrl) async {
    state = true; // Start Loading

    try {
      // 1. Delete Image from Storage (Only if it exists in OUR bucket)
      // This prevents crashing if you try to delete an Unsplash/Amazon image
      if (imageUrl.contains('hardware_items')) {
        // Extract filename from URL (e.g. ".../public/hardware_items/image.png" -> "image.png")
        final fileName = imageUrl.split('/').last;
        await _supabase.storage.from('hardware_items').remove([fileName]);
      }

      // 2. Delete Data from Database
      await _supabase.from('hardware').delete().eq('id', id);

      // 3. Refresh the List
      ref.invalidate(hardwareProvider);
    } catch (e) {
      print('Error deleting: $e');
      rethrow;
    } finally {
      state = false; // Stop Loading
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, bool>((ref) {
  return AdminNotifier(ref);
});
