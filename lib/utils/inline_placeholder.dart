import 'package:flutter/widgets.dart';

/// Stand-in passed to a translated message for a placeholder that is shown as
/// a widget or styled span instead of plain text (U+FFFC, object replacement
/// character). Each translation can put the placeholder where its grammar
/// needs it.
const inlinePlaceholder = '￼';

/// The spans of [message] (built with [inlinePlaceholder]) with [inserted] in
/// place of the placeholder. Without a placeholder, the message is returned as is.
List<InlineSpan> spansWithPlaceholder(String message, InlineSpan inserted) {
  final index = message.indexOf(inlinePlaceholder);
  if (index < 0) return [TextSpan(text: message)];
  return [
    if (index > 0) TextSpan(text: message.substring(0, index)),
    inserted,
    if (index + inlinePlaceholder.length < message.length)
      TextSpan(text: message.substring(index + inlinePlaceholder.length)),
  ];
}
