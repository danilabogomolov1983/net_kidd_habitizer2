import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search query for the habit list shown on the home tab.
///
/// Declared in the habit slice because browsing/searching habits is a habit
/// feature concern, even though the search box itself is rendered inside the
/// app shell's home tab.
final searchQueryProvider = StateProvider<String>((ref) => '');
