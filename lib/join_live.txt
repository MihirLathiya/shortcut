import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hotlinecafee/ViewModel/gift_view_model.dart';
import 'package:hotlinecafee/ViewModel/view_profile_view_model.dart';
import 'package:hotlinecafee/ViewModel/vs_view_model.dart';
import 'package:hotlinecafee/common/snackbar.dart';
import 'package:hotlinecafee/model/apis/api_response.dart';
import 'package:hotlinecafee/model/response_model/gift_list_res_model.dart';

import '../../Preference/preference.dart';
import '../../common/loading.dart';

class JoinLivePage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;
  final String? userId;
  final String? hostName;
  final int? channelId;
  final String? channelToken;
  final String? username;
  final String? hostImage;
  final String? userImage;

  /// Creates a call page with given channel name.
  const JoinLivePage(
      {Key? key,
      this.channelName,
      this.channelId,
      this.username,
      this.hostImage,
      this.userImage,
      this.channelToken,
      this.hostName,
      this.userId})
      : super(key: key);

  @override
  _JoinLivePageState createState() => _JoinLivePageState();
}

class _JoinLivePageState extends State<JoinLivePage> {
  GiftListViewModel giftListResModel = Get.put(GiftListViewModel());
  GiftViewModel sendGiftViewModel = Get.put(GiftViewModel());
  bool isStickerShow = false;

  VSLiveViewModel vsLiveViewModel = Get.put(VSLiveViewModel());
  bool loading = true;
  bool completed = false;
  static final _users = <int>[];
  bool muted = true;
  int userNo = 0;
  var userMap;
  bool heart = false;
  bool requested = false;
  int joinId = 0;
  bool _isLogin = true;
  bool _isInChannel = true;

  final _channelMessageController = TextEditingController();

  final _infoStrings = <Message>[];

  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;

