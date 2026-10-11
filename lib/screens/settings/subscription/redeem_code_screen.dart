import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '/domain/services/cloud_functions_service.dart';
import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';

/// Lets Artazest customers enter the access code they received.
class RedeemCodeScreen extends StatefulWidget {
  const RedeemCodeScreen({super.key});

  @override
  State<RedeemCodeScreen> createState() => _RedeemCodeScreenState();
}

class _RedeemCodeScreenState extends State<RedeemCodeScreen> with Translation {
  final _controller = TextEditingController();
  final _trigger = ActionTrigger();

  String? _error;
  String? _success;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return false;
    setState(() => _error = _success = null);
    try {
      final expiresAt = await CloudFunctionsService.redeemCode(code);
      final locale = Localizations.localeOf(context).toLanguageTag();
      setState(() => _success = expiresAt == null
          ? tr.codeRedeemedLifetime
          : tr.codeRedeemedUntil(DateFormat.yMMMMd(locale).format(expiresAt)));
      return true;
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = switch (e.message) {
            'not-found' => tr.codeNotFound,
            'already-redeemed' => tr.codeAlreadyRedeemed,
            'disabled' => tr.codeDisabled,
            'too-many-attempts' => tr.codeTooManyAttempts,
            _ => tr.somethingWentWrong,
          });
      return false;
    } catch (_) {
      setState(() => _error = tr.somethingWentWrong);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: (context, isMobile) => AdaptiveAppBar(title: tr.redeemCode),
      body: (context, isMobile) => BottomPanelSpacer.padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  Text(tr.redeemCodeDescription, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    enabled: _success == null,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [LengthLimitingTextInputFormatter(24)],
                    style: const TextStyle(fontSize: 20, letterSpacing: 2),
                    decoration: InputDecoration(
                      hintText: 'GENTLE-XXXX-XXXX',
                      errorText: _error,
                      errorMaxLines: 3,
                    ),
                    onSubmitted: (_) => _trigger.trigger(),
                  ),
                  if (_success != null) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_success!, style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.sidePadding),
              child: _success == null
                  ? TxButton.filled(
                      label: Text(tr.redeem),
                      trigger: _trigger,
                      onPress: _redeem,
                    )
                  : TxButton.filled(
                      label: Text(tr.continueText),
                      onPressVoid: () => Navigator.pop(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
