import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class FormScreen extends StatefulWidget {
  final AppointmentModel? appointment;
  const FormScreen({super.key, this.appointment});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  int? _selectedTypeId;
  String _selectedStatus = 'รอดำเนินการ';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _titleController.text = widget.appointment!.title;
      _locationController.text = widget.appointment!.location;
      _selectedTypeId = widget.appointment!.typeId;
      _selectedStatus = widget.appointment!.status;
      _selectedDate = DateTime.parse(widget.appointment!.date);
      List<String> timeParts = widget.appointment!.time.split(':');
      _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = context.read<AppointmentProvider>().types;

    return Scaffold(
      appBar: AppBar(title: Text(widget.appointment == null ? 'เพิ่มนัดหมาย' : 'แก้ไขนัดหมาย')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'หัวข้อนัดหมาย', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.title)),
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกหัวข้อ' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'สถานที่', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.location_on)),
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกสถานที่' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: 'วันที่', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: 'เวลา', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                initialValue: _selectedTypeId,
                decoration: InputDecoration(labelText: 'ประเภทนัดหมาย', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _selectedTypeId = val),
                validator: (val) => val == null ? 'กรุณาเลือกประเภท' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(labelText: 'สถานะ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['รอดำเนินการ', 'เสร็จสิ้น', 'ยกเลิก'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
                    final app = AppointmentModel(
                      id: widget.appointment?.id,
                      title: _titleController.text, location: _locationController.text,
                      date: DateFormat('yyyy-MM-dd').format(_selectedDate), time: formattedTime,
                      typeId: _selectedTypeId!, status: _selectedStatus,
                    );
                    
                    if (widget.appointment == null) {
                      context.read<AppointmentProvider>().addAppointment(app);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มนัดหมายสำเร็จ'), backgroundColor: Colors.green));
                    } else {
                      context.read<AppointmentProvider>().updateAppointment(app);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขนัดหมายสำเร็จ'), backgroundColor: Colors.blue));
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}