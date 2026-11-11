import 'package:flutter/material.dart';

class TodayHubScreen extends StatefulWidget {
  const TodayHubScreen({super.key});

  @override
  State<TodayHubScreen> createState() => _TodayHubScreenState();
}

class _TodayHubScreenState extends State<TodayHubScreen> {
  int _selectedIndex = 0;

  static const Color _primary = Color(0xFF0E71EB);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF414754);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color _surfaceContainer = Color(0xFFE5EEFF);
  static const Color _surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color _surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color _secondaryContainer = Color(0xFFDAE2FD);
  static const Color _onSecondaryFixedVariant = Color(0xFF3F465C);
  static const Color _tertiary = Color(0xFF10B981);
  static const Color _tertiaryContainer = Color(0xFF00865C);
  static const Color _orange = Color(0xFFFF6B00);

  final List<_ScheduleItem> _schedule = const [
    _ScheduleItem(
      time: '1:30',
      period: 'PM',
      title: 'Engineering Sprint Demo',
      subtitle: '45 mins • 14 teammates attending',
      joinable: true,
    ),
    _ScheduleItem(
      time: '3:00',
      period: 'PM',
      title: 'Weekly Executive All-Hands',
      subtitle: '60 mins • Zoom Auditorium',
      badge: 'Webinar',
      joinable: false,
    ),
  ];

  final List<_Teammate> _teammates = const [
    _Teammate(
      name: 'Elena R.',
      initials: 'ER',
      online: true,
      color: Color(0xFF7C3AED),
    ),
    _Teammate(
      name: 'Marcus T.',
      initials: 'MT',
      online: true,
      color: Color(0xFF2563EB),
    ),
    _Teammate(
      name: 'Sora K.',
      initials: 'SK',
      online: false,
      color: Color(0xFFDB2777),
    ),
    _Teammate(
      name: 'David L.',
      initials: 'DL',
      online: true,
      color: Color(0xFF059669),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildBriefing(),
                  const SizedBox(height: 20),
                  _buildSchedule(),
                  const SizedBox(height: 20),
                  _buildTeammates(),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Today',
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

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THURSDAY, OCT 24',
                    style: TextStyle(
                      color: _onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Good morning, Sarah',
                    style: TextStyle(
                      color: _onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.calendar_month, color: _primary, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.auto_awesome, color: _primary, size: 15),
              SizedBox(width: 6),
              Text(
                'AI Companion caught up on 4 overnight updates',
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward, color: _onSurfaceVariant, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(Icons.videocam, 'New Meeting', _orange, Colors.white),
        _quickAction(Icons.add_box, 'Join', _primary, Colors.white),
        _quickAction(
          Icons.edit_calendar,
          'Schedule',
          _surfaceContainerHighest,
          _primary,
        ),
        _quickAction(
          Icons.present_to_all,
          'Share Screen',
          _tertiaryContainer,
          Colors.white,
        ),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, Color bg, Color fg) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: fg, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'STARTING IN 12 MINS',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Room #4A • In-person / Zoom',
                style: TextStyle(
                  color: _onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Q4 Product Roadmap & Go-To-Market Alignment',
            style: TextStyle(
              color: _onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '10:00 AM – 11:00 AM (45m)  •  ID: 849 2039 1192',
            style: TextStyle(color: _onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _avatar('JD', const Color(0xFF7C3AED), 28),
                  _avatar('MK', const Color(0xFF2563EB), 28),
                  _avatar('RS', const Color(0xFFDB2777), 28),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+8',
                      style: TextStyle(
                        color: _onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You are Co-host',
                  style: TextStyle(
                    color: _onSecondaryFixedVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Start Meeting',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _iconButton(Icons.content_copy),
              const SizedBox(width: 8),
              _iconButton(Icons.more_vert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return IconButton(
      onPressed: () {},
      style: IconButton.styleFrom(
        backgroundColor: _surfaceContainer,
        foregroundColor: _onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: const Size(48, 48),
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Widget _avatar(String initials, Color color, double size) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBriefing() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_surfaceContainerLow, _surfaceContainer],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Morning Briefing',
                    style: TextStyle(
                      color: _onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Text(
                'Review all',
                style: TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _briefingItem(
            Icons.task_alt,
            _primary,
            'Design review notes ready for signoff',
            'From Figma Integration bot • 28 mins ago',
          ),
          const SizedBox(height: 8),
          _briefingItem(
            Icons.forum,
            _tertiaryContainer,
            'Alex Chen requested 1:1 sync on Sprint 32',
            'Recommended slot: 2:15 PM today',
          ),
        ],
      ),
    );
  }

  Widget _briefingItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _onSurfaceVariant, size: 18),
        ],
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Later Today',
              style: TextStyle(
                color: _onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '3 meetings scheduled',
              style: TextStyle(
                color: _onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._schedule.map(_scheduleCard),
      ],
    );
  }

  Widget _scheduleCard(_ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  item.time,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.period,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _tertiaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            color: _tertiaryContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (item.joinable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  color: _onSecondaryFixedVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: _onSurfaceVariant,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeammates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Pinned & Active Teammates',
              style: TextStyle(
                color: _onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'All Chats',
              style: TextStyle(
                color: _primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _teammates.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == _teammates.length) {
                return Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tag, color: _primary, size: 22),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '#q4-launch',
                      style: TextStyle(
                        color: _onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }
              final teammate = _teammates[index];
              return Column(
                children: [
                  Stack(
                    children: [
                      _avatar(teammate.initials, teammate.color, 52),
                      if (teammate.online)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
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
                  const SizedBox(height: 4),
                  Text(
                    teammate.name,
                    style: const TextStyle(
                      color: _onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScheduleItem {
  const _ScheduleItem({
    required this.time,
    required this.period,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.joinable,
  });

  final String time;
  final String period;
  final String title;
  final String subtitle;
  final String? badge;
  final bool joinable;
}

class _Teammate {
  const _Teammate({
    required this.name,
    required this.initials,
    required this.online,
    required this.color,
  });

  final String name;
  final String initials;
  final bool online;
  final Color color;
}
