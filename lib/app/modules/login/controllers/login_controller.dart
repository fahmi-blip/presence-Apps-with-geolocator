import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void login() async {
    if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
        );
        print(userCredential);

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            Get.offAllNamed(Routes.HOME);
          }else{
            Get.defaultDialog(
              title: "Login Gagal",
              middleText: "Email belum diverifikasi, silahkan cek email anda",
              textConfirm: "Kirim Ulang Email Verifikasi",
              onConfirm: () async {
                await userCredential.user!.sendEmailVerification();
                Get.back();
                Get.snackbar("Berhasil", "Email verifikasi telah dikirim ulang");
             },
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Get.snackbar("Login Gagal", "email tidak terdaftar");
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Login Gagal", "Password salah");
        }
      }
    } else {
      Get.snackbar("Login Gagal", "Email dan Password salah");
    }
  }
}
