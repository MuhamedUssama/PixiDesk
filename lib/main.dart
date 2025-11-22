import 'package:flutter/material.dart';
import 'package:pixi_desk/pixi_desk_app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PixiDesk());
}
