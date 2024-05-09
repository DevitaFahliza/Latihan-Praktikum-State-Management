import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

// Model untuk menyimpan informasi universitas
class University {
  final String name;
  final String website;

  University({required this.name, required this.website});

  // Factory method untuk membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

// Kelas yang mengelola daftar universitas menggunakan Bloc
class UniversityBloc extends Cubit<List<University>> {
  UniversityBloc() : super([]);

  // Method untuk mengambil daftar universitas dari API berdasarkan negara
  Future<void> fetchUniversities(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = [];
      // Mengonversi setiap item JSON menjadi objek University menggunakan factory method fromJson.
      for (var item in data) {
        universities.add(University.fromJson(item));
      }
      emit(universities);
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

// Kelas utama yang menjalankan aplikasi
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityBloc(),
        child: const UniversityList(),
      ),
    );
  }
}

// Widget stateful untuk menampilkan daftar universitas
class UniversityList extends StatefulWidget {
  const UniversityList({Key? key}) : super(key: key);

  @override
  _UniversityListState createState() => _UniversityListState();
}

// State dari UniversityList
class _UniversityListState extends State<UniversityList> {
  late UniversityBloc universityBloc;
  String selectedCountry = 'Indonesia';
  final List<String> aseanCountries = ['Indonesia', 'Malaysia', 'Singapore']; // Daftar negara ASEAN

  @override
  void initState() {
    super.initState();
    universityBloc = BlocProvider.of<UniversityBloc>(context);
    universityBloc.fetchUniversities(selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Universitas'),
      ),
      body: Column(
        children: [
          // Dropdown untuk memilih negara
          DropdownButton<String>(
            value: selectedCountry,
            onChanged: (String? newCountry) {
              if (newCountry != null) {
                setState(() {
                  selectedCountry = newCountry;
                });
                // Memanggil method untuk mengambil daftar universitas berdasarkan negara yang dipilih
                universityBloc.fetchUniversities(selectedCountry);
              }
            },
            items: aseanCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
          ),
          // Expanded digunakan untuk memastikan ListView mengisi ruang yang tersedia dalam layout.
          Expanded(
            // Widget yang menampilkan daftar universitas
            child: BlocBuilder<UniversityBloc, List<University>>(
              builder: (context, universities) {
                // Memeriksa apakah daftar universitas kosong
                if (universities.isEmpty) {
                  // Menampilkan indikator loading jika daftar universitas masih kosong
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  // Menampilkan daftar universitas dalam bentuk ListView
                  return ListView.separated(
                    itemCount: universities.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      // Menampilkan informasi nama universitas dan website
                      return ListTile(
                        title: Text(
                          universities[index].name,
                          textAlign: TextAlign.center,
                        ),
                        subtitle: InkWell(
                          child: Text(
                            universities[index].website,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () async {
                            // Menavigasi ke website universitas saat di-tap
                            final url = universities[index].website;
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
