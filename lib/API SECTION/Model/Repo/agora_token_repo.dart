import 'package:hotlinecafee/Model/Response_model/daat.dart';
import 'package:hotlinecafee/model/response_model/live_streaming_res_model.dart';
import 'package:hotlinecafee/model/response_model/stop_live_stream_res_model.dart';

import '../services/api_service.dart';
import '../services/base_service.dart';

class AgoraTokenRepo extends BaseService {
  Future<AgoraTokenResponseModel> agoraTokenRepo(
      {Map<String, dynamic>? body}) async {
    var response = await APIService()
        .getResponse(url: calling, body: body, apitype: APIType.aPost);

    AgoraTokenResponseModel agoraTokenResponseModel =
        await AgoraTokenResponseModel.fromJson(response);
    print('AgoraTokenResponseModel $response');
    return agoraTokenResponseModel;
  }

  /// LiveStreaming

  Future<LiveStreamingResponseModel> liveStreamingTokenRepo(
      {Map<String, dynamic>? body}) async {
    var response = await APIService()
        .getResponse(url: liveStreaming, body: body, apitype: APIType.aPost);

    LiveStreamingResponseModel liveStreamingResponseModel =
        await LiveStreamingResponseModel.fromJson(response);
    print('LiveStreamingResponseModel $response');
    return liveStreamingResponseModel;
  }

  /// Stop LiveStreaming

  Future<StopLiveStreamingResponseModel> stopLiveStreamingTokenRepo(
      {Map<String, dynamic>? body}) async {
    var response = await APIService().getResponse(
        url: stopLiveStreaming, body: body, apitype: APIType.aPost);

    StopLiveStreamingResponseModel stopLiveStreamingResponseModel =
        await StopLiveStreamingResponseModel.fromJson(response);
    print('LiveStreamingResponseModel $response');
    return stopLiveStreamingResponseModel;
  }
}
