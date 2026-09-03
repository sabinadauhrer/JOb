import 'package:flutter/material.dart';

/// A delete button using the app's custom trash-can icon, with a fallback
/// to the standard Material icon if the asset fails to load.
class DeleteIconButton extends StatelessWidget {
  const DeleteIconButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/icons/icon_delete.png',
        width: 26,
        height: 26,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.delete_outline),
      ),
      onPressed: onPressed,
    );
  }
}
