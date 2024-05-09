import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor package flutter_bloc untuk menggunakan Bloc dan Cubit
import 'package:flutter/material.dart'; // Mengimpor package flutter untuk membangun UI
import 'package:http/http.dart' as http; // Mengimpor package http untuk melakukan HTTP request
import 'dart:convert'; // Mengimpor package dart:convert untuk melakukan encoding dan decoding JSON
import 'dart:developer' as developer; // Mengimpor package developer untuk menggunakan log

// Model untuk menyimpan data aktivitas.
class ActivityModel {
  String aktivitas;
  String jenis;
  ActivityModel({required this.aktivitas, required this.jenis}); // Konstruktor

}

// Cubit yang mengelola logika bisnis terkait aktivitas.
class ActivityCubit extends Cubit<ActivityModel> {
  String url = "https://www.boredapi.com/api/activity";

  // Constructor untuk ActivityCubit, menginisialisasi state awal.
  ActivityCubit() : super(ActivityModel(aktivitas: "", jenis: ""));

  // Method untuk mengubah data dari JSON menjadi objek ActivityModel
  void setFromJson(Map<String, dynamic> json) {
    String aktivitas = json['activity'];
    String jenis = json['type'];
    emit(ActivityModel(aktivitas: aktivitas, jenis: jenis));
  }

  // Method untuk melakukan fetching data dari API.
  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ActivityCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocBuilder<ActivityCubit, ActivityModel>(
            buildWhen: (previousState, state) {
              // Logging perubahan state
              developer.log("${previousState.aktivitas} -> ${state.aktivitas}",
                  name: 'logyudi');
              return true;
            },
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          // Memanggil method fetchData() saat tombol ditekan.
                          context.read<ActivityCubit>().fetchData();
                        },
                        child: const Text("Saya bosan ..."),
                      ),
                    ),
                    Text(aktivitas.aktivitas),
                    Text("Jenis: ${aktivitas.jenis}")
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}

