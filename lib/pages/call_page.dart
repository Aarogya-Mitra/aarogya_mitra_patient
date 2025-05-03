import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  Widget build(BuildContext context) {
    int userID = Random().nextInt(1000000); // Generate a random userID for the demo.
    return ZegoUIKitPrebuiltCall(
      appID: 2140552828, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: 'd0abcb45f58cac4a75a189ef850b867a79815a414901e319419fe9d10102fc65', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userID.toString(),
      userName: 'user_name$userID',
      callID: callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}

