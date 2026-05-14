// ignore_for_file: empty_catches, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border; 
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/notifikasi_service.dart';

class BerandaController extends ChangeNotifier {
  List<Map<String, dynamic>> daftarOrder = [];
  bool sedangMemuat = true;
  bool sedangProsesEkspor = false; 
  
  String filterStatus = 'SEMUA'; 
  String filterTahun = 'SEMUA'; 
  String filterPIC = 'SEMUA';
  String filterKCU = 'SEMUA';
  String kataKunciPencarian = '';
  
  DateTime? filterTanggalMulai;
  DateTime? filterTanggalAkhir;

  String userRole = 'STAFF';
  String userEmail = '';
  String namaPICUser = '';   
  int targetSLA = 30;
  StreamSubscription<QuerySnapshot>? _orderSub;

  Future<void> inisialisasiData() async {
    await _muatPengaturanLokal();
    await _cekRoleUser();
    _mulaiMendengarkanCloud();
  }

  Future<void> _muatPengaturanLokal() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedSLA = prefs.getInt('target_sla');
    if (savedSLA != null) {
      targetSLA = savedSLA;
      notifyListeners();
    }
  }

  Future<void> _cekRoleUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email ?? '';
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userEmail).get(const GetOptions(source: Source.serverAndCache)); 
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            userRole = data['role'] ?? 'STAFF'; 
            namaPICUser = data['nama_pic'] ?? '';
            if (userRole == 'PIC' && namaPICUser.isNotEmpty) {
              filterPIC = namaPICUser;
            }
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("Gagal cek role: $e");
      }
    }
  }

  void _mulaiMendengarkanCloud() {
    // Pastikan tidak ada listener ganda
    _orderSub?.cancel();
    _orderSub = FirebaseFirestore.instance.collection('data_notaris').snapshots().listen((snapshot) async {
      daftarOrder = snapshot.docs.map((doc) => doc.data()).toList();
      sedangMemuat = false; 
      notifyListeners(); 

      int jumlahWarning = 0, jumlahTelat = 0;
      for (var item in daftarOrder) {
        if (item['progres'] != 'SELESAI') {
          int sisa = hitungSisaHari(item);
          if (sisa < 0) {
            jumlahTelat++;
          } else if (sisa <= 3) jumlahWarning++;
        }
      }

      if (jumlahWarning > 0 || jumlahTelat > 0) {
        final prefs = await SharedPreferences.getInstance();
        String tglTerakhirNotif = prefs.getString('terakhir_notif') ?? '';
        String tglHariIni = DateTime.now().toString().substring(0, 10);

        if (tglTerakhirNotif != tglHariIni) {
          await NotifikasiService.tampilkanNotif('⚠️ Peringatan Laporan Notaris', 'Ada $jumlahWarning berkas H-3 SLA dan $jumlahTelat berkas TELAT.');
          await prefs.setString('terakhir_notif', tglHariIni);
        }
      }
    }, onError: (e) {
      sedangMemuat = false;
      notifyListeners();
    });
  }

  int hitungSisaHari(Map<String, dynamic> item) {
    if (item['progres'] == 'SELESAI') return 999;
    try {
      DateTime? deadline = DateTime.tryParse(item['deadline']?.toString() ?? '');
      if (deadline == null) return 999;
      DateTime now = DateTime.now();
      return DateTime(deadline.year, deadline.month, deadline.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    } catch (e) { return 999; }
  }

  bool cekTelat(Map<String, dynamic> item) {
    if (item['progres'] == 'SELESAI') return false;
    try {
      String deadlineStr = item['deadline']?.toString() ?? '';
      if (deadlineStr.isEmpty) return false;
      DateTime deadline = DateTime.parse(deadlineStr);
      return DateTime.now().isAfter(DateTime(deadline.year, deadline.month, deadline.day));
    } catch (e) { return false; }
  }

  void setKataKunci(String kata) { kataKunciPencarian = kata; notifyListeners(); }
  void setFilterStatus(String status) { filterStatus = filterStatus == status ? 'SEMUA' : status; notifyListeners(); }
  void setFilterDropdown({String? tahun, String? pic, String? kcu}) {
    if (tahun != null) filterTahun = tahun;
    if (pic != null) filterPIC = pic;
    if (kcu != null) filterKCU = kcu;
    notifyListeners();
  }
  void setRentangTanggal(DateTime? mulai, DateTime? akhir) { filterTanggalMulai = mulai; filterTanggalAkhir = akhir; notifyListeners(); }

    void resetFilter() {
    filterStatus = 'SEMUA';
    filterTahun = 'SEMUA';
    filterPIC = 'SEMUA';
    filterKCU = 'SEMUA';
    filterTanggalMulai = null;
    filterTanggalAkhir = null;
    // kataKunciPencarian = ''; // (Opsional: Aktifkan jika ingin mereset kolom pencarian juga)
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredData {
    List<Map<String, dynamic>> filtered = daftarOrder.where((item) {
      String s = kataKunciPencarian.toLowerCase();
      bool mSearch = item['debitur'].toString().toLowerCase().contains(s) || 
                     item['noSurat'].toString().toLowerCase().contains(s) ||
                     item['kcu'].toString().toLowerCase().contains(s);
                     
      bool isSelesai = item['progres'] == 'SELESAI';
      bool isMenunggu = item['progres'] == 'MENUNGGU APPROVAL'; 
      bool matchesTahun;
      if (filterTahun == 'SEMUA') {
        matchesTahun = true;
      } else {
        try {
          final tglStr = item['tglOrder']?.toString();
          final dt = tglStr != null ? DateTime.tryParse(tglStr) : null;
          matchesTahun = dt != null && dt.year.toString() == filterTahun;
        } catch (_) {
          matchesTahun = false;
        }
      }
      bool matchesPIC = filterPIC == 'SEMUA' || item['picInternal'] == filterPIC;
      bool matchesKCU = filterKCU == 'SEMUA' || item['kcu'] == filterKCU;
      bool matchesRentangTanggal = true;

      if (filterTanggalMulai != null && filterTanggalAkhir != null) {
        DateTime tglOrder = DateTime.tryParse(item['tglOrder'] ?? '') ?? DateTime.now();
        DateTime tglCek = DateTime(tglOrder.year, tglOrder.month, tglOrder.day);
        DateTime start = DateTime(filterTanggalMulai!.year, filterTanggalMulai!.month, filterTanggalMulai!.day);
        DateTime end = DateTime(filterTanggalAkhir!.year, filterTanggalAkhir!.month, filterTanggalAkhir!.day);
        matchesRentangTanggal = (tglCek.isAfter(start) || tglCek.isAtSameMomentAs(start)) && (tglCek.isBefore(end) || tglCek.isAtSameMomentAs(end));
      }

      if (filterStatus == "SELESAI" && !isSelesai) return false;
      if (filterStatus == "APPROVAL" && !isMenunggu) return false;
      if (filterStatus == "PROSES" && (isSelesai || isMenunggu || cekTelat(item))) return false;
      if (filterStatus == "TELAT" && !cekTelat(item)) return false;

      return mSearch && matchesTahun && matchesPIC && matchesKCU && matchesRentangTanggal;
    }).toList();

    filtered.sort((a, b) {
      int getPriority(Map<String, dynamic> item) {
        if (item["progres"] == "MENUNGGU APPROVAL") return 0;
        if (cekTelat(item)) return 1;
        if (item["progres"] == "SELESAI") return 3;
        return 2;
      }
      int priorityA = getPriority(a), priorityB = getPriority(b);
      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      
      return (DateTime.tryParse(a['tglOrder'] ?? '') ?? DateTime.now()).compareTo(DateTime.tryParse(b['tglOrder'] ?? '') ?? DateTime.now());
    });
    return filtered;
  }

  Future<void> catatAktivitas(String aksi, String detail) async {
    try {
      await FirebaseFirestore.instance.collection('logs_notaris').add({'aksi': aksi, 'detail': detail, 'waktu': FieldValue.serverTimestamp()});
    } catch (e) { debugPrint("Gagal catat aktivitas: $e"); }
  }

  Future<void> simpanOrder(Map<String, dynamic> data) async {
    bool isUpdate = daftarOrder.any((e) => e['id'] == data['id']);
    await FirebaseFirestore.instance.collection('data_notaris').doc(data['id']).set(data);
    await catatAktivitas(isUpdate ? 'EDIT' : 'TAMBAH', '${isUpdate ? "Mengubah" : "Menambah"} debitur: ${data['debitur']}');
  }

  Future<void> tandaiSelesai(String idDokumen, String namaDebitur) async {
    await FirebaseFirestore.instance.collection('data_notaris').doc(idDokumen).update({'progres': 'SELESAI'});
    catatAktivitas('SELESAI', 'Menyelesaikan berkas: $namaDebitur');
  }

  Future<void> approveBerkas(String idDokumen, String namaDebitur) async {
    await FirebaseFirestore.instance.collection('data_notaris').doc(idDokumen).update({'progres': 'PROSES'});
    catatAktivitas('APPROVE', 'Meng-approve data: $namaDebitur');
  }

  Future<void> hapusData(String idDokumen, String namaDebitur) async {
    await FirebaseFirestore.instance.collection('data_notaris').doc(idDokumen).delete();
    catatAktivitas('HAPUS', 'Menghapus data: $namaDebitur');
  }

  Future<void> tambahHistori(String idDokumen, String teks) async {
    await FirebaseFirestore.instance.collection('data_notaris').doc(idDokumen).collection('histori').add({'teks': teks, 'waktu': FieldValue.serverTimestamp()});
    catatAktivitas('EDIT', 'Menambahkan update kendala pada histori');
  }

  Future<void> eksporDanBagikanCSV() async {
    try {
      sedangProsesEkspor = true;
      notifyListeners();

      String csvData = "DEBITUR,Nama Notaris,KCU/KCP,PIC,No. Surat Order,Tgl. Order,Jenis,Rincian Order,No. Covernote,Limit,Nilai HT,Biaya,Tgl. Pelaksanaan,Batas SLA Laporan,Umur Pekerjaan,Progres Pekerjaan,PROGRES/KETERANGAN,TANGGAL BAST,Per kasus,PIC AKAD\n";
      String escapeCsv(String? value) {
        if (value == null) return '';
        String sanitized = value.replaceAll('"', '""');
        return (sanitized.contains(',') || sanitized.contains('\n')) ? '"$sanitized"' : sanitized;
      }

      for (var item in filteredData) {
        DateTime tglOrder = DateTime.tryParse(item['tglOrder'] ?? '') ?? DateTime.now();
        String strUmur = item['progres'] == 'SELESAI' ? 'SELESAI' : '${DateTime.now().difference(tglOrder).inDays} Hari';
        String formatTgl(String? val) => val != null && val.isNotEmpty ? DateFormat('dd/MM/yyyy').format(DateTime.parse(val)) : '-';

        csvData += "${escapeCsv(item['debitur'])},${escapeCsv(item['notaris'])},${escapeCsv(item['kcu'])},${escapeCsv(item['picBank'])},${escapeCsv(item['noSurat'])},${formatTgl(item['tglOrder'])},${escapeCsv(item['jenis'])},${escapeCsv(item['rincian'])},${escapeCsv(item['covernote'])},${item['limit']},${item['nilaiHT']},${item['biaya']},${formatTgl(item['tglPelaksanaan'])},${formatTgl(item['deadline'])},$strUmur,${escapeCsv(item['progres'])},${escapeCsv(item['progresKeterangan'])},${formatTgl(item['tglBAST'])},${escapeCsv(item['perKasus'])},${escapeCsv(item['picInternal'])}\n";
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Laporan_Tracker.csv');
      await file.writeAsString(csvData);
      
      sedangProsesEkspor = false;
      notifyListeners();

      await Share.shareXFiles([XFile(file.path)]);
      catatAktivitas('EXPORT', 'Mengekspor laporan ke CSV');
    } catch (e) {
      sedangProsesEkspor = false;
      notifyListeners();
      debugPrint("Error CSV: $e");
      rethrow;
    }
  }

  // REVISI EKSPOR PDF: Final Layout & Urutan Kolom Sesuai Permintaan
  Future<void> eksporDanBagikanPDF() async {
    try {
      sedangProsesEkspor = true;
      notifyListeners();

      final pdf = pw.Document();
      
      // 1. FILTER: Hanya pekerjaan yang belum selesai (Outstanding)
      final dataList = daftarOrder.where((item) => item['progres'] != 'SELESAI').toList();

      // Urutkan berdasarkan tanggal order terbaru
      dataList.sort((a, b) => (DateTime.tryParse(b['tglOrder'] ?? '') ?? DateTime.now())
          .compareTo(DateTime.tryParse(a['tglOrder'] ?? '') ?? DateTime.now()));

      // Helper format tanggal
      String formatDateSafe(dynamic isoDate) {
        if (isoDate == null || isoDate == '') return '-';
        try {
          return DateFormat('dd/MM/yyyy').format(DateTime.parse(isoDate.toString()));
        } catch (_) { return '-'; }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.Header(
              level: 0, 
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("LAPORAN TRACKER NOTARIS (OUTSTANDING)", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Daftar Pekerjaan Belum Selesai (Proses & Telat)", style: const pw.TextStyle(fontSize: 9)),
                    ]
                  ),
                  pw.Text("Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 9)),
                ]
              )
            ),
            pw.SizedBox(height: 15),
            pw.TableHelper.fromTextArray(
              // URUTAN HEADER SESUAI PERMINTAAN
              headers: [
                'NAMA DEBITUR', 
                'KCU / KCP', 
                'JENIS ORDER', 
                'TGL ORDER', 
                'STATUS PROGRESS', 
                'PER KASUS', 
                'PIC INTERNAL',
                'CATATAN'
              ],
              data: dataList.map((item) {
                bool isTelat = cekTelat(item);
                String status = item['progres']?.toString() ?? 'PROSES';
                if (isTelat) status = "TELAT ($status)";

                return [
                  item['debitur']?.toString().toUpperCase() ?? '-',
                  item['kcu']?.toString().replaceAll('Micro Garut ', '') ?? '-',
                  item['jenis']?.toString() ?? '-',
                  formatDateSafe(item['tglOrder']),
                  status,
                  item['perKasus']?.toString() ?? '-', // Data dari sistem
                  item['picInternal']?.toString() ?? '-', // PIC Internal
                  '', // Kolom CATATAN (KOSONG untuk tulis tangan)
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4), // NAMA DEBITUR (Dibuat lebih sempit agar pas)
                1: const pw.FlexColumnWidth(1.4), // KCU
                2: const pw.FlexColumnWidth(1.1), // JENIS
                3: const pw.FlexColumnWidth(0.9), // TGL ORDER
                4: const pw.FlexColumnWidth(1.1), // STATUS
                5: const pw.FlexColumnWidth(2.3), // PER KASUS (Data sistem - Lebih luas)
                6: const pw.FlexColumnWidth(1.0), // PIC INTERNAL
                7: const pw.FlexColumnWidth(2.0), // CATATAN (KOSONG - Lebih luas untuk tulis tangan)
              },
            ),
            pw.SizedBox(height: 15),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total Dokumen: ${dataList.length} Berkas", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            )
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Laporan_Outstanding_Notaris.pdf');
      
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes, flush: true);
      
      sedangProsesEkspor = false;
      notifyListeners();

      await Share.shareXFiles([XFile(file.path)], subject: 'Laporan Outstanding Notaris');
      catatAktivitas('EXPORT', 'Mengekspor laporan PDF (Outstanding)');
      
    } catch (e) {
      sedangProsesEkspor = false;
      notifyListeners();
      debugPrint("CRASH PDF: $e");
      throw Exception("Gagal membuat PDF. Pastikan data valid.");
    }
  }

  Future<int> imporExcel(PlatformFile fileInfo) async {
    var bytes = await File(fileInfo.path!).readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) throw Exception("File kosong");
    var table = excel.tables.values.first;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int count = 0;
    
    for (int i = 1; i < table.rows.length; i++) {
      var row = table.rows[i];
      if (row.isEmpty || row[0] == null) continue;
      
      String idBaru = FirebaseFirestore.instance.collection('data_notaris').doc().id;
      String safeStr(int index) => (index < row.length && row[index]?.value != null) ? row[index]!.value.toString().trim() : '';
      String parseDate(int index) {
        String s = safeStr(index);
        if (s.isNotEmpty && s != '-') try { return DateTime.parse(s).toIso8601String(); } catch (e) {}
        return DateTime.now().toIso8601String(); 
      }
      String getNum(int index) { String s = safeStr(index).replaceAll(RegExp(r'[^0-9]'), ''); return s.isEmpty ? '0' : s; }

      String prog = safeStr(15).toUpperCase();
      prog = ['SELESAI', 'PENDING', 'MENUNGGU APPROVAL'].contains(prog) ? prog : 'PROSES';

      DateTime tglOrder = DateTime.parse(parseDate(5));
      String tglStr = DateFormat('yyyy-MM-dd').format(tglOrder);
      String kodeUnik = "${safeStr(0).toLowerCase()}_$tglStr";

      batch.set(FirebaseFirestore.instance.collection('data_notaris').doc(idBaru), {
        'id': idBaru, 'kode_duplikat': kodeUnik, 'debitur': safeStr(0), 'notaris': safeStr(1), 'kcu': safeStr(2), 'picBank': safeStr(3), 
        'noSurat': safeStr(4), 'tglOrder': tglOrder.toIso8601String(), 'jenis': safeStr(6), 'rincian': safeStr(7),
        'covernote': safeStr(8), 'limit': getNum(9), 'nilaiHT': getNum(10), 'biaya': getNum(11),      
        'tglPelaksanaan': safeStr(12).isNotEmpty ? parseDate(12) : null, 'deadline': parseDate(13),  
        'progres': prog, 'progresKeterangan': safeStr(16), 'tglBAST': safeStr(17).isNotEmpty ? parseDate(17) : null,
        'perKasus': safeStr(18), 'note': safeStr(19), 'picInternal': safeStr(20), 
      });
      count++;
      if (count % 400 == 0) { await batch.commit(); batch = FirebaseFirestore.instance.batch(); }
    }
    await batch.commit();
    catatAktivitas('TAMBAH', 'Impor massal sebanyak $count data dari Excel');
    return count;
  }

  @override
  void dispose() {
    // Batalkan listener untuk mencegah memory leak
    _orderSub?.cancel();
    super.dispose();
  }
}