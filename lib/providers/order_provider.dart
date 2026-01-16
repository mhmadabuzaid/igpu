import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hardware_item.dart';
import 'cart_provider.dart'; // Needed to clear the cart

// 1. The Order Model (Simple version)
class Order {
  final int id;
  final double totalPrice;
  final DateTime date;

  Order({required this.id, required this.totalPrice, required this.date});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      totalPrice: (json['total_price'] as num).toDouble(),
      date: DateTime.parse(json['created_at']),
    );
  }
}

// 2. The Logic Class
class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier(this.ref) : super([]) {
    loadOrders();
  }

  final Ref ref;
  final _supabase = Supabase.instance.client;

  // Fetch Past Orders
  Future<void> loadOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final response = await _supabase
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false); // Newest first

    state = (response as List).map((data) => Order.fromJson(data)).toList();
  }

  // THE BIG ONE: Checkout Function
  Future<void> checkout(List<HardwareItem> cartItems, double total) async {
    final user = _supabase.auth.currentUser;
    if (user == null || cartItems.isEmpty) return;

    // A. Create the "Receipt" (Order)
    final orderResponse = await _supabase
        .from('orders')
        .insert({'user_id': user.id, 'total_price': total})
        .select()
        .single();

    final orderId = orderResponse['id'];

    // B. Create the "Line Items"
    final List<Map<String, dynamic>> itemsToInsert = cartItems.map((item) {
      return {
        'order_id': orderId,
        'hardware_id': item.id,
        'price_at_purchase': item.price,
      };
    }).toList();

    await _supabase.from('order_items').insert(itemsToInsert);

    // C. Clear the Cart (Database)
    await _supabase.from('cart').delete().eq('user_id', user.id);

    // D. Refresh App State
    await ref.read(cartProvider.notifier).loadCart(); // Clears UI Cart
    await loadOrders(); // Updates History List
  }
}

// 3. The Provider
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref);
});
