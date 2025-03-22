import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class ParticipantView extends StatelessWidget {
  final Participant participant;
  final bool isLocal;

  const ParticipantView({
    Key? key,
    required this.participant,
    required this.isLocal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    VideoTrack? videoTrack;
    bool isScreenShare = false;
    if (participant is LocalParticipant) {
      final localParticipant = participant as LocalParticipant;
      for (var trackPublication in localParticipant.videoTrackPublications) {
        if (trackPublication.track != null) {
          if (trackPublication.source == TrackSource.screenShareVideo) {
            isScreenShare = true;
            videoTrack = trackPublication.track;
            break;
          } else if (trackPublication.source == TrackSource.camera) {
            videoTrack = trackPublication.track;
          }
        }
      }
    } else if (participant is RemoteParticipant) {
      final remoteParticipant = participant as RemoteParticipant;
      for (var trackPublication in remoteParticipant.videoTrackPublications) {
        if (trackPublication.track != null) {
          if (trackPublication.source == TrackSource.screenShareVideo) {
            isScreenShare = true;
            videoTrack = trackPublication.track;
            break;
          } else if (trackPublication.source == TrackSource.camera) {
            videoTrack = trackPublication.track;
          }
        }
      }
    }

    // Check if audio is muted
    bool isAudioMuted = true;
    if (participant is LocalParticipant) {
      final localParticipant = participant as LocalParticipant;
      for (var trackPublication in localParticipant.audioTrackPublications) {
        if (trackPublication.track != null && !trackPublication.muted) {
          isAudioMuted = false;
          break;
        }
      }
    } else if (participant is RemoteParticipant) {
      final remoteParticipant = participant as RemoteParticipant;
      for (var trackPublication in remoteParticipant.audioTrackPublications) {
        if (trackPublication.track != null && !trackPublication.muted) {
          isAudioMuted = false;
          break;
        }
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(color: Colors.black),

          // Video view
          if (videoTrack != null)
            VideoTrackRenderer(videoTrack)
          else
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Text(
                  participant.identity?[0].toUpperCase() ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Overlay (name, status icons)
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      isScreenShare
                          ? '${participant.identity ?? "Participant"} (Screen)'
                          : (participant.identity ?? "Participant") +
                              (isLocal ? ' (You)' : ''),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAudioMuted)
                    const Icon(Icons.mic_off, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
