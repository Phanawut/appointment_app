import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../widgets/stat_card.dart';
import 'list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('สรุปนัดหมาย', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: provider.types.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () {
                    context.read<AppointmentProvider>().filterByStatus('ทั้งหมด');
                    context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('นัดหมายทั้งหมด (Total)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('${provider.totalAppointments}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // แถวที่ 1: นัดหมายวันนี้ & รอดำเนินการ
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'นัดหมายวันนี้', count: provider.todayAppointments, color: Colors.orange, icon: Icons.today,
                        onTap: () {
                          context.read<AppointmentProvider>().filterByStatus('ทั้งหมด');
                          context.read<AppointmentProvider>().filterByDate('วันนี้');
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                        },
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'รอดำเนินการ', count: provider.pendingAppointments, color: Colors.blueAccent, icon: Icons.hourglass_empty,
                        onTap: () {
                          context.read<AppointmentProvider>().filterByStatus('รอดำเนินการ');
                          context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                        },
                      )
                    ),
                  ],
                ),
                
                const SizedBox(height: 16), // เว้นระยะห่างระหว่างแถว
                
                // แถวที่ 2: เสร็จสิ้นแล้ว & ยกเลิก
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'เสร็จสิ้นแล้ว', count: provider.completedAppointments, color: Colors.green, icon: Icons.task_alt,
                        onTap: () {
                          context.read<AppointmentProvider>().filterByStatus('เสร็จสิ้น');
                          context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                        },
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'ยกเลิก', count: provider.canceledAppointments, color: Colors.red, icon: Icons.cancel_presentation,
                        onTap: () {
                          context.read<AppointmentProvider>().filterByStatus('ยกเลิก');
                          context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                        },
                      )
                    ),
                  ],
                ),
                
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AppointmentProvider>().filterByStatus('ทั้งหมด');
                    context.read<AppointmentProvider>().filterByDate('ทั้งหมด');
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen()));
                  },
                  icon: const Icon(Icons.calendar_month), label: const Text('ดูตารางนัดหมายทั้งหมด', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                )
              ],
            ),
          ),
    );
  }
}