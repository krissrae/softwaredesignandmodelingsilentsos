import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF2F2F2);
  static const card = Color(0xFFE6E6E6);
  static const primary = Color(0xFF5672A8); // bluish from mockups
  static const danger = Color(0xFFE11212);
  static const dark = Color(0xFF111111);
  static const muted = Color(0xFFBDBDBD);
}

RoundedRectangleBorder rounded([double r = 20]) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

ButtonStyle pillButton(Color c, {EdgeInsets pad = const EdgeInsets.symmetric(horizontal: 22, vertical: 14)}) =>
  ElevatedButton.styleFrom(
    backgroundColor: c,
    foregroundColor: Colors.white,
    shape: rounded(32),
    padding: pad,
    elevation: 0,
  );

Card roundedCard({EdgeInsets? padding, Color? color, double radius = 26, Widget? child}) => Card(
  margin: EdgeInsets.zero,
  color: color ?? AppColors.card,
  shape: rounded(radius),
  elevation: 0,
  child: Padding(padding: padding ?? const EdgeInsets.all(18), child: child ?? const SizedBox()),
);
