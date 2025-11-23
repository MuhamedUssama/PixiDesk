import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/di/injection.dart';
import 'package:pixi_desk/features/image_processing/presentation/cubit/image_cubit.dart';
import 'package:pixi_desk/features/image_processing/presentation/pages/image_processing_page.dart';
import 'package:pixi_desk/features/landing/presentation/pages/main_landing_page.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/cubit/pdf_converter_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/pages/pdf_converter_page.dart';
import 'package:pixi_desk/features/pdf/pdf_tools_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String imageProcessingRoute = '/image-processing';
  static const String pdfConverterRoute = '/pdf-converter';
  static const String pdfToolsRoute = '/pdf-tools';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (context) => const MainLandingPage());
      case imageProcessingRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<ImageCubit>(),
            child: const ImageProcessingPage(),
          ),
        );
      case pdfConverterRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<PdfConverterCubit>(),
            child: const PdfConverterPage(),
          ),
        );
      case pdfToolsRoute:
        return MaterialPageRoute(builder: (context) => const PdfToolsPage());
      default:
        return MaterialPageRoute(builder: (context) => const MainLandingPage());
    }
  }
}
