import 'package:flutter/material.dart';
import 'app.dart';
import 'core/infrastructure/database/database_factory_initializer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  runApp(const HabitizerApp());
}
