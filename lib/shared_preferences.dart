// Import library untuk menggunakan Flutter framework dan shared_preferences package
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> userId; // Future untuk menampung user ID dari SharedPreferences

  // Method untuk mengambil data user dari SharedPreferences
  Future<String> ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('userId') ?? ""); // Mengambil user ID, jika tidak ada, kembalikan string kosong
  }

  // Method untuk menyimpan data user ke SharedPreferences
  Future<void> simpanDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', "budiWati"); // Menyimpan user ID "budiWati" ke SharedPreferences
  }

  // Method untuk menghapus data user dari SharedPreferences
  Future<void> hapusDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Menghapus user ID dari SharedPreferences
  }

  @override
  void initState() {
    super.initState();
    userId = ambilDataUser(); // Menginisialisasi Future userId dengan data user dari SharedPreferences saat initState
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder<String>(
            future: userId, // Future yang akan digunakan oleh FutureBuilder
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Jika data sudah tersedia
                if (snapshot.data == "") {
                  // Jika user belum login (data kosong)
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("User belum login"),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Ketika tombol Login ditekan, simpan data user ke SharedPreferences dan refresh UI
                            simpanDataUser();
                            userId = ambilDataUser(); // Mendapatkan user ID terbaru
                          });
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  );
                } else {
                  // Jika user sudah login (data tidak kosong)
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("User ID: ${snapshot.data!}"), // Menampilkan user ID
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Ketika tombol Logout ditekan, hapus data user dari SharedPreferences dan refresh UI
                            hapusDataUser();
                            userId = ambilDataUser(); // Mendapatkan user ID terbaru setelah dihapus
                          });
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                }
              } else {
                // Jika data belum tersedia, tampilkan CircularProgressIndicator
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
