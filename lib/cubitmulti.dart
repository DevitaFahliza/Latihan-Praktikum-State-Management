import 'package:flutter/material.dart'; // Package flutter untuk membangun UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Package flutter_bloc untuk menggunakan Bloc
import 'package:http/http.dart' as http; // Package http untuk melakukan HTTP request
import 'dart:convert'; // Package dart:convert untuk melakukan encoding dan decoding JSON

// Screen untuk menampilkan detil UMKM
class ScreenDetil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detil'),
        ),
        body: BlocBuilder<DetilUmkmCubit, DetilUmkmModel>(
            builder: (context, detilUmkm) {
          return Column(children: [
            Text("Nama: ${detilUmkm.nama}"),
            Text("Detil: ${detilUmkm.jenis}"),
            Text("Member Sejak: ${detilUmkm.memberSejak}"),
            Text("Omzet per bulan: ${detilUmkm.omzet}"),
            Text("Lama usaha: ${detilUmkm.lamaUsaha}"),
            Text("Jumlah pinjaman sukses: ${detilUmkm.jumPinjamanSukses}"),
          ]);
        }));
  }
}

// Model untuk menyimpan detil UMKM
class DetilUmkmModel {
  String id;
  String jenis;
  String nama;
  String omzet;
  String lamaUsaha;
  String memberSejak;
  String jumPinjamanSukses;

  DetilUmkmModel(
      {required this.id,
      required this.nama,
      required this.jenis,
      required this.omzet,
      required this.jumPinjamanSukses,
      required this.lamaUsaha,
      required this.memberSejak}); // Konstruktor
}

// Model untuk menyimpan daftar UMKM
class Umkm {
  String id;
  String jenis;
  String nama;
  Umkm({required this.id, required this.nama, required this.jenis}); // Konstruktor
}

// Model untuk menyimpan data daftar UMKM
class UmkmModel {
  List<Umkm> dataUmkm;
  UmkmModel({required this.dataUmkm}); // Konstruktor
}

// Cubit untuk mengelola detil UMKM
class DetilUmkmCubit extends Cubit<DetilUmkmModel> {
  String urlDetil = "http://178.128.17.76:8000/detil_umkm/";

  DetilUmkmCubit()
      : super(DetilUmkmModel(
            id: '',
            jenis: '',
            nama: '',
            omzet: '',
            jumPinjamanSukses: '',
            lamaUsaha: '',
            memberSejak: ''));

  // Method untuk mengubah data dari JSON menjadi objek DetilUmkmModel
  void setFromJson(Map<String, dynamic> json) {
    emit(DetilUmkmModel(
        id: json["id"],
        nama: json["nama"],
        jenis: json["jenis"],
        omzet: json["omzet_bulan"],
        jumPinjamanSukses: json["jumlah_pinjaman_sukses"],
        lamaUsaha: json["lama_usaha"],
        memberSejak: json["member_sejak"]));
  }

  // Method untuk melakukan fetching data detil UMKM dari API
  void fetchDataDetil(String id) async {
    String urldet = "$urlDetil$id";
    final response = await http.get(Uri.parse(urldet));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

// Cubit untuk mengelola daftar UMKM
class UmkmCubit extends Cubit<UmkmModel> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UmkmCubit() : super(UmkmModel(dataUmkm: []));

  // Method untuk mengubah data dari JSON menjadi objek UmkmModel
  void setFromJson(Map<String, dynamic> json) {
    var arrData = json["data"];
    List<Umkm> arrOut = [];
    for (var el in arrData) {
      String id = el['id'];
      String jenis = el['jenis'];
      String nama = el['nama'];
      arrOut.add(Umkm(id: id, nama: nama, jenis: jenis));
    }
    emit(UmkmModel(dataUmkm: arrOut));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<UmkmCubit>(
          create: (BuildContext context) => UmkmCubit(),
        ),
        BlocProvider<DetilUmkmCubit>(
          create: (BuildContext context) => DetilUmkmCubit(),
        ),
      ],
      child: const HalamanUtama(),
    ));
  }
}

// HalamanUtama untuk menampilkan daftar UMKM
class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text(' My App'),
      ),
      body: Center(
        child: BlocBuilder<UmkmCubit, UmkmModel>(
          builder: (context, listUmkm) {
            return Center(
                child: Column(
                    children: [
                  Container(
                      padding: const EdgeInsets.all(10), child: const Text("""
nim1,nama1; nim2,nama2; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang""")),

                  Container(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<UmkmCubit>().fetchData();
                      },
                      child: const Text("Reload Daftar UMKM"),
                    ),
                  ),
                  Expanded(child: BlocBuilder<DetilUmkmCubit, DetilUmkmModel>(
                      builder: (context, detilUmkm) {
                    return ListView.builder(
                        itemCount: listUmkm.dataUmkm.length, //jumlah baris
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {
                                // Saat item di-tap, lakukan fetching data detil dan pindahkan ke halaman detil
                                context.read<DetilUmkmCubit>().fetchDataDetil(
                                    listUmkm.dataUmkm[index].id);
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return ScreenDetil();
                                }));
                              },
                              leading: Image.network(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                              trailing: const Icon(Icons.more_vert),
                              title: Text(listUmkm.dataUmkm[index].nama),
                              subtitle: Text(listUmkm.dataUmkm[index].jenis),
                              tileColor: Colors.white70);
                        });
                  }))
                ]));
          },
        ),
      ),
    ));
  }
}

