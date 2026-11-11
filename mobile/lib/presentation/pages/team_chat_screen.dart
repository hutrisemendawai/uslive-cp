import 'package:flutter/material.dart';

class TeamChatScreen extends StatefulWidget {
  const TeamChatScreen({super.key});

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  int _selectedIndex = 2;
  String _selectedFilter = 'All';

  static const Color _primary = Color(0xFF0E71EB);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF414754);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainer = Color(0xFFE5EEFF);
  static const Color _surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color _surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color _secondaryContainer = Color(0xFFDAE2FD);
  static const Color _onSecondaryContainer = Color(0xFF5C647A);
  static const Color _tertiary = Color(0xFF10B981);
  static const Color _tertiaryContainer = Color(0xFF00865C);
  static const Color _secondary = Color(0xFF565E74);
  static const Color _outline = Color(0xFF727785);

  final List<_Conversation> _pinned = const [
    _Conversation(
      name: 'product-design-core',
      time: '9:42 AM',
      message: 'Shared prototype for the unified workspace screen...',
      sender: 'Sarah',
      icon: Icons.tag,
      bolt: true,
      attachment: 'prototype-v4.fig',
      unread: 5,
      pinned: true,
    ),
    _Conversation(
      name: 'Elena Rostova',
      time: '9:30 AM',
      message: 'I will upload the slide deck before the 10am call!',
      initials: 'ER',
      avatarColor: Color(0xFF7C3AED),
      status: _Status.active,
      verified: true,
      delivered: true,
      unread: 1,
      pinned: true,
    ),
  ];

  final List<_Conversation> _recent = const [
    _Conversation(
      name: 'growth-marketing-gtm',
      time: 'Yesterday',
      message: 'Campaign metrics look stellar this week...',
      sender: 'Marcus',
      icon: Icons.tag,
    ),
    _Conversation(
      name: 'David Miller',
      time: 'Yesterday',
      message: 'Sounds good, let us discuss during roadmap sync.',
      initials: 'DM',
      avatarColor: Color(0xFF059669),
      status: _Status.away,
    ),
    _Conversation(
      name: 'announcements-all',
      time: 'Oct 22',
      message: 'Annual benefits enrollment is open',
      sender: 'HR Team',
      icon: Icons.lock,
      locked: true,
    ),
    _Conversation(
      name: 'DevOps Alerts',
      time: 'Oct 21',
      message: 'Deployment to prod succeeded (v3.12.4)',
      icon: Icons.smart_toy,
      isBot: true,
      successIcon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.edit_square),
        label: const Text(
          'New Chat / Channel',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildSearchAndFilters(),
                  const SizedBox(height: 12),
                  _buildCatchUpBanner(),
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                    icon: Icons.star,
                    title: 'Pinned Chats',
                    trailing: '2 pinned',
                  ),
                  const SizedBox(height: 8),
                  ..._pinned.map(_conversationTile),
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                    title: 'Recent Conversations',
                    trailing: 'Mark all read',
                    trailingAction: true,
                  ),
                  const SizedBox(height: 8),
                  ..._recent.map(_conversationTile),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: _primary,
        unselectedItemColor: _onSurfaceVariant,
        backgroundColor: _surfaceContainerLowest,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Team Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recaps',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.videocam, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zoom Workplace',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Team Chat',
                  style: TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome, color: _primary, size: 22),
          ),
          Stack(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: _surfaceContainer,
                child: Icon(Icons.person, color: _onSurfaceVariant, size: 18),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _surfaceContainerLowest,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: _outline, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search chats, channels, or ask AI...',
                          hintStyle: TextStyle(color: _outline, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(color: _onSurface, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.mic, color: _primary, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune,
                color: _onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _filterChip('All'),
              _filterChip('Unread', badge: '3'),
              _filterChip('Channels'),
              _filterChip('Direct Messages'),
              _filterChip('Mentions'),
            ].map(
              (chip) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: chip,
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, {String? badge}) {
    final bool selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _primary : _surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : _primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: selected ? _primary : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCatchUpBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _surfaceContainerHigh,
            _surfaceContainer,
            _surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new,
                    color: _primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Smart Chat Catch-up',
                    style: TextStyle(
                      color: _onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _surfaceContainerLowest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'AI Powered',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '3 channels have unread discussions while you were offline.',
            style: TextStyle(
              color: _onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.summarize, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Generate 30-sec summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.close, color: _outline, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    IconData? icon,
    required String title,
    String? trailing,
    bool trailingAction = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: _primary, size: 18),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: trailingAction ? _primary : _outline,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _conversationTile(_Conversation c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.pinned
            ? _surfaceContainerLowest
            : _surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: c.pinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leadingAvatar(c),
          const SizedBox(width: 12),
          Expanded(child: _conversationContent(c)),
        ],
      ),
    );
  }

  Widget _leadingAvatar(_Conversation c) {
    final double size = c.pinned ? 48 : 44;
    final Widget core;

    if (c.icon != null) {
      core = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.isBot
              ? _surfaceContainerHighest
              : c.pinned
                  ? _secondaryContainer
                  : _surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          c.icon,
          color: c.isBot
              ? _primary
              : c.pinned
                  ? _onSecondaryContainer
                  : _onSurfaceVariant,
          size: c.pinned ? 24 : 22,
        ),
      );
    } else {
      core = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.avatarColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          c.initials ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (c.bolt) {
      return Stack(
        children: [
          core,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: _tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 12),
            ),
          ),
        ],
      );
    }

    if (c.status != _Status.none) {
      return Stack(
        children: [
          core,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: c.pinned ? 14 : 12,
              height: c.pinned ? 14 : 12,
              decoration: BoxDecoration(
                color: c.status == _Status.active ? _tertiary : _secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _surfaceContainerLowest,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return core;
  }

  Widget _conversationContent(_Conversation c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      c.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (c.verified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: _outline, size: 16),
                  ],
                  if (c.locked) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.lock, color: _outline, size: 14),
                  ],
                  if (c.isBot) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BOT',
                        style: TextStyle(
                          color: _onSecondaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              c.time,
              style: TextStyle(
                color: c.pinned ? _primary : _outline,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        if (c.successIcon)
          Row(
            children: [
              const Icon(Icons.check_circle, color: _tertiary, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  c.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          )
        else
          Text.rich(
            TextSpan(
              children: [
                if (c.sender != null)
                  TextSpan(
                    text: '${c.sender}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                TextSpan(text: c.message),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.pinned ? _onSurface : _onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        if (c.attachment != null || c.delivered || c.unread > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (c.attachment != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_file,
                        color: _onSurfaceVariant,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        c.attachment!,
                        style: const TextStyle(
                          color: _onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (c.delivered) ...[
                const Icon(Icons.done_all, color: _tertiary, size: 14),
                const SizedBox(width: 4),
                const Text(
                  'Delivered',
                  style: TextStyle(
                    color: _tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              if (c.unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${c.unread}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Conversation {
  const _Conversation({
    required this.name,
    required this.time,
    required this.message,
    this.sender,
    this.icon,
    this.initials,
    this.avatarColor,
    this.status = _Status.none,
    this.verified = false,
    this.isBot = false,
    this.locked = false,
    this.bolt = false,
    this.attachment,
    this.delivered = false,
    this.unread = 0,
    this.pinned = false,
    this.successIcon = false,
  });

  final String name;
  final String time;
  final String message;
  final String? sender;
  final IconData? icon;
  final String? initials;
  final Color? avatarColor;
  final _Status status;
  final bool verified;
  final bool isBot;
  final bool locked;
  final bool bolt;
  final String? attachment;
  final bool delivered;
  final int unread;
  final bool pinned;
  final bool successIcon;
}

enum _Status { none, active, away }
