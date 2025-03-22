import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../view.dart';

class PreviewScreen extends StatefulWidget {
  final String meetingId;
  final bool isNewMeeting;

  const PreviewScreen({
    Key? key,
    required this.meetingId,
    this.isNewMeeting = false,
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final meetingController = Get.find<MeetingController>();
  LocalVideoTrack? _localVideoTrack;
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;

  @override
  void initState() {
    super.initState();
    _initLocalVideo();
  }

  Future<void> _initLocalVideo() async {
    try {
      final videoTrack = await LocalVideoTrack.createCameraTrack();

      setState(() {
        _localVideoTrack = videoTrack;
      });
    } catch (e) {
      // Hata yönetimi
      Get.log('Error initializing camera: $e', isError: true);
      setState(() {
        _isCameraEnabled = false;
      });
    }
  }

  @override
  void dispose() {
    _localVideoTrack?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewMeeting ? 'New Meeting' : 'Join Meeting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child:
                  _localVideoTrack != null && _isCameraEnabled
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 320,
                          height: 240,
                          child: VideoTrackRenderer(_localVideoTrack!),
                        ),
                      )
                      : Container(
                        width: 320,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam_off,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.isNewMeeting
                      ? 'Starting new meeting'
                      : 'Joining meeting: ${widget.meetingId.substring(0, min(8, widget.meetingId.length))}...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                      label: 'Mic',
                      isEnabled: _isMicEnabled,
                      onPressed: () {
                        setState(() {
                          _isMicEnabled = !_isMicEnabled;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildControlButton(
                      icon:
                          _isCameraEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                      label: 'Camera',
                      isEnabled: _isCameraEnabled,
                      onPressed: () {
                        setState(() {
                          _isCameraEnabled = !_isCameraEnabled;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    meetingController.isAudioEnabled.value = _isMicEnabled;
                    meetingController.isVideoEnabled.value = _isCameraEnabled;

                    if (widget.isNewMeeting) {
                      meetingController.createMeeting();
                    } else {
                      meetingController.joinMeeting(widget.meetingId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    widget.isNewMeeting ? 'Start meeting' : 'Join now',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: isEnabled ? Get.theme.primaryColor : Colors.grey,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isEnabled ? Get.theme.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
