import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    // จัดฟอร์แมตข้อความที่จะโชว์บนปุ่มเลือกวันที่
    String dateFilterDisplay = 'ทุกวัน';
    if (provider.currentFilterDate == 'วันนี้') {
      dateFilterDisplay = 'วันนี้';
    } else if (provider.currentFilterDate != 'ทั้งหมด') {
      DateTime parsedDate = DateTime.parse(provider.currentFilterDate);
      dateFilterDisplay = DateFormat('dd MMM yyyy').format(parsedDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.currentFilterDate == 'วันนี้' ? 'นัดหมายวันนี้' : 'รายการนัดหมาย'),
        actions: [
          // เพิ่มปุ่มล้างตัวกรองมุมขวาบน (กรณีผู้ใช้กดกรองจนลืม)
          if (provider.currentFilterDate != 'ทั้งหมด' || provider.currentFilterStatus != 'ทั้งหมด')
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'แสดงทั้งหมด',
              onPressed: () {
                context.read<AppointmentProvider>().filterByStatus('ทั้งหมด');
                context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // ส่วนของช่องค้นหาและตัวกรอง
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: Column(
              children: [
                // แถวที่ 1: ช่องค้นหา
                TextField(
                  decoration: InputDecoration(
                    labelText: 'ค้นหาหัวข้อ/สถานที่...', prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) => context.read<AppointmentProvider>().search(val),
                ),
                const SizedBox(height: 12),
                
                // แถวที่ 2: ตัวกรองสถานะ & ตัวกรองวันที่
                Row(
                  children: [
                    // ตัวกรองสถานะ
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.currentFilterStatus,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'ทั้งหมด', child: Text('ทุกสถานะ')),
                              DropdownMenuItem(value: 'รอดำเนินการ', child: Text('รอทำ')),
                              DropdownMenuItem(value: 'เสร็จสิ้น', child: Text('เสร็จสิ้น')),
                              DropdownMenuItem(value: 'ยกเลิก', child: Text('ยกเลิก')),
                            ],
                            onChanged: (val) => context.read<AppointmentProvider>().filterByStatus(val!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ตัวกรองวันที่ (กดแล้วเด้ง DatePicker)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            helpText: 'เลือกวันที่ต้องการดูนัดหมาย',
                          );
                          if (picked != null) {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
                            context.read<AppointmentProvider>().filterByDate(formattedDate);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.indigo, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dateFilterDisplay,
                                  style: TextStyle(fontSize: 14, color: provider.currentFilterDate != 'ทั้งหมด' ? Colors.indigo : Colors.black87, fontWeight: provider.currentFilterDate != 'ทั้งหมด' ? FontWeight.bold : FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // แสดงปุ่ม X ล้างวันที่เมื่อมีการเลือกวันที่ไว้
                              if (provider.currentFilterDate != 'ทั้งหมด')
                                GestureDetector(
                                  onTap: () => context.read<AppointmentProvider>().filterByDate('ทั้งหมด'),
                                  child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ส่วนแสดงรายการนัดหมาย
          if (provider.appointments.isEmpty)
            const Expanded(child: Center(child: Text('ไม่พบนัดหมายในหมวดนี้', style: TextStyle(fontSize: 18, color: Colors.grey))))
          else
            Expanded(
              child: ListView.builder(
                itemCount: provider.appointments.length,
                itemBuilder: (context, index) {
                  final app = provider.appointments[index];
                  Color statusColor = app.status == 'เสร็จสิ้น' ? Colors.green : (app.status == 'ยกเลิก' ? Colors.red : Colors.orange);
                  
                  return Dismissible(
                    key: ValueKey(app.id),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red.shade400, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('ยืนยันการลบ'), content: Text('ต้องการลบนัดหมาย "${app.title}" ใช่หรือไม่?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
                            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('ลบ', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      context.read<AppointmentProvider>().deleteAppointment(app.id!);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบนัดหมายแล้ว'), backgroundColor: Colors.red));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: statusColor.withValues(alpha: 0.5))),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: statusColor.withValues(alpha: 0.2), child: Icon(Icons.event, color: statusColor)),
                        title: Text(app.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${app.location}\n${DateFormat('dd MMM yyyy').format(DateTime.parse(app.date))} เวลา ${app.time}'),
                        trailing: Chip(label: Text(app.status, style: const TextStyle(fontSize: 12, color: Colors.white)), backgroundColor: statusColor, side: BorderSide.none),
                        isThreeLine: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(appointment: app))),
                        onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(appointment: app))),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen())),
        icon: const Icon(Icons.add), label: const Text('เพิ่มนัดหมาย'),
      ),
    );
  }
}