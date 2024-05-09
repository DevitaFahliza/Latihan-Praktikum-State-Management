import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';

// Definisikan kelas untuk merepresentasikan data populasi pada suatu tahun.
class PopulasiTahun {
  String tahun; // Perlu dalam format string
  int populasi;
  charts.Color barColor; // Warna batang grafik
  
  // Konstruktor untuk kelas PopulasiTahun.
  PopulasiTahun({required this.tahun, required this.populasi, required this.barColor});
}

// Kelas untuk menyimpan data populasi dari berbagai tahun.
class Populasi {
  List<PopulasiTahun> ListPop = <PopulasiTahun>[]; // List untuk menyimpan objek PopulasiTahun.

  // Konstruktor untuk kelas Populasi.
  Populasi(Map<String, dynamic> json) {
    // Mengisi ListPop dengan data dari JSON.
    var data = json["data"];
    for (var val in data) {
      var tahun = val["Year"];
      var populasi = val["Population"];
      var warna = charts.ColorUtil.fromDartColor(Colors.green); // Warna batang grafik (satu warna dulu).
      ListPop.add(PopulasiTahun(tahun: tahun, populasi: populasi, barColor: warna));
    }
  }

  // Factory method untuk membuat objek Populasi dari JSON.
  factory Populasi.fromJson(Map<String, dynamic> json) {
    return Populasi(json);
  }
}

// Widget untuk menampilkan grafik populasi.
class PopulasiChart extends StatelessWidget {
  List<PopulasiTahun> listPop; // List dari data populasi.

  // Konstruktor untuk PopulasiChart.
  PopulasiChart({required this.listPop});
  
  @override
  Widget build(BuildContext context) {
    // Series yang akan digunakan untuk membuat grafik batang.
    List<charts.Series<PopulasiTahun, String>> series = [
      charts.Series(
        id: "populasi",
        data: listPop,
        domainFn: (PopulasiTahun series, _) => series.tahun,
        measureFn: (PopulasiTahun series, _) => series.populasi,
        colorFn: (PopulasiTahun series, _) => series.barColor
      )
    ];
    // Membuat dan mengembalikan grafik batang.
    return charts.BarChart(series, animate: true);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Chart-Http", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

// Kelas state untuk halaman utama.
class HomePageState extends State<HomePage> {
  late Future<Populasi> futurePopulasi; // Future untuk menampung hasil fetching data.

  // URL endpoint untuk mengambil data populasi.
  String url = "https://datausa.io/api/data?drilldowns=Nation&measures=Population";

  // Method untuk mengambil data populasi dari URL.
  Future<Populasi> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Jika request berhasil, parse JSON dan kembalikan objek Populasi.
      return Populasi.fromJson(jsonDecode(response.body));
    } else {
      // Jika request gagal, lempar exception.
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futurePopulasi = fetchData(); // Memanggil method fetchData() saat inisialisasi state.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chart - http'),
      ),
      body: FutureBuilder<Populasi>(
        future: futurePopulasi,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Jika data sudah tersedia, tampilkan grafik populasi.
            return Center(
              child: PopulasiChart(listPop: snapshot.data!.ListPop),
            );
          } else if (snapshot.hasError) {
            // Jika terjadi error dalam fetching data, tampilkan pesan error.
            return Text('${snapshot.error}');
          }
          // Jika masih dalam proses fetching data, tampilkan loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
