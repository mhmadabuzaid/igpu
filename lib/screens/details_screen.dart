import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import '../models/hardware_item.dart';
import '../providers/cart_provider.dart';
import '../providers/admin_provider.dart'; // 2. Import Admin Provider

class DetailsScreen extends ConsumerWidget {
  final HardwareItem item;

  const DetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = const Color(0xFF0A0E21);
    final neonColor = Colors.cyanAccent;

    // 3. ADMIN CHECK
    final currentUser = Supabase.instance.client.auth.currentUser;
    // MAKE SURE THIS MATCHES YOUR ADMIN EMAIL EXACTLY
    final isAdmin = currentUser?.email == 'admin@admin.com';

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: neonColor,
          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
        ),
        // 4. DELETE BUTTON (Only visible to Admin)
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                // Confirm Dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF0A0E21),
                    title: const Text(
                      'DELETE ITEM?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('CANCEL'),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                      TextButton(
                        child: const Text(
                          'DELETE',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  // Call the Provider to Delete
                  await ref
                      .read(adminProvider.notifier)
                      .deleteItem(item.id, item.imageUrl);

                  if (context.mounted) {
                    Navigator.pop(context); // Close details screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item Deleted Successfully'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO IMAGE
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.black,
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, backgroundColor],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // PRODUCT INFO
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: neonColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: neonColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      item.brand.toUpperCase(),
                      style: TextStyle(
                        color: neonColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    item.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '${item.price} JOD',
                    style: TextStyle(
                      color: neonColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),

                  // Description Label
                  const Text(
                    'SPECIFICATIONS',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Text
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : "High-performance component designed for optimal efficiency in gaming and professional workflows. Features advanced cooling architecture and reliable power delivery.",
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // FLOATING ACTION BUTTON
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60,
        child: FloatingActionButton.extended(
          backgroundColor: neonColor,
          onPressed: () {
            ref.read(cartProvider.notifier).addToCart(item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: backgroundColor,
                content: Text(
                  'ADDED TO CART',
                  style: TextStyle(color: neonColor),
                ),
              ),
            );
          },
          label: const Text(
            'ADD TO SYSTEM',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
