import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:igpu/providers/auth_provider.dart';
import 'package:igpu/providers/hardware_provider.dart';
import 'package:igpu/providers/cart_provider.dart';
import 'package:igpu/screens/cartscreen.dart';
import 'package:igpu/screens/orders_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hardwareAsync = ref.watch(hardwareProvider);

    // Theme Colors
    final backgroundColor = const Color(0xFF0A0E21);
    final neonColor = Colors.cyanAccent;
    final glassColor = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        // 1. LEFT SIDE (Logout)
        leading: IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
          onPressed: () {
            ref.read(authServiceProvider).signOut();
          },
        ),

        // 2. CENTER (Title)
        title: Text(
          'HARDWARE DATABASE',
          style: TextStyle(
            color: neonColor,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        // 3. RIGHT SIDE (Cart)
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.receipt_long,
              color: Colors.purpleAccent,
            ), // Purple for history
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
          ),
        ],
      ),

      // Rest of the body stays exactly the same...
      body: hardwareAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: neonColor)),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (items) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: glassColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: neonColor.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: neonColor,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white24,
                                  size: 20,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              item.type.isNotEmpty ? item.type[0] : '?',
                              style: TextStyle(color: neonColor),
                            ),
                          ),
                  ),
                ),
                title: Text(
                  item.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: neonColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.brand,
                          style: TextStyle(color: neonColor, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${item.price} JOD',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: neonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: neonColor.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: backgroundColor,
                          content: Text(
                            'ADDED: ${item.name}',
                            style: TextStyle(color: neonColor),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
