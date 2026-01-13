import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Don't forget this import!
import 'package:igpu/providers/auth_provider.dart';
import 'package:igpu/providers/hardware_provider.dart';

// 2. Change from StatefulWidget to ConsumerWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  // 3. Add 'WidgetRef ref' as the second parameter
  Widget build(BuildContext context, WidgetRef ref) {
    final hardwareAsync = ref.watch(hardwareProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PC Parts Store'),actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            ref.read(authServiceProvider).signOut();
          },
        ),
      ],),
      body: hardwareAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  // Check if image URL is valid, otherwise show initial
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, fit: BoxFit.cover)
                      : CircleAvatar(child: Text(item.type[0])),
                ),
                title: Text(item.name),
                subtitle: Text('${item.brand} - ${item.price} JOD'),
                trailing: const Icon(Icons.add_shopping_cart),
              ),
            );
          },
        ),
      ),
    );
  }
}
