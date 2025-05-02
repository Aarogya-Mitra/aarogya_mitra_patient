import 'dart:async';
import 'dart:math';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:arogya_mitra_patient/database/firebase_db.dart';
import 'package:arogya_mitra_patient/pages/prescription_page.dart';
import 'package:arogya_mitra_patient/widgets/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.roomID});
  final String roomID;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int userID = Random().nextInt(1000000);
  bool isDoctorJoined = false;
  late StreamSubscription<List<ZegoUIKitUser>> userJoinSub;
  late StreamSubscription<List<ZegoUIKitUser>> userLeaveSub;

  @override
  void initState() {
    super.initState();

    // Listen for users joining
    userJoinSub = ZegoUIKit().getUserListStream().listen((userList) {
      setState(() {
        isDoctorJoined = userList.length > 1;
      });
    });

    // 🔄 Listen for call end
    userLeaveSub = ZegoUIKit().getUserListStream().listen((userList) {
      if (userList.length == 1) {
        // Doctor left, you're the only one
        customOnCallEndFunction();
      }
    });
  }

  Future<void> customOnCallEndFunction() async {
    CustomDialog.showLoadingDialog(context, message: 'Ending Call...');
    try {
      // Get the consultation ID using the same logic as in sendPrescription

      QuerySnapshot querySnapshot =
          await FirebaseDb.firestore
              .collection("consultations")
              .where("patientId", isEqualTo: widget.roomID)
              .orderBy("createdAt", descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String consultationId = querySnapshot.docs.first.id;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => PrescriptionPage(consultationId: consultationId),
          ),
        );
      } else {
        // Fallback in case no consultation is found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active consultation found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error finding consultation: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    userJoinSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isDoctorJoined)
          ZegoUIKitPrebuiltCall(
            appID: 2140552828,
            appSign:
                'd0abcb45f58cac4a75a189ef850b867a79815a414901e319419fe9d10102fc65',
            userID: userID.toString(),
            userName: 'user_$userID',
            callID: widget.roomID,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          ),
        if (isDoctorJoined)
          Container(
            color: Colors.black.withOpacity(0.6),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  "Waiting for Doctor to Join...",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
