import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nipController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordAdminController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    String inputNama = namaController.text.trim();
    String inputNip = nipController.text.trim();
    String inputEmail = emailController.text.trim();

    if (passwordAdminController.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;
        int? nipInput = int.tryParse(inputNip);

        UserCredential userCredentialAdmin = await auth
            .signInWithEmailAndPassword(
              email: emailAdmin,
              password: passwordAdminController.text,
            );

        UserCredential pegawaiCredential = await auth
            .createUserWithEmailAndPassword(
              email: inputEmail,
              password: "123456", // Password default
            );

        if (pegawaiCredential.user != null) {
          String uid = pegawaiCredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipInput,
            "nama": inputNama,
            "email": inputEmail,
            "uid": uid,
            "createdAt": FieldValue.serverTimestamp(),
          });

          await pegawaiCredential.user!.sendEmailVerification();

          await auth.signOut();

          UserCredential userCredentialAdmin = await auth
              .signInWithEmailAndPassword(
                email: emailAdmin,
                password: passwordAdminController.text,
              );
          Get.back();
          Get.back();
          Get.snackbar(
            "Sukses",
            "Pegawai berhasil ditambahkan dan email verifikasi telah dikirim",
          );
        }

        print(pegawaiCredential);
        Get.snackbar("Sukses", "Pegawai berhasil ditambahkan");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Error", "Password terlalu singkat");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Error", "Pegawai sudah terdaftar");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Error", "Admin tidak dapat login, password salah");
        } else {
          Get.snackbar("Error", e.message ?? "Terjadi kesalahan Firebase");
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal menambahkan pegawai");
      }
    } else {
      Get.snackbar("Error", "Password admin wajib diisi");
    }
  }

  void addPegawai() async {
    // 1. Ambil teks lalu bersihkan spasi di awal & akhir menggunakan .trim()
    String inputNama = namaController.text.trim();
    String inputNip = nipController.text.trim();
    String inputEmail = emailController.text.trim();

    // 2. Gunakan variabel yang sudah di-trim untuk pengecekan kondisi 'if'
    if (inputNama.isNotEmpty && inputNip.isNotEmpty && inputEmail.isNotEmpty) {
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("Masukkan password untuk validasi admin"),
            TextField(
              controller: passwordAdminController,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Get.back(), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await prosesAddPegawai();
            },
            child: Text("Submit"),
          ),
        ],
      );
    } else {
      Get.snackbar("Error", "Semua kolom wajib diisi!");
    }
  }
}
