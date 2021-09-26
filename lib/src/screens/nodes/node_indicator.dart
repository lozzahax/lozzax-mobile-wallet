import 'package:flutter/material.dart';
import 'package:lozzax_wallet/palette.dart';

class NodeIndicator extends StatelessWidget {
  NodeIndicator({bool active = false})
      : _color = active ? LozzaxPalette.green : LozzaxPalette.red;

  final Color _color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
    );
  }
}
