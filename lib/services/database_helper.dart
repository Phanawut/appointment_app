import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../models/appointment_type.dart';
import '../models/appointment_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('appointment_app_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE types (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, 
        location TEXT NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL,
        status TEXT NOT NULL, type_id INTEGER NOT NULL,
        FOREIGN KEY (type_id) REFERENCES types (id)
      )
    ''');
    await _insertSeedData(db);
  }

  Future _insertSeedData(Database db) async {
    List<Map<String, dynamic>> types = [
      {'name': 'เรื่องงาน'}, {'name': 'เรื่องส่วนตัว'},
      {'name': 'สุขภาพ/หาหมอ'}, {'name': 'อื่นๆ'},
    ];
    for (var t in types) { await db.insert('types', t); }

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String tomorrow = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    
    // ข้อมูลตัวอย่าง 10 รายการตามโจทย์บังคับข้อ 3
    List<Map<String, dynamic>> apps = [
      {'title': 'ประชุมโปรเจกต์จบ', 'location': 'ห้องสมุด', 'date': today, 'time': '10:00', 'type_id': 1, 'status': 'รอดำเนินการ'},
      {'title': 'นัดทานข้าวกับที่บ้าน', 'location': 'ร้านอาหารเซ็นทรัล', 'date': today, 'time': '18:00', 'type_id': 2, 'status': 'รอดำเนินการ'},
      {'title': 'หาหมอฟัน', 'location': 'คลินิกหน้ามอ', 'date': tomorrow, 'time': '13:00', 'type_id': 3, 'status': 'รอดำเนินการ'},
      {'title': 'ส่งเอกสารฝึกงาน', 'location': 'ตึกคณะ', 'date': today, 'time': '09:00', 'type_id': 1, 'status': 'เสร็จสิ้น'},
      {'title': 'ดูหนังกับเพื่อน', 'location': 'SF Cinema', 'date': tomorrow, 'time': '15:30', 'type_id': 2, 'status': 'รอดำเนินการ'},
      {'title': 'นัดคุยงานลูกค้า', 'location': 'ร้านกาแฟ', 'date': '2025-03-20', 'time': '14:00', 'type_id': 1, 'status': 'ยกเลิก'},
      {'title': 'ตรวจสุขภาพประจำปี', 'location': 'โรงพยาบาล', 'date': '2025-03-01', 'time': '08:00', 'type_id': 3, 'status': 'เสร็จสิ้น'},
      {'title': 'ซื้อของเข้าหอ', 'location': 'Lotus', 'date': today, 'time': '19:00', 'type_id': 2, 'status': 'รอดำเนินการ'},
      {'title': 'สัมภาษณ์งาน', 'location': 'บริษัท XYZ', 'date': '2025-03-25', 'time': '10:00', 'type_id': 1, 'status': 'รอดำเนินการ'},
      {'title': 'จ่ายค่าไฟ', 'location': 'แอปธนาคาร', 'date': today, 'time': '12:00', 'type_id': 4, 'status': 'เสร็จสิ้น'},
    ];
    for (var a in apps) { await db.insert('appointments', a); }
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT appointments.*, types.name as type_name 
      FROM appointments JOIN types ON appointments.type_id = types.id
    ''');
    return result.map((json) => AppointmentModel.fromMap(json)).toList();
  }

  Future<int> insertAppointment(AppointmentModel app) async {
    final db = await instance.database;
    return await db.insert('appointments', app.toMap());
  }

  Future<int> updateAppointment(AppointmentModel app) async {
    final db = await instance.database;
    return await db.update('appointments', app.toMap(), where: 'id = ?', whereArgs: [app.id]);
  }

  Future<int> deleteAppointment(int id) async {
    final db = await instance.database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AppointmentType>> getAllTypes() async {
    final db = await instance.database;
    final result = await db.query('types');
    return result.map((json) => AppointmentType.fromMap(json)).toList();
  }
}