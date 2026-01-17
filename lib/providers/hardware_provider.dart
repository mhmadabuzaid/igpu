import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hardware_item.dart';


// 1. The Raw Data (Fetches everything once)
final hardwareProvider = FutureProvider<List<HardwareItem>>((ref) async {
  final response = await Supabase.instance.client
      .from('hardware')
      .select()
      .order('price', ascending: true); // Sort by cheapest first

  return (response as List).map((json) => HardwareItem.fromJson(json)).toList();
});

// 2. The Search Text State
final searchQueryProvider = StateProvider<String>((ref) => '');

// 3. The Category Filter State
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// 4. THE SMART PROVIDER (Filtered List)
// This provider watches the original list AND the search text AND the category.
// If any of them change, this updates automatically!
final filteredHardwareProvider = Provider<AsyncValue<List<HardwareItem>>>((
  ref,
) {
  final hardwareAsync = ref.watch(hardwareProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return hardwareAsync.whenData((items) {
    return items.where((item) {
      // Filter 1: Does the name match the search text?
      final matchesSearch = item.name.toLowerCase().contains(query);

      // Filter 2: Does the category match? (Or is "All" selected?)
      final matchesCategory = category == 'All' || item.type == category;

      return matchesSearch && matchesCategory;
    }).toList();
  });
});
