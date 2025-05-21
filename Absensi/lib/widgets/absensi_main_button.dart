import 'package:flutter/material.dart';

class AbsensiMainButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDisabled;

  const AbsensiMainButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red, // Warna Merah
        foregroundColor: Colors.white, // Teks putih
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
