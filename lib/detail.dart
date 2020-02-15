import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  String noResi = '';
  String layanan = '';
  String nama = '';
  String status = '';
  String tujuan = '';
  String penerima = '';
  String tanggal = '';

  Detail(this.noResi, this.layanan, this.nama, this.status, this.tujuan,
      this.penerima, this.tanggal);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: ListTile(
          title: Text(
            '${noResi} - $layanan'
          ),
          subtitle: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nama :\t$nama'),
                Text('Status :\t$status'),
                Text('Tujuan :\t$tujuan'),
                Text('tgl Diterima :\t$tanggal'),
                Text('Penerima :\t$penerima')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
