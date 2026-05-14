// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final bool isSelesai;
  final bool isTelat;
  final bool isMenunggu;
  final int sisaHari;
  final Color warnaStatus;
  final String teksStatus;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final DismissDirection dismissDirection;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDismissed;

  const OrderCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.isSelesai,
    required this.isTelat,
    required this.isMenunggu,
    required this.sisaHari,
    required this.warnaStatus,
    required this.teksStatus,
    required this.onTap,
    this.onLongPress,
    required this.dismissDirection,
    this.confirmDismiss,
    this.onDismissed,
  });

  String formatTgl(String? val) => val != null && val.isNotEmpty ? DateFormat('dd MMM yyyy').format(DateTime.parse(val)) : '-';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Gunakan ValueKey dan fallback ke string kosong jika ID null
      key: ValueKey(item['id']?.toString() ?? ''),
      direction: dismissDirection,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Text('HAPUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.delete_sweep, color: Colors.white, size: 28)],
        ),
      ),
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: warnaStatus.withOpacity(isSelesai ? 0.3 : 0.6), width: isSelesai ? 1 : 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['debitur']?.toString().toUpperCase() ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 0.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: warnaStatus.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(teksStatus, style: TextStyle(color: warnaStatus, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.folder_open, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${item['noSurat']} • ${item['jenis']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.account_balance, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${item['kcu']} - PIC Bank: ${item['picBank']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: Colors.blueAccent.withOpacity(0.2), child: const Icon(Icons.person, size: 14, color: Colors.blueAccent)),
                        const SizedBox(width: 8),
                        Text(item['picInternal'] ?? 'Belum ada', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    isSelesai
                        ? Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 16), const SizedBox(width: 4), Text('Selesai', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13))])
                        : Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: warnaStatus),
                              const SizedBox(width: 6),
                              Text(formatTgl(item['deadline']), style: TextStyle(color: warnaStatus, fontWeight: FontWeight.w600, fontSize: 13)),
                              if (!isMenunggu) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: isTelat ? Colors.red : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                  child: Text('${DateTime.now().difference(DateTime.parse(item['tglOrder'])).inDays}h', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isTelat ? Colors.white : Colors.black87)),
                                )
                              ]
                            ],
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}