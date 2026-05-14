// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FormOrderController extends ChangeNotifier {
  final debiturCtrl = TextEditingController();
  final notarisCtrl = TextEditingController();
  final picBankCtrl = TextEditingController();
  final noSuratCtrl = TextEditingController();
  final jenisCtrl = TextEditingController();
  final rincianCtrl = TextEditingController();
  final covernoteCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final nilaiHTCtrl = TextEditingController();
  final biayaCtrl = TextEditingController();
  final progresKeteranganCtrl = TextEditingController();
  final perKasusCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final picInternalCtrl = TextEditingController();

  DateTime tglOrder = DateTime.now();
  DateTime? tglPelaksanaan;
  late DateTime deadline;
  DateTime? tglBAST;
  
  String progresPilihan = 'MENUNGGU APPROVAL';
  String? kcuPilihan;
  String? picInternalPilihan;
  String? jenisPilihan;

  final List<String> listProgres = ['DRAFT', 'MENUNGGU APPROVAL', 'APPROVED', 'PROSES', 'SELESAI', 'PENDING'];
  final List<String> listJenisOrder = ["Lainnya", "Hak Tanggungan", "FIDUSIA"];
  
  // KRITIK A: Variabel disiapkan kosong, akan diisi dari Firestore
  List<String> listPicInternal = [];
  List<String> saranNotaris = [];
  Map<String, String> kcuPicMap = {};
  List<String> listKcu = ['LAINNYA'];

  Future<void> inisialisasiData(Map<String, dynamic>? dataAwal, int targetSLA) async {
    deadline = DateTime.now().add(Duration(days: targetSLA));
    
    // KRITIK A: Ambil Master Data dari Firestore
    await _muatMasterData();

    if (dataAwal != null) {
      debiturCtrl.text = (dataAwal['debitur'] ?? '').toString().toUpperCase();
      notarisCtrl.text = dataAwal['notaris'] ?? '';
      picBankCtrl.text = dataAwal['picBank'] ?? '';
      noSuratCtrl.text = dataAwal['noSurat'] ?? '';
      jenisCtrl.text = dataAwal['jenis'] ?? '';
      rincianCtrl.text = dataAwal['rincian'] ?? '';
      covernoteCtrl.text = dataAwal['covernote'] ?? ''; 
      
      limitCtrl.text = _formatRibuanAwal(dataAwal['limit']?.toString() ?? '0');
      nilaiHTCtrl.text = _formatRibuanAwal(dataAwal['nilaiHT']?.toString() ?? '0');
      biayaCtrl.text = _formatRibuanAwal(dataAwal['biaya']?.toString() ?? '0');
      
      progresKeteranganCtrl.text = dataAwal['progresKeterangan'] ?? '';
      perKasusCtrl.text = dataAwal['perKasus'] ?? '';
      noteCtrl.text = dataAwal['note'] ?? '';
      picInternalCtrl.text = dataAwal['picInternal'] ?? '';

      if (listProgres.contains(dataAwal['progres'])) progresPilihan = dataAwal['progres'];
      
      if (dataAwal['kcu'] != null) {
        if (!listKcu.contains(dataAwal['kcu'])) listKcu.add(dataAwal['kcu']);
        kcuPilihan = dataAwal['kcu'];
      }
      
      if (dataAwal['picInternal'] != null && dataAwal['picInternal'].toString().isNotEmpty) {
        if (!listPicInternal.contains(dataAwal['picInternal'])) listPicInternal.add(dataAwal['picInternal']);
        picInternalPilihan = dataAwal['picInternal'];
      }

      if (dataAwal['jenis'] != null && dataAwal['jenis'].toString().isNotEmpty) {
        if (!listJenisOrder.contains(dataAwal['jenis'])) listJenisOrder.add(dataAwal['jenis']);
        jenisPilihan = dataAwal['jenis'];
      }

      if (dataAwal['tglOrder'] != null) tglOrder = DateTime.parse(dataAwal['tglOrder']);
      if (dataAwal['deadline'] != null) deadline = DateTime.parse(dataAwal['deadline']);
      if (dataAwal['tglPelaksanaan'] != null) tglPelaksanaan = DateTime.parse(dataAwal['tglPelaksanaan']);
      if (dataAwal['tglBAST'] != null) tglBAST = DateTime.parse(dataAwal['tglBAST']);
    }
  }

  // Fetching dari Collection "master_data"
  Future<void> _muatMasterData() async {
    try {
      final db = FirebaseFirestore.instance;
      // Note: Pastikan Collection 'master_data' dengan doc 'kcu', 'pic', dan 'notaris' dibuat di Firebase!
      var kcuDoc = await db.collection('master_data').doc('kcu').get();
      var picDoc = await db.collection('master_data').doc('pic').get();
      var notarisDoc = await db.collection('master_data').doc('notaris').get();

      if (kcuDoc.exists && kcuDoc.data() != null) {
        kcuPicMap = Map<String, String>.from(kcuDoc.data()!);
        listKcu = kcuPicMap.keys.toList();
        listKcu.add('LAINNYA');
      }
      if (picDoc.exists && picDoc.data() != null) {
        listPicInternal = List<String>.from(picDoc.data()!['daftar'] ?? []);
      }
      if (notarisDoc.exists && notarisDoc.data() != null) {
        saranNotaris = List<String>.from(notarisDoc.data()!['daftar'] ?? []);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal load master data: $e");
    }
  }

  String _formatRibuanAwal(String angka) {
    String clean = angka.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '0';
    String res = ''; int c = 0;
    for (int i = clean.length - 1; i >= 0; i--) {
      res = clean[i] + res; c++;
      if (c == 3 && i > 0) { res = '.$res'; c = 0; }
    }
    return res;
  }

  void setKcu(String? val) {
    kcuPilihan = val;
    if (val != null && kcuPicMap.containsKey(val)) {
      picBankCtrl.text = kcuPicMap[val]!;
    } else if (val == 'LAINNYA') picBankCtrl.clear();
    notifyListeners();
  }

  void setPicInternal(String? val) { picInternalPilihan = val; picInternalCtrl.text = val ?? ''; notifyListeners(); }
  void setJenisOrder(String? val) { jenisPilihan = val; jenisCtrl.text = val ?? ''; notifyListeners(); }
  void setProgres(String val) { progresPilihan = val; notifyListeners(); }
  void updateTglOrder(DateTime dt, int targetSLA) { tglOrder = dt; deadline = dt.add(Duration(days: targetSLA)); if (tglPelaksanaan != null && tglPelaksanaan!.isBefore(tglOrder)) tglPelaksanaan = tglOrder; notifyListeners(); }
  void updateTglPelaksanaan(DateTime dt) { tglPelaksanaan = dt; notifyListeners(); }
  void updateDeadline(DateTime dt) { deadline = dt; notifyListeners(); }
  void updateTglBAST(DateTime dt) { tglBAST = dt; notifyListeners(); }

  // KRITIK E: Validasi Duplikat Menggunakan Field Unik (Tanggal YYYY-MM-DD + Debitur)
  Future<bool> cekKemungkinanDuplikat() async {
    String noSurat = noSuratCtrl.text.trim();
    String debitur = debiturCtrl.text.trim().toLowerCase();
    String tglStr = DateFormat('yyyy-MM-dd').format(tglOrder);
    String kodeUnik = "${debitur}_$tglStr"; // Misal: "agus_2024-05-12"

    if (noSurat.isNotEmpty && noSurat != '-') {
      final cekSurat = await FirebaseFirestore.instance.collection('data_notaris').where('noSurat', isEqualTo: noSurat).limit(1).get();
      if (cekSurat.docs.isNotEmpty) return true;
    }
    
    // Cek Duplikat menggunakan field rahasia "kode_duplikat"
    final cekDebitur = await FirebaseFirestore.instance.collection('data_notaris').where('kode_duplikat', isEqualTo: kodeUnik).limit(1).get();
    if (cekDebitur.docs.isNotEmpty) return true;

    return false;
  }

  Map<String, dynamic> siapkanDataSimpan(String? existingId) {
    String bersihkan(String teks) => teks.replaceAll(RegExp(r'[^0-9]'), '').isEmpty ? '0' : teks.replaceAll(RegExp(r'[^0-9]'), '');
    
    // KRITIK D: Menggunakan Auto ID Firestore
    String idBaru = existingId ?? FirebaseFirestore.instance.collection('data_notaris').doc().id;
    
    // KRITIK E: Generate Field Validasi
    String tglStr = DateFormat('yyyy-MM-dd').format(tglOrder);
    String kodeUnik = "${debiturCtrl.text.trim().toLowerCase()}_$tglStr";

    return {
      'id': idBaru,
      'kode_duplikat': kodeUnik, // Field rahasia anti duplikat
      'debitur': debiturCtrl.text,
      'notaris': notarisCtrl.text,
      'kcu': kcuPilihan ?? '',
      'picBank': picBankCtrl.text,
      'noSurat': noSuratCtrl.text,
      'tglOrder': tglOrder.toIso8601String(),
      'jenis': jenisCtrl.text,
      'rincian': rincianCtrl.text,
      'covernote': covernoteCtrl.text,
      'limit': bersihkan(limitCtrl.text),
      'nilaiHT': bersihkan(nilaiHTCtrl.text),
      'biaya': bersihkan(biayaCtrl.text),
      'tglPelaksanaan': tglPelaksanaan?.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'progres': progresPilihan,
      'progresKeterangan': progresKeteranganCtrl.text,
      'tglBAST': tglBAST?.toIso8601String(),
      'perKasus': perKasusCtrl.text,
      'note': noteCtrl.text,
      'picInternal': picInternalCtrl.text,
    };
  }

  @override
  void dispose() {
    debiturCtrl.dispose(); notarisCtrl.dispose(); picBankCtrl.dispose(); noSuratCtrl.dispose();
    jenisCtrl.dispose(); rincianCtrl.dispose(); covernoteCtrl.dispose(); limitCtrl.dispose();
    nilaiHTCtrl.dispose(); biayaCtrl.dispose(); progresKeteranganCtrl.dispose();
    perKasusCtrl.dispose(); noteCtrl.dispose(); picInternalCtrl.dispose();
    super.dispose();
  }
}