// import 'dart:async';
//
// import 'package:flutter_phone_call_state/flutter_phone_call_state.dart';
//
// class CallAdTrigger {
//   final PhoneCallState _phoneCallStatePlugin = PhoneCallState.instance;
//   StreamSubscription? _callStateSubscription;
//
//   // Assume you already have an AdsService
//   // final AdsService _adsService = Get.find<AdsService>();
//
//   void startListening() {
//     _callStateSubscription = _phoneCallStatePlugin.phoneStateChange.listen((event) {
//       // Key: Listen for call end state
//       if (event.state == CallState.end) {
//         print('Call ended, triggering ad...');
//       }
//     });
//   }
//
//   void stopListening() {
//     _callStateSubscription?.cancel();
//   }
// }