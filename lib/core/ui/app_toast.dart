import 'package:flutter/material.dart';

/// Root messenger used when no [BuildContext] messenger is available.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Bottom clearance so floating snackbars sit above [GlassBottomNav].
const double kToastBottomClearance = 88;

/// Low-invasive floating toast — short duration, lifted above the glass nav.
void showAppToast(
  String message, {
  BuildContext? context,
  ScaffoldMessengerState? messenger,
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 2),
}) {
  final state =
      messenger ??
      (context != null ? ScaffoldMessenger.maybeOf(context) : null) ??
      appMessengerKey.currentState;
  if (state == null) return;

  final bottomInset = context != null
      ? MediaQuery.maybeViewPaddingOf(context)?.bottom ?? 0
      : 0.0;

  state.hideCurrentSnackBar();
  state.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 13.5, height: 1.25),
      ),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        kToastBottomClearance + bottomInset,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: action,
    ),
  );
}
