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
            if(passController.text == "123456"){
              Get.offAllNamed(Routes.NEW_PASSWORD);
            }else{
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
              title: "Login Gagal",
              middleText: "Email belum diverifikasi, silahkan cek email anda",
              actions: [
                OutlinedButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      Get.back();
                      Get.snackbar(
                        "Berhasil",
                        "Email verifikasi berhasil dikirim, silahkan cek email anda",
                      );
                    } catch (e) {
                      Get.snackbar(
                        "Terjadi Kesalahan",
                        "Tidak dapt mengirim email verifikasi, silahkan coba lagi nanti",
                      );
                    }
                  },
                  child: Text("Kirim Ulang"),
                ),
              ],
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
