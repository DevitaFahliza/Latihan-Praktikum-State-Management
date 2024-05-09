import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => UserCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

// Model berisi data/state user
class UserModel {
  String userId;
  UserModel({required this.userId}); // Constructor
}

// Cubit untuk mengelola UserModel
class UserCubit extends Cubit<UserModel> {
  UserCubit() : super(UserModel(userId: "")) {
    // Inisialisasi state dengan data dari SharedPreferences saat Cubit dibuat
    ambilDataUser();
  }

  // Method untuk mengambil data user dari SharedPreferences
  Future<void> ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Emit (mengirim) UserModel baru dengan data dari SharedPreferences
    emit(UserModel(userId: prefs.getString('userId') ?? ""));
  }

  // Method untuk menyimpan data user ke SharedPreferences
  Future<void> simpanDataUser() async {
    String user = "budiWati"; // Contoh data user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user);
    // Emit (mengirim) UserModel baru setelah data disimpan
    emit(UserModel(userId: user));
  }

  // Method untuk menghapus data user dari SharedPreferences
  Future<void> hapusDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    // Emit (mengirim) UserModel baru setelah data dihapus
    emit(UserModel(userId: ""));
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocBuilder<UserCubit, UserModel>(
            builder: (context, user) {
              if (user.userId == "") {
                // Jika user belum login
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("User belum login"),
                      ElevatedButton(
                        onPressed: () {
                          // Memanggil method untuk menyimpan data user saat tombol Login ditekan
                          context.read<UserCubit>().simpanDataUser();
                        },
                        child: Text("Login"),
                      ),
                    ],
                  ),
                );
              } else {
                // Jika user sudah login
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("User ID: ${user.userId}"),
                      ElevatedButton(
                        onPressed: () {
                          // Memanggil method untuk menghapus data user saat tombol Logout ditekan
                          context.read<UserCubit>().hapusDataUser();
                        },
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
