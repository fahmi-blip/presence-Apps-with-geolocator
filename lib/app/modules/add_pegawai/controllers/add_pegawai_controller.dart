import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nipController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    // 1. Ambil teks lalu bersihkan spasi di awal & akhir menggunakan .trim()
    String inputNama = namaController.text.trim();
    String inputNip = nipController.text.trim();
    String inputEmail = emailController.text.trim();

    // 2. Gunakan variabel yang sudah di-trim untuk pengecekan kondisi 'if'
    if (inputNama.isNotEmpty && inputNip.isNotEmpty && inputEmail.isNotEmpty) {
      try {
        // 3. Konversi NIP ke tipe int
        int? nipInput = int.tryParse(inputNip);
        if (nipInput == null) {
          Get.snackbar("Error", "NIP harus berupa angka bulat yang valid!");
          return;
        }

        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(
              email: inputEmail,
              password: "123456", // Password default
            );
        
        if(userCredential.user != null){
          String uid = userCredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipInput,
            "nama": inputNama,
            "email": inputEmail,
            "uid": uid,
            "createdAt": FieldValue.serverTimestamp(),
          });

          userCredential.user!.sendEmailVerification();
        }


        print(userCredential);
        Get.snackbar("Sukses", "Pegawai berhasil ditambahkan");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Error", "Password terlalu singkat");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Error", "Pegawai sudah terdaftar");
        } else {
          Get.snackbar("Error", e.message ?? "Terjadi kesalahan Firebase");
        }
      } catch (e) {
        Get.snackbar("Error", "Gagal menambahkan pegawai");
      }
    } else {
      // Jalankan ini jika ada field yang terdeteksi string kosong "" setelah di-trim
      Get.snackbar("Error", "Semua kolom wajib diisi!");
    }
  }
}
