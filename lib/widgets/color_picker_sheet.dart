import 'package:flutter/material.dart';

class ColorPickerSheet extends StatelessWidget {
  final List<Color> colors = const [
    Colors.cyan,
    Color(0xFFB2F7EF), // pastel mint
    Color(0xFFFFB6B9), // pastel pink
    Color(0xFFFFE29A), // pastel yellow
    Color(0xFFB5EAD7), // pastel green
    Color(0xFFB2CEFE), // pastel blue
    Color(0xFFFFD6E0), // pastel rose
    Color(0xFFFFC3A0), // pastel orange
  ];

  const ColorPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pick an accent color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black12,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 