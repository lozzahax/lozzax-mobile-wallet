import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lozzax_wallet/generated/l10n.dart';
import 'package:lozzax_wallet/palette.dart';
import 'package:lozzax_wallet/src/widgets/primary_button.dart';
import 'package:lozzax_wallet/src/widgets/slide_to_act.dart';

Future showLozzaxDialog(BuildContext context, Widget child,
    {void Function(BuildContext context) onDismiss}) {
  return showDialog<void>(
      builder: (_) => LozzaxDialog(body: child, onDismiss: onDismiss),
      context: context);
}

Future showSimpleLozzaxDialog(BuildContext context, String title, String body,
    {String buttonText,
    void Function(BuildContext context) onPressed,
    void Function(BuildContext context) onDismiss}) {
  return showDialog<void>(
      builder: (_) => SimpleLozzaxDialog(title, body,
          buttonText: buttonText, onDismiss: onDismiss, onPressed: onPressed),
      context: context);
}

Future showConfirmLozzaxDialog(BuildContext context, String title, String body,
    {void Function(BuildContext context) onConfirm,
    Future Function(BuildContext context) onFutureConfirm,
    void Function(BuildContext context) onDismiss}) {
  return showDialog<void>(
      builder: (_) => ConfirmLozzaxDialog(title, body,
          onDismiss: onDismiss,
          onConfirm: onConfirm,
          onFutureConfirm: onFutureConfirm),
      context: context);
}

class LozzaxDialog extends StatelessWidget {
  LozzaxDialog({this.body, this.onDismiss});

  final void Function(BuildContext context) onDismiss;
  final Widget body;

  void _onDismiss(BuildContext context) {
    if (onDismiss == null) {
      Navigator.of(context).pop();
    } else {
      onDismiss(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onDismiss(context),
      child: Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.55)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleLozzaxDialog extends StatelessWidget {
  SimpleLozzaxDialog(this.title, this.body,
      {this.buttonText, this.onPressed, this.onDismiss});

  final String title;
  final String body;
  final String buttonText;
  final void Function(BuildContext context) onPressed;
  final void Function(BuildContext context) onDismiss;

  @override
  Widget build(BuildContext context) {
    return LozzaxDialog(
        onDismiss: onDismiss,
        body: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.none,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .caption
                              .color))),
              Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  child: Text(body,
                      style: TextStyle(
                          fontSize: 15,
                          decoration: TextDecoration.none,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .caption
                              .color))),
              PrimaryButton(
                  text: buttonText ?? S.of(context).ok,
                  color:
                      Theme.of(context).primaryTextTheme.button.backgroundColor,
                  borderColor:
                      Theme.of(context).primaryTextTheme.button.decorationColor,
                  onPressed: () {
                    if (onPressed != null) onPressed(context);
                  })
            ],
          ),
        ));
  }
}

class ConfirmLozzaxDialog extends StatelessWidget {
  ConfirmLozzaxDialog(this.title, this.body,
      {this.onFutureConfirm, this.onConfirm, this.onDismiss});

  final String title;
  final String body;
  final Future Function(BuildContext context) onFutureConfirm;
  final void Function(BuildContext context) onConfirm;
  final void Function(BuildContext context) onDismiss;

  @override
  Widget build(BuildContext context) {
    return LozzaxDialog(
        onDismiss: onDismiss,
        body: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.none,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .caption
                              .color))),
              Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  child: Text(body,
                      style: TextStyle(
                          fontSize: 15,
                          decoration: TextDecoration.none,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .caption
                              .color))),
              SlideToAct(
                text: S.of(context).ok,
                outerColor: Theme.of(context).primaryTextTheme.subtitle2.color,
                innerColor: LozzaxPalette.teal,
                onFutureSubmit: onFutureConfirm != null
                    ? () async => await onFutureConfirm(context)
                    : null,
                onSubmit: onConfirm != null ? () => onConfirm(context) : null,
              )
            ],
          ),
        ));
  }
}
