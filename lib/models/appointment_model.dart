class AppointmentModel {
  final int? id;
  final String title;
  final String location;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final int typeId;
  final String status; // 'รอดำเนินการ', 'เสร็จสิ้น', 'ยกเลิก'
  final String? typeName;

  AppointmentModel({
    this.id, required this.title, required this.location,
    required this.date, required this.time, required this.typeId,
    required this.status, this.typeName,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'location': location,
    'date': date, 'time': time, 'type_id': typeId, 'status': status
  };

  factory AppointmentModel.fromMap(Map<String, dynamic> map) => AppointmentModel(
    id: map['id'], title: map['title'], location: map['location'],
    date: map['date'], time: map['time'], typeId: map['type_id'], 
    status: map['status'], typeName: map['type_name'],
  );
}