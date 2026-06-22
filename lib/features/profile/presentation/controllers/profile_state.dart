import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final bool isEditing;
  final bool saved;

  const ProfileLoaded({
    required this.profile,
    this.isEditing = false,
    this.saved = false,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isEditing,
    bool? saved,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [profile, isEditing, saved];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}