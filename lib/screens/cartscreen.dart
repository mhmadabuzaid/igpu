import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the Cart Items
    final cartItems = ref.watch(cartProvider);

    // 2. Calculate Total Price
    final total = cartItems.fold(0.0, (sum, item) => sum + item.price);

    // Theme Colors
    final backgroundColor = const Color(0xFF0A0E21);
    final neonColor = Colors.cyanAccent;
    final glassColor = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ASSEMBLY BAY', // Sci-fi name for "Cart"
          style: TextStyle(
            color: neonColor,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: neonColor),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.computer, size: 80, color: Colors.white24),
                  SizedBox(height: 20),
                  Text(
                    'NO COMPONENTS DETECTED',
                    style: TextStyle(color: Colors.white54, letterSpacing: 1.5),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // THE LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              cacheWidth: 150, // Optimize memory
                              errorBuilder: (c, e, s) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[900],
                                child: Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${item.brand} // ${item.price} JOD',
                            style: TextStyle(color: neonColor.withOpacity(0.7)),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .removeFromCart(item.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // THE FOOTER (Total & Checkout)
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(color: neonColor.withOpacity(0.3)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SYSTEM TOTAL',
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '$total JOD',
                            style: TextStyle(
                              color: neonColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Payment Gateway not implemented yet!',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'INITIALIZE CHECKOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
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
