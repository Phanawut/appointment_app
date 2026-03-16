class AppointmentType {
  final int? id;
  final String name;

  AppointmentType({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory AppointmentType.fromMap(Map<String, dynamic> map) => AppointmentType(id: map['id'], name: map['name']);
}