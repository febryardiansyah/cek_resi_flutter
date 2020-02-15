import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:track_ur_resi/detail.dart';
import 'package:http/http.dart'as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF212121),
        accentColor: Colors.white,
        accentIconTheme: IconThemeData(color: Colors.black),
        dividerColor: Colors.black12,
      ),
      home: ResiKu(),
    );
  }
}
class ResiKu extends StatefulWidget {
  @override
  _ResiKuState createState() => _ResiKuState();
}

class _ResiKuState extends State<ResiKu> {

  final TextEditingController _controller = TextEditingController();
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.clear();
      }
    });
    super.initState();
  }

  String noResi = '';
  String layanan = '';
  String nama = '';
  String status = '';
  String tujuan = '';
  String penerima = '';
  String tanggal = '';

  bool loading = false;
  bool showDetail = false;
  bool isNotFound = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Icon(Icons.home), title: Text('CekUrResi'),),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukan Resi',
                      labelText: 'Nomor Resi'
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: MaterialButton(
                  child: Text('Cari'),
                  color: Colors.pink,
                  textColor: Colors.white,
                  onPressed: cekResi,
                ),
              ),

              Divider(),
              //loading true
              loading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : showDetail
                  ? Detail(
                  noResi,
                  layanan,
                  nama,
                  status,
                  tujuan,
                  tanggal,
                  penerima)
                  : isNotFound
                  ? Card(
                elevation: 4,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Tidak Ditemukan'),
                  ),
                ),
              )
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }
  void cekResi() async {
    setState(() {
      showDetail = false;
      isNotFound = false;
      loading = true;
    });
    Map<String, String> requestHeaders = {
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'en-US,en;q=0.9',
      'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Host': 'sicepat.com',
      'Origin': 'http://sicepat.com',
      'Referer': 'http://sicepat.com',
      'User-Agent':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
      'Cookie':
      '__cfduid=d4a82874e43363ef776bd20169c2e37ca1568383926; ci_session=nphsvktt6jl68lu74er1osttbfc4ct9d',
      'X-Requested-With': 'XMLHttpRequest'
    };

    //BUAT JUGA VARIABLE LAINNYA DENGAN TIPE MAP DAN KEY STRING, VALUE STRING
    //DATA INI DIGUNAKAN SEBAGAI BODY KETIKA MENGIRIMKAN REQUEST KE API
    Map<String, String> resi = {'awb[]': _controller.text};

    //LAKUKAN REQUEST KE API DENGAN MENYERTAKAN BODY = RESI DAN HEADERS = REQUESTHEADERS
    final response = await http.post('http://sicepat.com/checkAwb/doSearch',
        body: resi, headers: requestHeaders);
    //DECODE HASILNYA DAN HANYA MENGAMBIL VALUE DARI KEY HTML
    final content = json.decode(response.body)['html'];

    //KEMUDIAN VALUE DARI CONTENT KITA REMOVE BEBERAPA BAGIAN YANG TIDAK DIBUTUHKAN DENGAN BANTUAN METHOD BARU YANG BERNAMA removeHeading() DIMANA METHOD INI AKAN KITA BUAT KEMUDIAN
    final withoutHtml = removeHeading(content);

    setState(() {
      loading = false; //SET LOADING JADI FALSE KARENA PROSES REQUESTNYA SDH BERHASIL
      if (withoutHtml.length > 1) { //JIKA RESINYA ADA
        //MAKA DATA DARI API TERSEBUT KITA ASSIGN KE DALAM VARIABLE YANG TELAH DIBUAT SEBELUMNYA
        //KARENA DATANYA MENGGUNAKAN FORMAT HTML, MAKA KITA PERLU MEMECAH DATANYA DAN MENGHILANGKAN HTML CODENYA
        //KITA JUGA AKAN MEMBUAT METHOD BARU BERNAMA withoutHtml YANG BERFUNGSI UNTUK MEMECAH DATA
        noResi = explodeItem(withoutHtml[1], '<div class="visible-xs">', 0);
        layanan = explodeItem(withoutHtml[1], '<div class="visible-xs">', 1);
        nama = explodeItem(withoutHtml[4], '<td class="hidden-xs">', 1);
        status = explodeItem(withoutHtml[7], '<td>', 1);
        tujuan = explodeItem(withoutHtml[3], '<div class="visible-xs">', 0);
        tanggal = explodeItem(withoutHtml[5], '<div class="visible-xs">', 0);
        penerima = explodeItem(withoutHtml[5], '<div class="visible-xs">', 1);
        showDetail = true; //SET SHOW DETAIL JADI TRUE AGAR CARD INFORMASI RESI DIRENDER
      } else {
        isNotFound = true; //IJKA RESI TIDAK DITEMUKAN, SET IS NOT FOUND JADI TRUE
      }

      FocusScope.of(context).nextFocus(); //HILANGKAN FOCUS DARI TEXT FIELD
      _controller.clear(); //DAN BERSIHKAN VALUENYA
    });
    return;
  }
  List removeHeading(String htmlText) { //METHOD PERTAMA NILAI BALIKNYA DENGAN FORMAT LIST (ARRAY)

    //METHOD INI MENERIMA VALUE DARI RESPONSE API, KEMUDIAN CODE HTML DIBAWAH DIHAPUS MENGGUNAKAN REPLACE ALL
    final removeHeading = htmlText.replaceAll(
        '<div class=\"awb-detail-title text-center\">       <div class=\"container\">           Status Pengiriman Anda       </div>   </div>   <div class=\"awb-detail-sub-title text-center\">       <div class=\"container\">           Terimakasih telah menggunakan pengiriman SiCepat. Silahkan cek daftar pengiriman Anda       </div>   </div><span class=\"awb-click-info\">Silahkan klik salah satu baris untuk melihat detail pengiriman.</span>   <div class=\"table-responsive\"><table id=\"awb-list\" class=\"table table-striped  nowrap ws-table\"\n                 cellspacing=0 width=\"100%\">  <thead><tr> <th  id=\"seq\" class=\"hidden-xs\">No</th> <th  id=\"awb_number\" class=\"\">No RESI</th> <th  id=\"service\" class=\"hidden-xs\">Layanan</th> <th  id=\"destination\" class=\"\">Tujuan</th> <th  id=\"receipt_name\" class=\"hidden-xs\">Penerima</th> <th  id=\"receipt_date\" class=\"\">Tgl Diterima</th> <th  id=\"receipt_paket\" class=\"hidden-xs\">Penerima Paket</th> <th  id=\"status\" class=\"\">STATUS</th></tr>  </thead><tbody><tr class=\"res-item\"> ',
        '');

    //SETELAH BAGIAN YANG TIDAK DIPERLUKAN DIHAPUS, KITA PECAH DATANYA MENGGUNAKAN SPLIT DENGAN </TD> SEBAGAI PARAMETERNYA
    final splitTd = removeHeading.split('</td>');
    return splitTd.toList(); //KEMUDIAN KEMBALIKAN VALUE YANG BARU DALAM BENTUK LIST
  }

  String explodeItem(String str, String remove, int index) { //METHOD INI AKAN MENGHASILKAN STRING SEBAGAI NILAI BALIK
    //PARAMETER PERTAMA ADALAH STRING YANG AKAN DIPECAH
    //PARAMETER KEDUA KEDUA ADALAH PEMECAHNYA. CONTOH: PADA METHOD SEBELUMNYA KITA GUNAKAN </TD>, KARENA METHOD INI REUSABLE JADI KITA BUAT DALAM BENTUK VARIABLE JADI TERGANTUNG REQUEST
    //PARAMETER KETIGA INDEX DATA YANG MAU DIAMBIL

    //KITA PECAH STRINGNYA MENGGUNAKAN PARAMETER REMOVE DAN HASILNYA DIUBAH JADI LIST
    final result = str.split(remove).toList();

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true); //BUAT REGEX UNTUK MENGIDENTIFIKASI HTML

    return result[index].replaceAll(exp, ''); //REPLACE SEMUA HTML CODE
  }
}

