import 'dart:async';
import 'package:crud/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  final String verificationId;
  const PinCodeVerificationScreen({super.key, required this.verificationId});



  @override
  State<PinCodeVerificationScreen> createState() => _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController otpTxtController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {

        },
        child: ListView(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 30),
              child: Text(
                'Verify your phone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.start,
              ),
            ),
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 30),
               child: Text(
                  "Enter code",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                textAlign: TextAlign.start,
            ),
             ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 30,
                ),
                child: PinCodeTextField(
                  appContext: context,
                  pastedTextStyle: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obscureText: true,
                  obscuringCharacter: '*',
                  blinkWhenObscuring: true,
                  animationType: AnimationType.fade,
                  validator: (v) {
                    if (v!.length != 6 ){
                      return "Please enter otp";
                    } else {
                      return null;
                    }
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  cursorColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: otpTxtController,
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onCompleted: (v) {
                    debugPrint("Completed");
                  },
                  onChanged: (value) {
                    debugPrint(value);
                    setState(() {
                      currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    debugPrint("Allowing to paste $text");
                    return true;
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async{
                  if (formKey.currentState!.validate()) {
                    try {
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: widget.verificationId,
                        smsCode: otpTxtController.text,
                      );
                       await auth.signInWithCredential(credential);
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
                    } on FirebaseAuthException catch (e) {
                      snackBar(e.message);
                    }catch (e) {
                      snackBar(e.toString());
                    }
                  }
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("Verify")
            )
          ],
        ),
      ),
    );
  }
}
