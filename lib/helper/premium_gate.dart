import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/entitlement_cubit.dart';
import '/domain/models/block_item/audio_track.dart';
import '/main.dart';
import '/screens/settings/subscription/subscribe_modal.dart';
import '/utils/get.dart';

bool canPlay(AudioTrack track) =>
    Get.the<EntitlementCubit>().state.canPlay(premiumTrack: track.premium);

/// Returns true when [track] may be played; otherwise opens the paywall.
bool requireAccess(AudioTrack track) {
  if (canPlay(track)) return true;
  final context = MyApp.navigatorKey.currentContext;
  if (context != null) SubscribeModal.show(context);
  return false;
}

/// Small lock shown on premium tracks while the user has no premium access.
class PremiumLock extends StatelessWidget {
  final AudioTrack track;
  final double size;

  const PremiumLock({super.key, required this.track, this.size = 16});

  @override
  Widget build(BuildContext context) {
    if (!track.premium) return const SizedBox.shrink();
    return BlocBuilder<EntitlementCubit, Entitlement>(
      bloc: Get.the<EntitlementCubit>(),
      builder: (context, entitlement) => entitlement.isPremium
          ? const SizedBox.shrink()
          : Icon(Icons.lock_rounded, size: size, semanticLabel: 'Premium'),
    );
  }
}
