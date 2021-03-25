import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genesis_travels/code/constants.dart';
import 'package:genesis_travels/code/custom_widgets.dart';
import 'package:sms_autofill/sms_autofill.dart';

AuthService authService = AuthService();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User> user;
  AuthService() {
    user = _auth.authStateChanges();
  }

  Future signInWithNumber(BuildContext context, String number) async {
    print('signing with number');
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: bottomSheetShape,
        builder: (context) {
          return SingleChildScrollView(
              child: Container(
            // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(bottom: 8)),
                customDivider(MediaQuery.of(context).size.width * 0.1),
                Padding(padding: EdgeInsets.only(bottom: 8)),
                customLoadingModule('Requesting OTP'),
              ],
            ),
          ));
        });
    _auth.verifyPhoneNumber(
        phoneNumber: '+91$number',
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          print('auto verified?');
          verifyUser(context, credential);
        },
        verificationFailed: (FirebaseAuthException exception) {
          print('verificationFailed: $exception');
          Navigator.pop(context);
          AlertDialog dialog = new AlertDialog(content: Text(exception.message));
          showDialog(context: context, builder: (context) => dialog);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          print('code sent');
          TextEditingController _codeController = new TextEditingController();
          bool disposed = false;
          bool submitted = false;
          bool showLoading = true;
          Navigator.pop(context);
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              shape: bottomSheetShape,
              builder: (context) {
                double width = MediaQuery.of(context).size.width;
                double height = MediaQuery.of(context).size.height;
                return SingleChildScrollView(
                  child: CustomStatefulBuilder(
                    dispose: () => disposed = true,
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(padding: EdgeInsets.only(bottom: 8)),
                          customDivider(width * 0.1),
                          Padding(padding: EdgeInsets.only(bottom: 8)),
                          Center(
                            child: Text(
                              'Enter OTP',
                              style: Theme.of(context).textTheme.headline3.copyWith(color: appColor, fontSize: 24),
                            ),
                          ),
                          showLoading ? customLoadingModule(submitted ? 'Verifying' : 'Detecting OTP') : SizedBox.shrink(),
                          Padding(padding: EdgeInsets.only(bottom: 8)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: PinInputTextField(
                              controller: _codeController,
                              decoration: UnderlineDecoration(
                                textStyle: TextStyle(fontSize: 20, color: appColor),
                                colorBuilder: FixedColorBuilder(appColor),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (code) async {
                                if (code.length == 6 && !disposed) {
                                  setState(() {
                                    submitted = true;
                                    showLoading = true;
                                  });
                                  FocusScope.of(context).unfocus();
                                  try {
                                    PhoneAuthCredential credential =
                                        PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                                    verifyUser(context, credential);
                                  } catch (e) {
                                    // Navigator.pop(context);
                                    if (!disposed) {
                                      setState(() => showLoading = false);
                                      _codeController.text = '';
                                      AlertDialog dialog = new AlertDialog(content: new Text('Wrong OTP entered, try again'));
                                      showDialog(context: context, builder: (context) => dialog);
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 8)),
                        ],
                      );
                    },
                  ),
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
        });
  }

  Future verifyUser(BuildContext context, PhoneAuthCredential credential) async {
    (await _auth.signInWithCredential(credential)).user;
    Navigator.pop(context);
  }

  Future updateUserData(User user, String displayName) async {
    DocumentReference ref = _db.doc('users/${user.uid}');
    user.updateProfile(displayName: displayName);
    var result = await ref.set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'displayName': displayName,
      'lastSeen': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    return result;
  }

  Future<String> getUserData(User user) async {
    String displayName;
    await _db.collection('users').doc(user.uid).get().then((doc){
      if(doc.exists && user.displayName != null){
        displayName = doc.get('displayName');
      }
    });
    return displayName;
  }

  Future<bool> checkIfAdmin(String phoneNumber) async {
    bool isAdmin = false;
    await _db.collection('admins').doc(phoneNumber).get().then((doc){
      if(doc.exists){
        isAdmin = true;
      }
    });
    return isAdmin;
  }

  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('error signing out $e');
    }
  }
}
