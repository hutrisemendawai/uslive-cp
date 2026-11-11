import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/livekit_manager.dart';
import '../../data/models/message_model.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    required this.liveKitManager,
    required this.database,
    super.key,
  });

  final LiveKitManager liveKitManager;
  final AppDatabase database;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isGalleryView = false;
  bool isMuted = false;
  bool isVideoOff = false;
  EventsListener<RoomEvent>? _listener;

  static const Color _black = Color(0xFF000000);
  static const Color _darkGray = Color(0xFF1C1C1E);
  static const Color _tileGray = Color(0xFF2C2C2E);
  static const Color _avatarGray = Color(0xFF3A3A3C);
  static const Color _green = Color(0xFF34C759);
  static const Color _red = Color(0xFFEF4444);
  static const Color _blue = Color(0xFF0E71EB);
  static const Color _leaveRed = Color(0xFFE02E2E);

  Room? get _room => widget.liveKitManager.room;
  LocalParticipant? get _localParticipant => _room?.localParticipant;

  List<RemoteParticipant> get _remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? const [];

  Participant? get _activeSpeaker {
    final remotes = _remoteParticipants;
    for (final participant in remotes) {
      if (participant.isSpeaking) {
        return participant;
      }
    }
    if (remotes.isNotEmpty) {
      return remotes.first;
    }
    return _localParticipant;
  }

  List<Participant> get _carouselParticipants {
    final active = _activeSpeaker;
    return _remoteParticipants.where((p) => p != active).toList();
  }

  List<Participant> get _allParticipants {
    final local = _localParticipant;
    final participants = List<Participant>.of(_remoteParticipants);
    if (local != null) {
      participants.add(local);
    }
    return participants;
  }

  @override
  void initState() {
    super.initState();
    final local = _localParticipant;
    isMuted = !(local?.isMicrophoneEnabled() ?? true);
    isVideoOff = !(local?.isCameraEnabled() ?? true);
    _room?.addListener(_onRoomUpdate);
    _listener = _room?.createListener();
    _listener?.on<DataReceivedEvent>(_onDataReceived);
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomUpdate);
    unawaited(_listener?.dispose());
    super.dispose();
  }

  void _onRoomUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onDataReceived(DataReceivedEvent event) {
    try {
      final text = utf8.decode(event.data);
      final json = jsonDecode(text) as Map<String, dynamic>;
      unawaited(widget.database.messagesDao.insertMessage(MessageModel.fromJson(json)));
    } catch (_) {}
  }

  void _toggleMicrophone() {
    setState(() => isMuted = !isMuted);
    unawaited(widget.liveKitManager.toggleMicrophone());
  }

  void _toggleCamera() {
    setState(() => isVideoOff = !isVideoOff);
    unawaited(widget.liveKitManager.toggleCamera());
  }

  bool _isLocal(Participant participant) => participant == _localParticipant;

  String _displayName(Participant participant) {
    final name = participant.name.trim();
    return name.isNotEmpty ? name : participant.identity;
  }

  String _initials(Participant participant) {
    final name = _displayName(participant).trim();
    if (name.isEmpty) {
      return '?';
    }
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  VideoTrack? _videoTrack(Participant participant) {
    for (final publication in participant.videoTrackPublications) {
      if (!publication.isScreenShare) {
        final track = publication.track;
        if (track != null) {
          return track as VideoTrack;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: isGalleryView ? _buildGalleryView() : _buildSpeakerView(),
            ),
            _buildBottomControlBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: _black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.volume_up, color: Colors.white, size: 22),
              SizedBox(width: 16),
              Icon(Icons.flip_camera_ios, color: Colors.white, size: 20),
            ],
          ),
          InkWell(
            onTap: () => setState(() => isGalleryView = !isGalleryView),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _darkGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGalleryView ? Icons.person : Icons.grid_view,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isGalleryView ? 'Speaker' : 'Gallery',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _room?.name ?? 'Zoom',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.expand_more, color: Colors.white70, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerView() {
    final speaker = _activeSpeaker;
    return Stack(
      children: [
        if (speaker != null)
          Positioned.fill(
            child: _buildVideoFill(speaker, initialsSize: 40, avatarSize: 120),
          )
        else
          const Positioned.fill(child: ColoredBox(color: _black)),
        if (speaker != null)
          Positioned(
            left: 12,
            bottom: 12,
            child: _buildNameBadge(
              speaker,
              isLocal: _isLocal(speaker),
              iconSize: 14,
              textSize: 13,
            ),
          ),
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          height: 100,
          child: _buildParticipantStrip(),
        ),
        if (_localParticipant != null)
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildPiP(_localParticipant!),
          ),
      ],
    );
  }

  Widget _buildParticipantStrip() {
    final carousel = _carouselParticipants;
    if (carousel.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: carousel.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) => _buildCarouselTile(carousel[index]),
    );
  }

  Widget _buildCarouselTile(Participant participant) {
    return Container(
      width: 76,
      height: 94,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _tileGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoFill(participant),
          Positioned(
            left: 4,
            right: 4,
            bottom: 4,
            child: _buildNameBadge(
              participant,
              isLocal: _isLocal(participant),
              expand: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPiP(Participant participant) {
    return Container(
      width: 100,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _tileGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoFill(participant),
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: _buildNameBadge(
              participant,
              isLocal: true,
              iconSize: 12,
              textSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryView() {
    final all = _allParticipants;
    if (all.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.72,
        ),
        itemCount: all.length,
        itemBuilder: (context, index) => _buildGalleryTile(all[index]),
      ),
    );
  }

  Widget _buildGalleryTile(Participant participant) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _tileGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoFill(participant, initialsSize: 24),
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: _buildNameBadge(
              participant,
              isLocal: _isLocal(participant),
              iconSize: 12,
              textSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFill(
    Participant participant, {
    double initialsSize = 18,
    double avatarSize = 64,
  }) {
    final track = _videoTrack(participant);
    final isLocal = _isLocal(participant);
    final showPlaceholder =
        track == null || track.muted || (isLocal && isVideoOff);
    if (!showPlaceholder) {
      return VideoTrackRenderer(track!, fit: VideoViewFit.cover);
    }
    return Container(
      color: _tileGray,
      alignment: Alignment.center,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: const BoxDecoration(
          color: _avatarGray,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials(participant),
          style: TextStyle(
            color: Colors.white,
            fontSize: initialsSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNameBadge(
    Participant participant, {
    bool isLocal = false,
    double iconSize = 10,
    double textSize = 10,
    bool expand = false,
  }) {
    final muted = isLocal ? isMuted : participant.isMuted;
    final text = Text(
      isLocal ? 'You' : _displayName(participant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: textSize,
        fontWeight: FontWeight.w500,
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            muted ? Icons.mic_off : Icons.mic,
            color: muted ? _red : _green,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          if (expand) Expanded(child: text) else text,
        ],
      ),
    );
  }

  Widget _buildBottomControlBar() {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: _darkGray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            iconColor: isMuted ? _red : Colors.white,
            onTap: _toggleMicrophone,
          ),
          _buildControlButton(
            icon: isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: isVideoOff ? 'Start Video' : 'Stop Video',
            iconColor: isVideoOff ? _red : Colors.white,
            onTap: _toggleCamera,
          ),
          _buildControlButton(
            icon: Icons.ios_share,
            label: 'Share',
            iconColor: _green,
            onTap: () =>
                unawaited(widget.liveKitManager.setShareScreenEnabled(true)),
          ),
          _buildControlButton(
            icon: Icons.group,
            label: 'Participants',
            iconColor: Colors.white,
            badgeCount: _remoteParticipants.length,
            onTap: () {},
          ),
          InkWell(
            onTap: () => unawaited(widget.liveKitManager.disconnect()),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _leaveRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    int? badgeCount,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: iconColor, size: 24),
                if (badgeCount != null)
                  Positioned(
                    right: -10,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      constraints: const BoxConstraints(minWidth: 15),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD1D1D6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
