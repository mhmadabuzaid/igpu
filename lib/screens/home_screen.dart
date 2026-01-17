import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:igpu/providers/auth_provider.dart';
import 'package:igpu/providers/hardware_provider.dart';
import 'package:igpu/providers/cart_provider.dart';
import 'package:igpu/screens/admin_screen.dart';
import 'package:igpu/screens/cartscreen.dart';
import 'package:igpu/screens/details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'orders_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Existing providers
    final hardwareAsync = ref.watch(filteredHardwareProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // 2. ADMIN CHECK
    final currentUser = Supabase.instance.client.auth.currentUser;
    // Ensure this matches your login email EXACTLY
    final isAdmin = currentUser?.email == 'admin@admin.com';

    // Theme Colors
    final backgroundColor = const Color(0xFF0A0E21);
    final neonColor = Colors.cyanAccent;
    final glassColor = Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: backgroundColor,

      // <--- 2. ADD THIS BUTTON
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                );
              },
            )
          : null,

      // ---------------------
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
          onPressed: () => ref.read(authServiceProvider).signOut(),
        ),
        title: Text(
          'HARDWARE DATABASE',
          style: TextStyle(
            color: neonColor,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.purpleAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.cyanAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 2. SEARCH BAR & FILTERS AREA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Input
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search Component (e.g. RTX 4060)...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: Icon(Icons.search, color: neonColor),
                    filled: true,
                    fillColor: glassColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 10),
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'All',
                          'GPU',
                          'CPU',
                          'RAM',
                          'Monitor',
                          'Motherboard',
                          'Case',
                        ].map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
                                    cat;
                              },
                              backgroundColor: glassColor,
                              selectedColor: neonColor,
                              checkmarkColor: Colors.black,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? neonColor
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 3. THE LIST
          Expanded(
            child: hardwareAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: neonColor)),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'NO RESULTS FOUND',
                      style: TextStyle(color: Colors.white54, letterSpacing: 2),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: glassColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(item: item),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: neonColor.withOpacity(0.5),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${item.brand}  //  ${item.price} JOD',
                          style: TextStyle(color: neonColor.withOpacity(0.7)),
                        ),
                        trailing: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: neonColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: neonColor.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: backgroundColor,
                                duration: const Duration(milliseconds: 500),
                                content: Text(
                                  'ADDED: ${item.name}',
                                  style: TextStyle(color: neonColor),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
