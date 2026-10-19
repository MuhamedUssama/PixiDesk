import 'package:flutter/material.dart';
import 'package:pixi_desk/pixi_desk_app.dart';
import 'core/di/injection.dart';

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(PixiDesk(initialImagePaths: arguments));
}
