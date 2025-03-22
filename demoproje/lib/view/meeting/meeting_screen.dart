import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:async';
import '../../core/core.dart';
import '../view.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meetingController = Get.find<MeetingController>();

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving
        final shouldLeave = await _showLeaveConfirmationDialog() ?? false;
        if (shouldLeave) {
          await meetingController.leaveMeeting();
        }
        return shouldLeave;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Row(
              children: [
                Text(
                  'Meeting: ${meetingController.roomId.value.substring(0, 8)}...',
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      meetingController.formattedDuration,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy meeting ID',
              onPressed: () {
                // Copy meeting ID to clipboard logic
                MeetingUtils.showSnackbar(
                  'Copied',
                  'Meeting ID copied to clipboard',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'Participants',
              onPressed: () {
                _showParticipantsDialog(context);
              },
            ),
          ],
        ),
        body: Obx(() {
          return Row(
            children: [
              // Main content - participants grid
              Expanded(
                flex: meetingController.isChatOpen.value ? 7 : 10,
                child: Container(
                  color: Colors.black,
                  child: _buildParticipantsGrid(),
                ),
              ),

              // Chat panel (conditionally visible)
              if (meetingController.isChatOpen.value)
                const Expanded(flex: 3, child: ChatPanel()),
            ],
          );
        }),
        bottomNavigationBar: _buildControlsBar(),
      ),
    );
  }

  Future<bool?> _showLeaveConfirmationDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Leave Meeting'),
        content: const Text('Are you sure you want to leave this meeting?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    final meetingController = Get.find<MeetingController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Participants'),
        content: Obx(() {
          final participants = <Widget>[];

          // Katılımcı ekle
          if (meetingController.localParticipant != null) {
            participants.add(
              _buildParticipantListItem(
                meetingController.localParticipant!.identity ?? 'You',
                true,
                meetingController.isAudioEnabled.value,
                meetingController.isVideoEnabled.value,
              ),
            );
          }

          // Add remote participants
          for (var participant in meetingController.remoteParticipants) {
            bool isAudioEnabled = false;
            bool isVideoEnabled = false;

            // Ses durumunu kontrol et
            for (var publication in participant.audioTrackPublications) {
              if (publication.track != null && !publication.muted) {
                isAudioEnabled = true;
                break;
              }
            }

            // Video durumunu kontrol et
            for (var publication in participant.videoTrackPublications) {
              if (publication.track != null &&
                  publication.source != TrackSource.screenShareVideo &&
                  !publication.muted) {
                isVideoEnabled = true;
                break;
              }
            }

            participants.add(
              _buildParticipantListItem(
                participant.identity ?? 'Unknown',
                false,
                isAudioEnabled,
                isVideoEnabled,
              ),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child:
                participants.isEmpty
                    ? const Center(child: Text('No participants'))
                    : ListView(children: participants),
          );
        }),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildParticipantListItem(
    String name,
    bool isLocal,
    bool isAudioEnabled,
    bool isVideoEnabled,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Get.theme.primaryColor,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text('$name ${isLocal ? '(You)' : ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAudioEnabled ? Icons.mic : Icons.mic_off,
            color: isAudioEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(
            isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            color: isVideoEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsGrid() {
    final meetingController = Get.find<MeetingController>();

    return Obx(() {
      final participants = <Widget>[];

      // Add local participant
      if (meetingController.localParticipant != null) {
        participants.add(
          ParticipantView(
            participant: meetingController.localParticipant!,
            isLocal: true,
          ),
        );
      }

      // Add remote participants
      for (var participant in meetingController.remoteParticipants) {
        participants.add(
          ParticipantView(participant: participant, isLocal: false),
        );
      }

      // Calculate grid layout based on participant count
      int crossAxisCount;
      if (participants.length <= 1) {
        crossAxisCount = 1;
      } else if (participants.length <= 4) {
        crossAxisCount = 2;
      } else if (participants.length <= 9) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 4;
      }

      return participants.isEmpty
          ? const Center(
            child: Text(
              'Waiting for participants...',
              style: TextStyle(color: Colors.white),
            ),
          )
          : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: participants.length,
            itemBuilder: (context, index) => participants[index],
          );
    });
  }

  Widget _buildControlsBar() {
    final meetingController = Get.find<MeetingController>();

    return Container(
      color: Theme.of(Get.context!).colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          Obx(
            () => _buildControlButton(
              icon:
                  meetingController.isAudioEnabled.value
                      ? Icons.mic
                      : Icons.mic_off,
              label: 'Mic',
              onPressed: () => meetingController.toggleAudio(),
              isEnabled: meetingController.isAudioEnabled.value,
            ),
          ),

          // Camera toggle
          Obx(
            () => _buildControlButton(
              icon:
                  meetingController.isVideoEnabled.value
                      ? Icons.videocam
                      : Icons.videocam_off,
              label: 'Camera',
              onPressed: () => meetingController.toggleVideo(),
              isEnabled: meetingController.isVideoEnabled.value,
            ),
          ),

          // Screen sharing toggle
          Obx(
            () => _buildControlButton(
              icon: Icons.screen_share,
              label: 'Share',
              onPressed: () => meetingController.toggleScreenSharing(),
              isEnabled: meetingController.isScreenSharing.value,
            ),
          ),

          // Chat toggle
          Obx(
            () => _buildControlButton(
              icon: Icons.chat,
              label: 'Chat',
              onPressed: () => meetingController.toggleChat(),
              isEnabled: meetingController.isChatOpen.value,
            ),
          ),

          // Leave meeting button
          _buildControlButton(
            icon: Icons.call_end,
            label: 'Leave',
            onPressed: () async {
              final shouldLeave = await _showLeaveConfirmationDialog() ?? false;
              if (shouldLeave) {
                await meetingController.leaveMeeting();
              }
            },
            isEnabled: true,
            isEndCall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isEnabled,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor:
                isEndCall
                    ? Colors.red
                    : isEnabled
                    ? Get.theme.primaryColor
                    : Colors.grey,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isEndCall
                    ? Colors.red
                    : isEnabled
                    ? Get.theme.primaryColor
                    : Colors.grey,
          ),
        ),
      ],
    );
  }
}
