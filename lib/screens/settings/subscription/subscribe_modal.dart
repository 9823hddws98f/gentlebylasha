import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gentle/domain/cubits/subscription/product.dart';

import '/domain/cubits/subscription/subscription_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';

class SubscribeModal extends StatefulWidget {
  const SubscribeModal({super.key, this.scrollController});

  final ScrollController? scrollController;

  static Future<void> show(BuildContext context) => Modals.showModal(
        context,
        initialSize: 1,
        maxSize: 1,
        minSize: 1,
        builder: (context, scrollController) => SubscribeModal(
          scrollController: scrollController,
        ),
      );

  @override
  State<SubscribeModal> createState() => _SubscribeModalState();
}

class _SubscribeModalState extends State<SubscribeModal> {
  final _subscriptionCubit = Get.the<SubscriptionCubit>();

  late ColorScheme _colors;

  @override
  Widget build(BuildContext context) {
    _colors = Theme.of(context).colorScheme;
    return BottomPanelSpacer.padding(
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  controller: widget.scrollController,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Unlock Sleeptales',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildBenefitItem('Every week new content'),
                    _buildBenefitItem(
                        'More then 100 + sleep stories & guided meditations'),
                    _buildBenefitItem('Cancel anytime without questions'),
                    SizedBox(height: 16.0),
                    BlocBuilder<SubscriptionCubit, SubscriptionState>(
                      bloc: _subscriptionCubit,
                      builder: (context, state) => Column(
                        children: state.products.map(_buildSubscriptionButton).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: TxButton.filled(
                  label: Text('Try for free and subscribe'),
                  onPressVoid: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colors.primary,
              ),
              child: Icon(Icons.check, size: 18, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(child: Text(text))
          ],
        ),
      );

  Widget _buildSubscriptionButton(PurchasableProduct product) => TextButton(
        style: TextButton.styleFrom(
          backgroundColor: product.status == ProductStatus.purchased
              ? _colors.primary
              : _colors.surfaceContainerLowest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.smallBorderRadius,
          ),
        ),
        onPressed: () {},
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(product.title),
              Row(
                children: [
                  Text(
                    '\$${product.price}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(' / Month'),
                ],
              ),
            ],
          ),
        ),
      );
}
