import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap; // เพิ่มส่วนนี้เพื่อรับคำสั่งตอนกด

  const StatCard({super.key, required this.title, required this.count, required this.color, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1), 
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.3))),
      child: InkWell( // ห่อด้วย InkWell ทำให้ปุ่มกดได้และมีเอฟเฟกต์กระเพื่อม
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$count รายการ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}