import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Definisi sebuah abstract class untuk event-event yang akan dipicu di dalam bloc.

abstract class DataEvent {}

// Event untuk memulai pengambilan data.
class FetchDataEvent extends DataEvent {}

// Event untuk menandakan bahwa data sudah selesai diambil.
class DataSiapEvent extends DataEvent {
  late ActivityModel activity;
  DataSiapEvent(ActivityModel act) : activity = act;
}

// Bloc yang mengelola logika bisnis dan state terkait aktivitas.
class ActivityBloc extends Bloc<DataEvent, ActivityModel> {
  String url = "https://www.boredapi.com/api/activity";
  
  // Constructor untuk menginisialisasi state awal dan menangani event.
  ActivityBloc() : super(ActivityModel(aktivitas: "", jenis: "")) {
    
    // Menangani event FetchDataEvent dengan menjalankan fetchData().
    on<FetchDataEvent>((event, emit) {
      fetchData();
    });
    
    // Menangani event DataSiapEvent dengan mengubah state menggunakan emit().
    on<DataSiapEvent>((even, emit) {
      emit(even.activity);
    });
  }

  // Method untuk mengubah data dari JSON menjadi objek ActivityModel
  void setFromJson(Map<String, dynamic> json) {
    String aktivitas = json['activity'];
    String jenis = json['type'];
    // Menambahkan event bahwa data sudah difetch dan siap untuk digunakan.
    add(DataSiapEvent(ActivityModel(aktivitas: aktivitas, jenis: jenis)));
  }

  // Method untuk mengambil data dari API menggunakan HTTP GET request.
  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

// Model untuk menyimpan data aktivitas.
class ActivityModel {
  String aktivitas;
  String jenis;
  ActivityModel({required this.aktivitas, required this.jenis});
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        // Membuat instance dari ActivityBloc dan menyediakannya ke widget tree.
        create: (_) => ActivityBloc(),
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
          // BlocBuilder untuk mengakses dan mendengarkan perubahan pada ActivityBloc.
          BlocBuilder<ActivityBloc, ActivityModel>(
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          // Memicu event FetchDataEvent saat tombol ditekan.
                          context.read<ActivityBloc>().add(FetchDataEvent());
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
