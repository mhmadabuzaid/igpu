import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hardware_item.dart';

// 1. The Cart State (List of Items)
class CartNotifier extends StateNotifier<List<HardwareItem>> {
  CartNotifier() : super([]) {
    loadCart();
  }

  final _supabase = Supabase.instance.client;

  // Load Cart from Database
  Future<void> loadCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final response = await _supabase
        .from('cart')
        .select('hardware_id, hardware(*)') // Fetch the actual Hardware details
        .eq('user_id', user.id);

    final List<HardwareItem> loadedItems = [];
    for (var row in response) {
      // Supabase returns nested data like: { hardware: { name: "GPU", ... } }
      if (row['hardware'] != null) {
        loadedItems.add(HardwareItem.fromJson(row['hardware']));
      }
    }
    state = loadedItems;
  }

  // Add Item to Database
  Future<void> addToCart(int hardwareId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Optimistic Update (Show it in UI immediately)
    // We can't do this easily without the full object, so we'll just wait for the DB.

    // 2. Send to Supabase
    await _supabase.from('cart').insert({
      'user_id': user.id,
      'hardware_id': hardwareId,
    });

    // 3. Refresh the list
    await loadCart();
  }

  // Remove Item
  Future<void> removeFromCart(int hardwareId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Remove from Database
    await _supabase
        .from('cart')
        .delete()
        .eq('user_id', user.id)
        .eq('hardware_id', hardwareId);

    // Refresh
    await loadCart();
  }
}

// 2. The Provider Definition
final cartProvider = StateNotifierProvider<CartNotifier, List<HardwareItem>>((
  ref,
) {
  return CartNotifier();
});
