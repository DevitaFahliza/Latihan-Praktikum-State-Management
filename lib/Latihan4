import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// Model untuk menyimpan informasi universitas
class University {
  final String name;
  final String website;

  University({required this.name, required this.website}); // Constructor

  // Factory method untuk membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

// Kelas penyedia data yang mengelola negara serta daftar universitas
class UniversityProvider extends ChangeNotifier {
  late String _selectedCountry = "Indonesia";

  String get selectedCountry => _selectedCountry;

  // Metode untuk mengatur negara yang dipilih
  void setSelectedCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  // Metode untuk mengambil daftar universitas dari API berdasarkan negara
  Future<List<University>> fetchUniversities(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = [];
      // Mengonversi setiap item JSON menjadi objek University menggunakan factory method fromJson.
      for (var item in data) {
        universities.add(University.fromJson(item));
      }
      return universities;
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

// Kelas utama yang menjalankan aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => UniversityProvider(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Daftar Universitas di ASEAN'),
          ),
          body: UniversityList(),
        ),
      ),
    );
  }
}

// Kelas untuk menampilkan daftar universitas dan opsi negara
class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UniversityProvider>(context);

    return Column(
      children: [
        // Dropdown untuk memilih negara
        DropdownButton<String>(
          value: provider.selectedCountry,
          items: <String>['Indonesia', 'Singapore', 'Malaysia']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              // Ketika negara dipilih, memanggil metode setSelectedCountry pada provider untuk mengubah negara yang dipilih.
              provider.setSelectedCountry(newValue);
            }
          },
        ),
        // Expanded untuk menempatkan FutureBuilder dalam widget yang dapat berkembang sesuai dengan ruang yang tersedia.
        Expanded(
          child: FutureBuilder<List<University>>(
            future: Provider.of<UniversityProvider>(context).fetchUniversities(provider.selectedCountry),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Jika future masih menunggu, tampilkan CircularProgressIndicator.
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                // Jika terjadi kesalahan, tampilkan pesan kesalahan.
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                // Jika data berhasil dimuat, tampilkan daftar universitas.
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  itemBuilder: (context, index) {
                    // ListTile untuk menampilkan detail universitas.
                    return ListTile(
                      title: Text(
                        snapshot.data![index].name,
                        textAlign: TextAlign.center,
                      ),
                      subtitle: InkWell(
                        child: Text(
                          snapshot.data![index].website,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () async {
                          final url = snapshot.data![index].website;
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
    );
  }
}
