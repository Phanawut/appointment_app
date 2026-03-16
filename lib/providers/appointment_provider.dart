import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../models/appointment_type.dart';
import '../services/database_helper.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _allApps = [];
  List<AppointmentModel> _displayApps = [];
  List<AppointmentType> _types = [];
  
  String _searchQuery = '';
  String _filterStatus = 'ทั้งหมด'; 
  String _filterDate = 'ทั้งหมด'; // เก็บค่า 'ทั้งหมด', 'วันนี้', หรือ 'YYYY-MM-DD'

  List<AppointmentModel> get appointments => _displayApps;
  List<AppointmentType> get types => _types;
  String get currentFilterDate => _filterDate; 
  String get currentFilterStatus => _filterStatus; // เพิ่มตัวนี้ให้หน้ารายการดึงไปใช้

  int get totalAppointments => _allApps.length;
  int get todayAppointments {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _allApps.where((a) => a.date == today).length;
  }
  
  int get completedAppointments => _allApps.where((a) => a.status == 'เสร็จสิ้น').length;
  int get pendingAppointments => _allApps.where((a) => a.status == 'รอดำเนินการ').length;
  int get canceledAppointments => _allApps.where((a) => a.status == 'ยกเลิก').length;

  Future<void> initData() async {
    _types = await DatabaseHelper.instance.getAllTypes();
    await fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    _allApps = await DatabaseHelper.instance.getAllAppointments();
    _applyFilterAndSearch();
  }

  Future<void> addAppointment(AppointmentModel app) async {
    await DatabaseHelper.instance.insertAppointment(app);
    await fetchAppointments();
  }

  Future<void> updateAppointment(AppointmentModel app) async {
    await DatabaseHelper.instance.updateAppointment(app);
    await fetchAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await DatabaseHelper.instance.deleteAppointment(id);
    await fetchAppointments();
  }

  void search(String query) { _searchQuery = query; _applyFilterAndSearch(); }
  void filterByStatus(String status) { _filterStatus = status; _applyFilterAndSearch(); }
  void filterByDate(String dateType) { _filterDate = dateType; _applyFilterAndSearch(); }

  void _applyFilterAndSearch() {
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    _displayApps = _allApps.where((a) {
      // 1. ตรวจสอบสถานะ
      final matchStatus = _filterStatus == 'ทั้งหมด' || a.status == _filterStatus;
      
      // 2. ตรวจสอบคำค้นหา
      final matchSearch = a.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          a.location.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 3. ตรวจสอบวันที่
      bool matchDate = true;
      if (_filterDate != 'ทั้งหมด') {
        if (_filterDate == 'วันนี้') {
          matchDate = (a.date == todayStr);
        } else {
          matchDate = (a.date == _filterDate); // กรองตามวันที่ที่เลือกจากปฏิทิน
        }
      }
      
      return matchStatus && matchSearch && matchDate;
    }).toList();
    
    // เรียงลำดับใกล้สุดขึ้นก่อน
    _displayApps.sort((a, b) {
      DateTime dateA = DateTime.parse("${a.date} ${a.time}");
      DateTime dateB = DateTime.parse("${b.date} ${b.time}");
      return dateA.compareTo(dateB);
    });
    
    notifyListeners();
  }
}