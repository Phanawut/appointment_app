import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final AppointmentModel appointment;
  const DetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    // 1. ดึงข้อมูลล่าสุดเสมอ (เวลากดแก้ไขแล้วย้อนกลับมา ข้อมูลจะได้เปลี่ยนทันที)
    final provider = context.watch<AppointmentProvider>();
    final currentApp = provider.appointments.firstWhere(
      (app) => app.id == appointment.id,
      orElse: () => appointment,
    );

    Color statusColor = currentApp.status == 'เสร็จสิ้น' ? Colors.green : (currentApp.status == 'ยกเลิก' ? Colors.red : Colors.orange);

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดนัดหมาย'),
        actions: [
          // ปุ่มแก้ไข
          IconButton(
            icon: const Icon(Icons.edit_note, size: 28),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => FormScreen(appointment: currentApp))
              );
            },
          ),
          // ปุ่มลบ
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 26, color: Colors.red),
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ยืนยันการลบ', style: TextStyle(fontWeight: FontWeight.bold)), 
                  content: Text('ต้องการลบนัดหมาย "${currentApp.title}" ใช่หรือไม่?'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), 
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: const Text('ลบข้อมูล')
                    ),
                  ],
                ),
              ) ?? false;

              if (confirm && context.mounted) {
                context.read<AppointmentProvider>().deleteAppointment(currentApp.id!);
                Navigator.pop(context); // ลบเสร็จ เด้งกลับไปหน้ารายการ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ลบนัดหมายเรียบร้อยแล้ว'), backgroundColor: Colors.red)
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // 2. แก้แถบเหลือง (Overflow): ใช้ SingleChildScrollView ครอบไว้เพื่อให้เลื่อนหน้าจอได้
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withValues(alpha: 0.1)),
              child: Icon(Icons.event_note, color: statusColor, size: 80),
            ),
            const SizedBox(height: 30),
            
            // กล่องแสดงรายละเอียด
            Card(
              elevation: 0, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildRow('หัวข้อ', currentApp.title, Icons.title),
                    const Divider(height: 30),
                    _buildRow('สถานที่', currentApp.location, Icons.location_on),
                    const Divider(height: 30),
                    _buildRow('วันที่', DateFormat('dd MMMM yyyy').format(DateTime.parse(currentApp.date)), Icons.calendar_today),
                    const Divider(height: 30),
                    _buildRow('เวลา', currentApp.time, Icons.access_time),
                    const Divider(height: 30),
                    _buildRow('ประเภท', currentApp.typeName ?? '-', Icons.category),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30), // ระยะห่าง
            
            // แถบแสดงสถานะด้านล่างสุด
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('สถานะ:', style: TextStyle(fontSize: 20, color: Colors.white)),
                  Text(currentApp.status, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยสร้างแถวข้อมูล (ปรับแต่งให้รองรับข้อความยาวๆ)
  Widget _buildRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}