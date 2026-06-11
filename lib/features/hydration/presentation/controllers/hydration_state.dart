import 'package:equatable/equatable.dart';
import '../../domain/entities/hydration_entity.dart';

abstract class HydrationState extends Equatable {
  const HydrationState();
  @override
  List<Object?> get props => [];
}

class HydrationInitial extends HydrationState {
  const HydrationInitial();
}

class HydrationLoading extends HydrationState {
  const HydrationLoading();
}

class HydrationLoaded extends HydrationState {
  final HydrationSummary summary;
  final int customAmountMl;

  const HydrationLoaded({
    required this.summary,
    this.customAmountMl = 250,
  });

  HydrationLoaded copyWith({
    HydrationSummary? summary,
    int? customAmountMl,
  }) {
    return HydrationLoaded(
      summary: summary ?? this.summary,
      customAmountMl: customAmountMl ?? this.customAmountMl,
    );
  }

  @override
  List<Object?> get props => [summary, customAmountMl];
}

class HydrationError extends HydrationState {
  final String message;
  const HydrationError(this.message);
  @override
  List<Object?> get props => [message];
}