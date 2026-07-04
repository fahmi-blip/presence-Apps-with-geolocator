import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';

class NewPasswordController extends GetxController {

  TextEditingController newPassController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void newPassword() async{
    if(newPassController.text.isNotEmpty){
      if(newPassController.text != "123456"){
        try{
          await auth.currentUser!.updatePassword(newPassController.text);
        String email = auth.currentUser!.email!;

        await auth.signOut();
        
        await auth.signInWithEmailAndPassword(email: email, password: newPassController.text);
        
        Get.offAllNamed(Routes.HOME);
        }on FirebaseAuthException catch(e){
          if (e.code == 'weak-password') {
          Get.snackbar("Terjadi Kesalahan", "Password terlalu lemah, gunakan kombinasi huruf, angka, dan simbol");
        }
        }catch(e){
          Get.snackbar("Terjadi Kesalahan", "Tidak dapat mengubah password, silahkan coba lagi nanti");
        }
      }else{
        Get.snackbar(
          "Terjadi Kesalahan",
          "Password baru tidak boleh sama dengan password default",
        );
      }
    }else{
      Get.snackbar(
        "Terjadi Kesalahan",
        "Password baru tidak boleh kosong",
      );
    }
  }
}
