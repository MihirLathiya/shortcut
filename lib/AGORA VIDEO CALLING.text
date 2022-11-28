import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hotlinecafee/Common/snackbar.dart';
import 'package:hotlinecafee/Preference/preference.dart';
import 'package:hotlinecafee/ViewModel/brodcast_controller.dart';
import 'package:hotlinecafee/ViewModel/current_blance_view-model.dart';
import 'package:hotlinecafee/ViewModel/end_call_view_model.dart';
import 'package:hotlinecafee/common/chat_commons.dart';
import 'package:hotlinecafee/common/loading.dart';
import 'package:permission_handler/permission_handler.dart';

class RandomMatchVideoScreen extends StatefulWidget {
  final userName;
  final userImage;
  final channelName;
  final channelToken;
  final secondUserId;
  final userId;
  const RandomMatchVideoScreen(
      {Key? key,
      this.userName,
      this.userImage,
      this.channelName,
      this.channelToken,
      this.secondUserId,
      this.userId})
      : super(key: key);

  @override
  State<RandomMatchVideoScreen> createState() => _RandomMatchVideoScreenState();
}

class _RandomMatchVideoScreenState extends State<RandomMatchVideoScreen> {
  bool userJoin = false;
  // /// AGORA CALLING
  String appId = '72739f20a0644e549ac1689f529f823c';

  EndCallViewModel endCallViewModel = Get.put(EndCallViewModel());

  int? _remoteUid;
  RtcEngine? _engine;

  CountController countController = CountController();
  Timer? timer;
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      countController.counterIncrease();
    });
  }

  int x = 2000;
  CurrentBalanceViewModel _currentBalanceViewModel =
      Get.put(CurrentBalanceViewModel());
  var pairedList = [];
  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  updateCollection() async {
    startTimer();

    log('ADMISSION CLOSED');
  }

  List waitingList = [];
  Future getWaitingData() async {
    var data =
        await firebaseFirestore.collection('pairing_system').doc('data').get();
    Map<String, dynamic>? userData = data.data();

    setState(() {
      waitingList = userData!['waiting'];
    });

    print('WAITING LIST :- $waitingList');
    return waitingList;
  }

  Future<void> initForAgora() async {
    setState(() {});
    await [Permission.mediaLibrary, Permission.camera].request();
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine!.enableVideo();
    _engine!.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          setState(() {
            userJoin = true;
          });
          print('local user $uid joined');
        },
        userJoined: (int uid, int elapsed) {
          print('remote user $uid joined');
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print('local user $uid left channel');
          Get.back();
          _remoteUid = null;
          _engine!.leaveChannel();
          _engine!.destroy();
        },
      ),
    );

    await _engine!
        .joinChannel(widget.channelToken, widget.channelName, null, 0);
    await _engine?.enableVideo();
    await _engine?.enableAudio();
  }

  Widget _renderLocalPreview() {
    return Transform.rotate(
      angle: 0,
      child: userJoin == true
          ? RtcLocalView.TextureView()
          : RtcLocalView.SurfaceView(),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      updateCollection();
      return RtcRemoteView.SurfaceView(
        channelId: widget.channelName,
        uid: _remoteUid!,
      );
    } else {
      return Container(
        height: Get.height,
        width: Get.width,
        color: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _engine!.leaveChannel();
    _engine!.destroy();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        CommonSnackBar.commonSnackBar(message: 'First end video call');
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: [
                Center(
                  child: _renderRemoteVideo(),
                ),
                Positioned(
                  bottom: 30,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "images/call_user_chat.png",
                          // height: 150,
                          // width: 150,
                        ),
                        Spacer(),
                        InkWell(
                            onTap: () {
                              giftBottomSheet(context);
                            },
                            child: Image.asset('images/Gift.png')),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                            onTap: () {
                              menuBarBottomSheet(context, _engine!);
                            },
                            child: Image.asset('images/call_user_equal.png')),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            exitFunction();
                          },
                          child: Image.asset(
                            "images/call_user_remove.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 50.h,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: ImageLoading(
                            url: '${widget.userImage}',
                            height: 40.h,
                            width: 40.h,
                          ),
                        ),
                        SizedBox(width: Get.width * 0.015),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.userName}',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        Spacer(),
                        Obx(
                          () => Text(
                            '${countController.hour.value} : ${countController.min.value} : ${countController.count.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          height: Get.height * 0.040,

                          // width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 2),
                            child: Row(
                              children: [
                                Image.asset(
                                  "images/Dimond_fill.png",
                                  height: 20.h,
                                  width: 20.w,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Obx(
                                  () => Text(
                                    "${countController.min}/min",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_remoteUid != null)
              Positioned(
                bottom: 100.h,
                right: 30.w,
                child: Container(
                  width: 100,
                  height: 150,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: _renderLocalPreview(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  exitFunction() async {
    var data = await firebaseFirestore.collection('paired').doc('first').get();
    Map<String, dynamic>? userData = data.data();

    setState(() {
      pairedList = userData!['pair'];
    });

    log('PAIRED LIST :- ${pairedList}');
    pairedList.forEach(
      (element) async {
        if (element.toString().split(' + ').first ==
                PreferenceManager.getUserId() ||
            element.toString().split(' + ').last ==
                PreferenceManager.getUserId()) {
          pairedList.remove(element);
          firebaseFirestore.collection('paired').doc('first').update(
            {'pair': pairedList},
          );
        }
      },
    );

    await getWaitingData();
    waitingList.add(widget.userId);
    waitingList.add(widget.secondUserId);
    await waitingList.toSet().toList();
    FirebaseFirestore.instance.collection('pairing_system').doc('data').update(
      {'waiting': waitingList},
    );
    FirebaseFirestore.instance
        .collection('user')
        .doc('${widget.userId}')
        .update(
      {'randomMatch': false},
    );
    FirebaseFirestore.instance
        .collection('user')
        .doc('${widget.secondUserId}')
        .update(
      {'randomMatch': false},
    );
    Get.back();
    Get.back();
  }
}

giftBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    backgroundColor: Colors.black38,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Image.asset('images/3408506 1.png'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Game 1',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Image.asset('images/7469372 1.png'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Game 2',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset('images/2314909 1.png'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Lucky Draw',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Image.asset('images/3473515 1.png'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Top Up',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    },
  );
}

menuBarBottomSheet(BuildContext context, RtcEngine _engine) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    backgroundColor: Colors.black38,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Get.height * 0.01,
          ),
          Divider(
            endIndent: 160,
            indent: 160,
            thickness: 4,
            color: Color(0xfff4F4F5B),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset('images/call_user_video_icon.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset('images/call_user_noice_icon.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    _engine.enableAudio();
                  },
                  child: Image.asset('images/call_user_sound_icon.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    _engine.switchCamera();
                  },
                  child: Image.asset('images/call_user_switch_camara_icon.png'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    },
  );
}