  //Love animation
  final _random = math.Random();
  Timer? _timer;
  double height = 0.0;
  int _numConfetti = 10;
  var len;
  bool accepted = false;
  bool stop = false;
  RtcEngine? _rtcEngine;
  String appId = '9e6b469a2cae472ebc35ae0adbd449f4';
  @override
  void dispose() {
    _users.clear();

    _rtcEngine!.leaveChannel();
    _rtcEngine!.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    giftListResModel.giftListViewModel(model: {
      "user_id": PreferenceManager.getUserId(),
    });

    initialize();
    userMap = {widget.username: widget.userImage};
    _createClient();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _rtcEngine!.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _rtcEngine!.joinChannel(
      widget.channelToken,
      widget.channelName!,
      null,
      int.parse(PreferenceManager.getUserId()),
    );
    await _rtcEngine!.muteAllRemoteAudioStreams(true);
    await _rtcEngine!.disableAudio();
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _rtcEngine = await RtcEngine.create(appId);
    await _rtcEngine!.enableVideo();
    await _rtcEngine!.enableLocalAudio(false);
    await _rtcEngine!.enableLocalVideo(!muted);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _rtcEngine!.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';

        setState(() {});

        log('JOIN CHANNEL SUCCESS $uid');
      });
    },
        // leaveChannel: (stats) {
        // setState(() {
        //   _users.clear();
        // });
        // },
        userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _users.add(uid);
        log('USER JOINED ${_users.length}');
      });
    }, userOffline: (uid, elapsed) {
      log('LEAVE CHANNEL');
      Get.back(); // setState(() {
      final info = 'userOffline: $uid';
      _users.remove(uid);
      // });
    }));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    log('USER ADD');
    final List<StatefulWidget> list = [];
    // _users.add(widget.channelId!);
    _users.forEach(
      (int uid) {
        if (uid == widget.channelId) {
          list.add(
            RtcRemoteView.SurfaceView(
              uid: uid,
              channelId: widget.channelName.toString(),
            ),
          );
        }
      },
    );

    if (joinId == 0) {
      log('hello......not join');
    } else {
      list.add(RtcRemoteView.SurfaceView(
        uid: joinId,
        channelId: widget.channelName.toString(),
      ));
      log('hello...... join');
    }
    log('list.>>>>>> $list');
    if (accepted == true) {
      list.add(RtcLocalView.SurfaceView());
    }
    if (list.isEmpty) {
      setState(() {
        loading = true;
      });
    } else {
      setState(() {
        loading = false;
      });
    }

    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: ClipRRect(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return (loading == true) && (completed == false)
            ?
            //LoadingPage()
            CircularProgressIndicator()
            : Container(
                child: Column(
                  children: <Widget>[_videoView(views[0])],
                ),
              );
      case 2:
        return (loading == true) && (completed == false)
            ?
            //LoadingPage()
            CircularProgressIndicator()
            : Container(
                child: Column(
                  children: <Widget>[
                    _expandedVideoRow([views[0]]),
                    _expandedVideoRow([views[1]])
                  ],
                ),
              );
    }
    return Container();
  }

  void popUp() async {
    setState(() {
      heart = true;
    });
    Timer(
        Duration(seconds: 4),
        () => {
              _timer!.cancel(),
              setState(() {
                heart = false;
              })
            });
    _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
      setState(() {
        height += _random.nextInt(20);
      });
    });
  }

  Widget heartPop() {
    final size = MediaQuery.of(context).size;
    final confetti = <Widget>[];
    for (var i = 0; i < _numConfetti; i++) {
      final height = _random.nextInt(size.height.floor());
      final width = 20;
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 400,
            width: 200,
            child: Stack(
              children: confetti,
            ),
          ),
        ),
      ),
    );
  }

  /// Info panel to show logs
  Widget _messageList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null!;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: (_infoStrings[index].type == 'join')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: _infoStrings[index].image!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 32.0,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${_infoStrings[index].user} joined',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_infoStrings[index].type == 'message')
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: ImageLoading(
                                      height: 40.h,
                                      width: 40.h,
                                      url: '${_infoStrings[index].image}'),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _infoStrings[index].user!,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: _infoStrings[index]
                                              .message!
                                              .contains('https:')
                                          ? Row(
                                              children: [
                                                Image.network(
                                                  '${_infoStrings[index].message!.toString().split('.....').first}',
                                                  height: 40,
                                                  width: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                                Text(
                                                  ' * ${_infoStrings[index].message!.toString().split('.....').last}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Text(
                                              _infoStrings[index].message!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    _leaveChannel();
    _logout();
    _rtcEngine!.leaveChannel();
    _rtcEngine!.destroy();
    return true;
  }

  Widget _ending() {
    return Container(
      color: Colors.black.withOpacity(.7),
      child: Center(
        child: Container(
          width: double.infinity,
          color: Colors.grey[700],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'The Live has ended',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _liveText() {
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              backDropButton(
                icon: '',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _username() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _leaveChannel();
                _logout();
                _rtcEngine!.leaveChannel();
                _rtcEngine!.destroy();
                Get.back();
              },
              child: Container(
                height: 32.h,
                width: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            CachedNetworkImage(
              imageUrl: widget.hostImage!,
              imageBuilder: (context, imageProvider) => Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              child: Text(
                '${widget.hostName}',
                style: TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 1.3),
                    ),
                  ],
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Spacer(),
            Container(
              height: 32.h,
              width: 57.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xffE76944),
              ),
              child: Center(
                child: Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              height: 32.h,
              width: 57.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white12,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 20.h,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      '$userNo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget requestedWidget() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          spacing: 0,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 20,
              ),
              width: 130,
              alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 130,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: widget.hostImage!,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 130,
                    alignment: Alignment.centerRight,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: widget.userImage!,
                          imageBuilder: (context, imageProvider) => Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '${widget.channelName} Wants You To Be In This Live Video.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                top: 0,
                bottom: 20,
                right: 20,
              ),
              child: Text(
                'Anyone can watch, and some of your followers may get notified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Color(0xffE76944)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Go Live with ${widget.hostName}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // elevation: 2.0,
                // color: Colors.blue[400],
                onPressed: () async {
                  await _rtcEngine!.enableLocalVideo(true);
                  await _rtcEngine!.enableLocalAudio(true);
                  await _channel!.sendMessage(AgoraRtmMessage.fromText(
                      'k1r2i3s4t5i6e7 confirming ${PreferenceManager.getUserId()}'));
                  // log(log);
                  setState(() {
                    accepted = true;
                    requested = false;
                  });
                  await vsLiveViewModel.addVSViewModel(model: {
                    'from_id': '${widget.userId}',
                    'to_id': '${PreferenceManager.getUserId()}',
                  });
                  if (vsLiveViewModel.addVsApiResponse.status.toString() ==
                      Status.COMPLETE.toString()) {
                    log('DONE JOIN');
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: double.maxFinite,
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.pink[300],
                    ),
                  ),
                ),
                // elevation: 2.0,
                // color: Colors.transparent,
                onPressed: () async {
                  await _channel!.sendMessage(
                    AgoraRtmMessage.fromText(
                      'R1e2j3e4c5t6i7o8n9e0d Rejected',
                    ),
                  );
                  setState(() {
                    requested = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void stopFunction() async {
    await _rtcEngine!.enableLocalVideo(!muted);
    await _rtcEngine!.enableLocalAudio(!muted);
    setState(() {
      accepted = false;
    });
    log('MY IDS :- ${PreferenceManager.getUserId()}');
    log('OTHER IDS :- ${widget.userId}');
    await vsLiveViewModel.removeVSViewModel(model: {
      'from_id': '${widget.userId}',
      'to_id': '${PreferenceManager.getUserId()}',
    });
    if (vsLiveViewModel.removeVsApiResponse.status.toString() ==
        Status.COMPLETE.toString()) {
      log('USER REMOVED');
    }
  }

  Widget stopSharing() {
    return Container(
      height: MediaQuery.of(context).size.height / 2 + 40,
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: MaterialButton(
          minWidth: 0,
          onPressed: () async {
            await _channel!
                .sendMessage(AgoraRtmMessage.fromText('E1m2I3l4i5E6 stoping'));
            stopFunction();
          },
          child: Icon(
            Icons.clear,
            color: Colors.white,
            size: 15.0,
          ),
          shape: CircleBorder(),
          elevation: 2.0,
          color: Colors.blue[400],
          padding: const EdgeInsets.all(5.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: (completed == true)
                  ? _ending()
                  : Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        _viewRows(),
                        if (completed == false) _bottomBar(),
                        Positioned(
                            top: 20, left: 0, right: 0, child: _username()),

                        if (completed == false) _messageList(),
                        if (heart == true && completed == false) heartPop(),
                        if (requested == true) requestedWidget(),
                        if (accepted == true)
                          Positioned(top: 10, right: 10, child: stopSharing()),
                        if (isStickerShow)
                          if (_infoStrings.isNotEmpty)
                            if (_infoStrings.first.message!.contains('https:'))
                              Image.network(
                                _infoStrings.first.message
                                    .toString()
                                    .split('.....')
                                    .first,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),

                        //_ending()
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
  // Agora RTM

  Widget _bottomBar() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: ShapeDecoration(
                    color: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      side: const BorderSide(
                        width: 1,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    controller: _channelMessageController,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      hintText: "Type",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20.w,
              ),
              InkWell(
                onTap: () {
                  giftBottomSheet(
                    context,
                    sendGiftViewModel,
                    widget.userId!,
                    // _startkey,
                  );
                },
                child: Image.asset('images/Gift.png'),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () async {},
                child: SvgPicture.asset(
                  'images/call.svg',
                  height: 44.h,
                  width: 44.w,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              backDropButton(
                onTap: () {},
                icon: 'images/svg/menu.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await _client!.logout();
      // _log('Logout success.');
    } catch (errorCode) {
      //_log('Logout error: ' + errorCode.toString());
    }
  }

  void _leaveChannel() async {
    try {
      await _channel!.leave();
      //_log('Leave channel success.');
      _client!.releaseChannel(_channel!.channelId!);
      _channelMessageController.text = '';
    } catch (errorCode) {
      //_log('Leave channel error: ' + errorCode.toString());
    }
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel!.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: widget.username!, info: text, type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _sendMessage(text) async {
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel!.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: PreferenceManager.getUserName(), info: text, type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _createClient() async {
    _client =
        await AgoraRtmClient.createInstance('b42ce8d86225475c9558e478f1ed4e8e');
    _client!.onMessageReceived =
        (AgoraRtmMessage message, String peerId) async {
      var img =
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtP0v8NPq0_gfdDiu-nOn210pFSFsfKn1PnXF5NvMvP-IbENLdjP3Vdc2g9OQVbLdtGYE&usqp=CAU';
      _log(user: peerId, info: message.text, type: 'message');
    };
    _client!.onConnectionStateChanged = (int state, int reason) {
      log('STATE :- $state : REASON :- $reason');
      if (state == 5) {
        _client!.logout();
        // _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
    await _client!.login(null, widget.username!);
    _channel = await _createChannel(widget.channelName!);
    await _channel!.join();
    var len;
    _channel!.getMembers().then((value) {
      len = value.length;
      setState(() {
        userNo = len - 1;
      });
    });
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel? channel = await _client!.createChannel(name);
    channel!.onMemberJoined = (AgoraRtmMember member) async {
      var img =
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtP0v8NPq0_gfdDiu-nOn210pFSFsfKn1PnXF5NvMvP-IbENLdjP3Vdc2g9OQVbLdtGYE&usqp=CAU';
      userMap.putIfAbsent(member.userId, () => img);

      _channel!.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo = len - 1;
        });
      });

      _log(info: 'Member joined: ', user: member.userId, type: 'join');
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      var len;
      _channel!.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo = len - 1;
        });
      });
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) async {
      var img =
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtP0v8NPq0_gfdDiu-nOn210pFSFsfKn1PnXF5NvMvP-IbENLdjP3Vdc2g9OQVbLdtGYE&usqp=CAU';
      userMap.putIfAbsent(member.userId, () => img);
      _log(user: member.userId, info: message.text, type: 'message');
    };
    return channel;
  }

  void _log({String? info, String? type, String? user}) {
    if (type == 'message' && info!.contains('m1x2y3z4p5t6l7k8')) {
      popUp();
    } else if (type == 'message' && info!.contains('E1m2I3l4i5E6')) {
      log('info....stop..$info');
      setState(() {
        joinId = 0;
      });
      stopFunction();
    } else if (type == 'message' && info!.contains('k1r2i3s4t5i6e7')) {
      log('info...... $info  $type');
      var a = info.split(' ');
      setState(
        () {
          joinId = int.parse(a.last);
        },
      );

      // list.add(RtcRemoteView.SurfaceView(
      //   uid: int.parse(a.last),
      //   channelId: widget.channelName.toString(),
      // ));
      Message m;
      var image = userMap[user];
      m = new Message(message: 'joining', type: type, user: user, image: image);
      setState(() {
        _infoStrings.insert(0, m);
      });
    } else {
      Message m;
      var image = userMap[user];
      if (info!.contains('d1a2v3i4s5h6')) {
        var mess = info.split(' ');
        if (mess[1] == widget.username) {
          /*
          m = new Message(
              message: 'working', type: type, user: user, image: image);
              */
          setState(() {
            //_infoStrings.insert(0, m);
            requested = true;
          });
        }
      } else {
        m = new Message(message: info, type: type, user: user, image: image);
        setState(
          () {
            _infoStrings.insert(0, m);
            log('USER IMAGES :- ${_infoStrings.first.image}');
            if (_infoStrings.isNotEmpty) {
              isStickerShow = true;

              Future.delayed(
                Duration(seconds: 2),
                () {
                  setState(() {
                    isStickerShow = false;
                  });
                },
              );
            }
          },
        );
      }
    }
  }

  giftBottomSheet(
    BuildContext context,
    GiftViewModel sendGiftViewModel,
    userId,
    // _startkey
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.black38,
      builder: (context) {
        return GetBuilder<GiftListViewModel>(
          builder: (controller) {
            if (controller.giftApiResponse.status == Status.LOADING) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (controller.giftApiResponse.status == Status.ERROR) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (controller.giftApiResponse.status == Status.COMPLETE) {
              GiftListResponseModel giftListResponse =
                  controller.giftApiResponse.data;
              var giftData = giftListResponse.data;

              return Stack(
                children: [
                  GridView.builder(
                    itemCount: giftListResponse.data!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 2,
                        crossAxisCount: 4,
                        mainAxisExtent: 120),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          controller.selectGift(index, giftData![index].giftId,
                              giftData[index].coins, giftData[index].image);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: controller.selectedGift == index
                                  ? Color(0xffF8AB17)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ImageLoading(
                                    url: '${giftData![index].image}',
                                    width: 48.h,
                                    height: 48.h),
                              ),
                              Text(
                                '${giftData[index].title}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/Coin.png',
                                    height: 15,
                                    width: 15,
                                  ),
                                  Text(
                                    '${giftData[index].coins}',
                                    style: TextStyle(
                                        color: Color(0Xff81818A), fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'images/Coin.png',
                                    height: 15,
                                    width: 15,
                                  ),
                                  Text(
                                    '${int.parse(controller.giftPrice) * controller.counter}',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          controller.increment();
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: FittedBox(
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${controller.counter}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          controller.decrement();
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: FittedBox(
                                            child: Icon(Icons.remove),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  // key: _startkey,
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xffE76944),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await sendGiftViewModel.sendGiftViewModel(
                                      model: {
                                        'user_id':
                                            PreferenceManager.getUserId(),
                                        'receiver_id': userId,
                                        'gift_id': controller.selectedGiftID,
                                        'qty': '${controller.counter}'
                                      },
                                    );
                                    if (sendGiftViewModel
                                            .sendGiftApiResponse.status
                                            .toString() ==
                                        Status.COMPLETE.toString()) {
                                      _sendMessage(
                                          '${controller.image}.....${controller.counter}');
                                    } else {
                                      CommonSnackBar.commonSnackBar(
                                          message: 'Try Again');
                                    }

                                    Get.back();
                                  },
                                  child: Text('Send'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return SizedBox();
            }
          },
        );
        //   Column(
        //   mainAxisSize: MainAxisSize.min,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     SizedBox(
        //       height: 20,
        //     ),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: GestureDetector(
        //             onTap: () {},
        //             child: Column(
        //               children: [
        //                 Image.asset('images/3408506 1.png'),
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     'Game 1',
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.w500,
        //                         fontSize: 12,
        //                         color: Colors.white),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: GestureDetector(
        //             onTap: () {},
        //             child: Column(
        //               children: [
        //                 Image.asset('images/7469372 1.png'),
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     'Game 2',
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.w500,
        //                         fontSize: 12,
        //                         color: Colors.white),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //         GestureDetector(
        //           onTap: () {},
        //           child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Column(
        //               children: [
        //                 Image.asset('images/2314909 1.png'),
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     'Lucky Draw',
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.w500,
        //                         fontSize: 12,
        //                         color: Colors.white),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: GestureDetector(
        //             onTap: () {},
        //             child: Column(
        //               children: [
        //                 Image.asset('images/3473515 1.png'),
        //                 Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Text(
        //                     'Top Up',
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.w500,
        //                         fontSize: 12,
        //                         color: Colors.white),
        //                   ),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //     SizedBox(
        //       height: 20,
        //     ),
        //   ],
        // );
      },
    );
  }
}
