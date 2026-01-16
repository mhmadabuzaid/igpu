import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
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
          'ASSEMBLY BAY',
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
                  const Icon(Icons.computer, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  const Text(
                    'NO COMPONENTS DETECTED',
                    style: TextStyle(color: Colors.white54, letterSpacing: 1.5),
                  ),
                ],
              ),
            )
          : Column(
              children: [
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
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              cacheWidth: 150,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${item.price} JOD',
                            style: TextStyle(color: neonColor),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
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
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(color: neonColor.withOpacity(0.3)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SYSTEM TOTAL',
                            style: TextStyle(color: Colors.white70),
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
                          ),
                          // 2. THE REAL CHECKOUT LOGIC
                          onPressed: () async {
                            await ref
                                .read(orderProvider.notifier)
                                .checkout(cartItems, total);
                            if (context.mounted) {
                              Navigator.pop(context); // Close Cart
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: backgroundColor,
                                  content: Text(
                                    'TRANSACTION RECORDED',
                                    style: TextStyle(color: neonColor),
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'INITIALIZE CHECKOUT',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
