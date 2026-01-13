import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hardware_item.dart';

// 1. Fetch All Hardware
final hardwareProvider = FutureProvider<List<HardwareItem>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('hardware').select();
  return response.map((json) => HardwareItem.fromJson(json)).toList();
});

// 2. Filter by Type (e.g., only GPUs) - Optional for later
final gpuProvider = FutureProvider<List<HardwareItem>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('hardware').select().eq('type', 'GPU');
  return response.map((json) => HardwareItem.fromJson(json)).toList();
});
final cpuProvider = FutureProvider<List<HardwareItem>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('hardware').select().eq('type', 'CPU');
  return response.map((json) => HardwareItem.fromJson(json)).toList();
});
final motherboardProvider = FutureProvider<List<HardwareItem>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('hardware').select().eq('type', 'Motherboard');
  return response.map((json) => HardwareItem.fromJson(json)).toList();
});

