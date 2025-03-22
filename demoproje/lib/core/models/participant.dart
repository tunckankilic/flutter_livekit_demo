class Participant {
  final String id;
  final String name;
  bool isAudioEnabled;
  bool isVideoEnabled;
  bool isScreenSharing;

  Participant({
    required this.id,
    required this.name,
    this.isAudioEnabled = true,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
  });
}
