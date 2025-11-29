import 'package:equatable/equatable.dart';

class ConversionProgress extends Equatable {
  final int currentPage;
  final int totalPages;
  final double percentage;

  const ConversionProgress({
    required this.currentPage,
    required this.totalPages,
    required this.percentage,
  });

  @override
  List<Object?> get props => [currentPage, totalPages, percentage];
}
