import 'package:crud/otp_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MobileInputScreen extends StatefulWidget {
  const MobileInputScreen({super.key});

  @override
  State<MobileInputScreen> createState() => _MobileInputScreenState();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  final formKey = GlobalKey<FormState>();

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  FirebaseAuth auth = FirebaseAuth.instance;


  TextEditingController mobileNumTxtController = TextEditingController();

  void verifyPhoneNumber() async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: '+91${mobileNumTxtController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          snackBar(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> PinCodeVerificationScreen(verificationId: verificationId,)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      snackBar(e.message);
    }catch (e) {
      snackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key:formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 100.0),
              child: Text("Continue with Phone",style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller:mobileNumTxtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "Enter mobile number",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)
                  ),
                  prefixIcon: Icon(Icons.call),
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return "please enter mobile number";
                  }else if(mobileNumTxtController.text.length != 10){
                    return "please enter valid mobile number";
                  }else {
                    return null;
                  }
                },
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  if(formKey.currentState!.validate()){
                    verifyPhoneNumber();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Continue",style: TextStyle(color: Colors.white),)
            )
          ],
        ),
      ),
    );
  }
}
