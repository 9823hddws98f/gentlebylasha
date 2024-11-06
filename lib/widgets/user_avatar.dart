import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/blocs/user/user_bloc.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.radius = 20,
    this.imageUrl,
  });

  final double radius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) return _buildImage(imageUrl!);
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) => _buildImage(
        state.user.photoURL!,
      ),
    );
  }

  Widget _buildImage(String imageUrl) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black38,
        backgroundImage: NetworkImage(imageUrl),
      );
}
