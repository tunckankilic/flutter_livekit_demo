import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../../core/core.dart';
import '../view.dart';

class MeetingController extends GetxController {
  final authController = Get.find<AuthController>();

  // Meeting state
  final RxString roomId = ''.obs;
  final RxBool isMeetingActive = false.obs;
  final RxBool isChatOpen = false.obs;

  // Media state
  final RxBool isAudioEnabled = true.obs;
  final RxBool isVideoEnabled = true.obs;
  final RxBool isScreenSharing = false.obs;

  // Meeting duration
  final RxInt meetingDurationInSeconds = 0.obs;
  String get formattedDuration {
    final duration = Duration(seconds: meetingDurationInSeconds.value);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '$hours:' : ''}$minutes:$seconds';
  }

  // Timer for meeting duration
  Timer? _meetingTimer;

  // LiveKit objects
  Room? room;
  LocalParticipant? localParticipant;

  // WebSocket for chat
  WebSocketChannel? _chatWebSocket;

  // Chat messages
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;

  // Participants
  final RxList<RemoteParticipant> remoteParticipants =
      <RemoteParticipant>[].obs;

  void toggleChat() {
    isChatOpen.value = !isChatOpen.value;
  }

  void toggleAudio() {
    isAudioEnabled.value = !isAudioEnabled.value;
    if (localParticipant != null) {
      for (var publication in localParticipant!.audioTrackPublications) {
        if (publication.track != null) {
          if (isAudioEnabled.value) {
            publication.unmute();
          } else {
            publication.mute();
          }
        }
      }
    }
  }

  void toggleVideo() {
    isVideoEnabled.value = !isVideoEnabled.value;
    if (localParticipant != null) {
      for (var publication in localParticipant!.videoTrackPublications) {
        if (publication.track != null &&
            publication.source != TrackSource.screenShareVideo) {
          if (isVideoEnabled.value) {
            publication.unmute();
          } else {
            publication.mute();
          }
        }
      }
    }
  }

  Future<void> toggleScreenSharing() async {
    try {
      if (isScreenSharing.value) {
        await localParticipant?.setScreenShareEnabled(false);
      } else {
        await localParticipant?.setScreenShareEnabled(true);
      }
      isScreenSharing.value = !isScreenSharing.value;
    } catch (e) {
      print('Error toggling screen sharing: $e');
    }
  }

  Future<void> createMeeting() async {
    final newRoomId = const Uuid().v4();
    roomId.value = newRoomId;
    await joinMeeting(newRoomId);
  }

  Future<void> joinMeeting(String meetingId) async {
    if (authController.userId == null) {
      Get.snackbar('Error', 'You must be signed in to join a meeting');
      return;
    }

    try {
      roomId.value = meetingId;

      // Set up LiveKit room
      room = Room();

      // Connect to LiveKit server
      // Note: In a real app, you would get these tokens from your server
      // This is a simplified example
      const url = 'wss://your-livekit-server.com';
      const token =
          'your-token-here'; // You need to generate this on your server

      try {
        // connect() metodu void dönüyor, localParticipant'a atama yapamayız
        await room?.connect(
          url,
          token,
          connectOptions: const ConnectOptions(autoSubscribe: true),
        );

        // Room'a bağlandıktan sonra localParticipant'ı Room örneğinden alıyoruz
        localParticipant = room?.localParticipant;

        if (localParticipant != null) {
          await localParticipant?.setCameraEnabled(isVideoEnabled.value);
          await localParticipant?.setMicrophoneEnabled(isAudioEnabled.value);
        }

        // Set up event listeners for the room
        room?.addListener(_onRoomEvent);

        // Connect to chat WebSocket
        _connectChatWebSocket(meetingId);

        // Start meeting timer
        _startMeetingTimer();

        isMeetingActive.value = true;
        Get.toNamed('/meeting');
      } catch (e) {
        print('Failed to connect to LiveKit: $e');
        Get.snackbar('Error', 'Failed to connect to meeting');
      }
    } catch (e) {
      print('Error joining meeting: $e');
      Get.snackbar('Error', 'Failed to join meeting');
    }
  }

  void _startMeetingTimer() {
    meetingDurationInSeconds.value = 0;
    _meetingTimer?.cancel();
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      meetingDurationInSeconds.value++;
    });
  }

  void _onRoomEvent() {
    // Update remote participants list
    if (room != null) {
      remoteParticipants.value = room!.remoteParticipants.values.toList();
    }
  }

  void _connectChatWebSocket(String meetingId) {
    // In a real app, you would connect to your WebSocket server
    // This is a simplified example
    final wsUrl = Uri.parse('wss://your-websocket-server.com/chat/$meetingId');

    _chatWebSocket = WebSocketChannel.connect(wsUrl);

    _chatWebSocket?.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'chat') {
        final chatMessage = ChatMessage.fromJson(data['message']);
        chatMessages.add(chatMessage);
      }
    });
  }

  void sendChatMessage(String message) {
    if (message.trim().isEmpty) return;

    final chatMessage = ChatMessage(
      id: const Uuid().v4(),
      senderId: authController.userId!,
      senderName: authController.userName!,
      message: message,
      timestamp: DateTime.now(),
    );

    // Add to local list
    chatMessages.add(chatMessage);

    // Send over WebSocket
    _chatWebSocket?.sink.add(
      jsonEncode({
        'type': 'chat',
        'roomId': roomId.value,
        'message': chatMessage.toJson(),
      }),
    );
  }

  Future<void> leaveMeeting() async {
    // Stop timer
    _meetingTimer?.cancel();
    _meetingTimer = null;

    // Disconnect from LiveKit
    room?.removeListener(_onRoomEvent);
    await room?.disconnect();
    room = null;
    localParticipant = null;

    // Close WebSocket
    await _chatWebSocket?.sink.close();
    _chatWebSocket = null;

    // Reset state
    chatMessages.clear();
    remoteParticipants.clear();
    isMeetingActive.value = false;
    isChatOpen.value = false;
    roomId.value = '';
    meetingDurationInSeconds.value = 0;

    Get.offAllNamed('/');
  }

  @override
  void onClose() {
    leaveMeeting();
    super.onClose();
  }
}
