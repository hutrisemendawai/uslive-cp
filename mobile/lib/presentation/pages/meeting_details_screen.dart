import 'package:flutter/material.dart';

class MeetingDetailsScreen extends StatefulWidget {
  const MeetingDetailsScreen({super.key});

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  static const Color _primary = Color(0xFF0059BE);
  static const Color _primaryContainer = Color(0xFF0E71EB);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF414754);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceLow = Color(0xFFEFF4FF);
  static const Color _surfaceContainer = Color(0xFFE5EEFF);
  static const Color _tertiary = Color(0xFF006A48);
  static const Color _purple = Color(0xFF7C3AED);

  final List<bool> _completed = [true, false, false];
  int _selectedChapter = 1;
  bool _isPlaying = false;

  static const List<_ActionItem> _actions = [
    _ActionItem(
      title: 'Share finalized mobile UI specs with frontend leads',
      assignee: 'Sarah Jenkins',
    ),
    _ActionItem(
      title: 'Review enterprise security whitepaper with legal',
      assignee: 'Elena Rostova',
      due: 'Due Tomorrow',
      overdue: true,
    ),
    _ActionItem(
      title: 'Prepare staging demo build for executive review',
      assignee: 'Marcus Vance',
      due: 'Due Oct 28',
    ),
  ];

  static const List<_Chapter> _chapters = [
    _Chapter('00:00 - 08:30', 'Introduction & Q3 Retrospective', '00:00'),
    _Chapter(
      '08:31 - 22:15',
      'Roadmap Features & Mobile Architecture',
      '08:31',
    ),
    _Chapter('22:16 - 38:00', 'Go-To-Market & Launch Readiness', '22:16'),
    _Chapter('38:01 - 45:12', 'Q&A & Action Assignment', '38:01'),
  ];

  int get _completedCount => _completed.where((completed) => completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go back',
        ),
        title: const Text(
          'Meeting Detail',
          style: TextStyle(
            color: _onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFDAE2FD),
              child: Icon(Icons.person, color: _onSurfaceVariant, size: 19),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _buildNavigationActions(),
          const SizedBox(height: 8),
          _buildMeetingHeader(),
          const SizedBox(height: 12),
          _buildExecutiveSummary(),
          const SizedBox(height: 12),
          _buildActionItems(),
          const SizedBox(height: 12),
          _buildRecording(),
          const SizedBox(height: 8),
          _buildRecapActions(),
        ],
      ),
    );
  }

  Widget _buildNavigationActions() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          label: const Text('Back to Recaps'),
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        _roundAction(Icons.share, 'Share recap'),
        const SizedBox(width: 8),
        _roundAction(Icons.picture_as_pdf, 'Export PDF'),
      ],
    );
  }

  Widget _roundAction(IconData icon, String label) {
    return IconButton(
      onPressed: () {},
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: _surfaceLow,
        foregroundColor: _onSurfaceVariant,
        fixedSize: const Size(40, 40),
      ),
      icon: Icon(icon, size: 19),
    );
  }

  Widget _buildMeetingHeader() {
    return _surfaceSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: _primary, size: 15),
                SizedBox(width: 5),
                Text(
                  'Cloud Recording • Processed',
                  style: TextStyle(
                    color: Color(0xFF5C647A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Q4 Product Roadmap & Go-To-Market Alignment',
            style: TextStyle(
              color: _onSurface,
              fontSize: 23,
              height: 1.25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF727785), size: 15),
              Text('Oct 24, 2024', style: _metaStyle),
              Text('•', style: _metaStyle),
              Text('10:00 AM - 10:45 AM', style: _metaStyle),
              Text('•', style: _metaStyle),
              Text(
                '12 Participants',
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle, color: _tertiary, size: 16),
              SizedBox(width: 6),
              Text('Hosted by ', style: _metaStyle),
              Text(
                'Sarah Jenkins (You)',
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummary() {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple, _primaryContainer, Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: _purple, size: 17),
                      SizedBox(width: 6),
                      Text(
                        'Zoom AI Companion',
                        style: TextStyle(
                          color: _onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '99% confidence',
                    style: TextStyle(
                      color: _tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Executive Summary',
              style: TextStyle(
                color: _onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _summaryBullet(
              _purple,
              const TextSpan(
                children: [
                  TextSpan(text: 'Roadmap timeline confirmed for '),
                  TextSpan(
                    text: 'November 15 release',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' across iOS and Android ecosystems.'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _summaryBullet(
              _primary,
              const TextSpan(
                children: [
                  TextSpan(text: 'Marketing budget adjusted '),
                  TextSpan(
                    text: '+\$40k',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' towards enterprise paid customer acquisition and webinars.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _summaryBullet(
              _tertiary,
              const TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Security compliance audit successfully wrapped up with ',
                  ),
                  TextSpan(
                    text: 'zero high-priority findings',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: _surfaceLow.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.forum, color: _primary, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ask AI follow-up questions',
                      style: TextStyle(
                        color: _onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: _primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Ask now →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBullet(Color color, TextSpan text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            text,
            style: const TextStyle(
              color: _onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItems() {
    return _surfaceSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.playlist_add_check, color: _primary, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Next Steps & Action Items',
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_completedCount of ${_actions.length} done',
                  style: const TextStyle(
                    color: Color(0xFF3F465C),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_actions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
              child: _actionTile(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _actionTile(int index) {
    final item = _actions[index];
    final isCompleted = _completed[index];

    return InkWell(
      onTap: () => setState(() => _completed[index] = !isCompleted),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _surfaceLow.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (value) => setState(() => _completed[index] = value!),
              activeColor: _primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: _onSurface.withValues(
                        alpha: isCompleted ? 0.65 : 1,
                      ),
                      fontSize: 13,
                      height: 1.4,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: _onSurfaceVariant,
                        size: 14,
                      ),
                      Text(
                        item.assignee,
                        style: const TextStyle(
                          color: _onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      if (item.due != null) ...[
                        const Text('•', style: _metaStyle),
                        Icon(
                          item.overdue ? Icons.alarm : Icons.event,
                          color: item.overdue
                              ? const Color(0xFFBA1A1A)
                              : _onSurfaceVariant,
                          size: 13,
                        ),
                        Text(
                          item.due!,
                          style: TextStyle(
                            color: item.overdue
                                ? const Color(0xFFBA1A1A)
                                : _onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: item.overdue
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecording() {
    return _surfaceSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_display, color: _primary, size: 21),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recording & Smart Chapters',
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _selectedChapter == 1
                    ? '45:12 total'
                    : _chapters[_selectedChapter].time,
                style: const TextStyle(
                  color: _onSurfaceVariant,
                  fontSize: 11,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVideoPlaceholder(),
          const SizedBox(height: 8),
          ...List.generate(_chapters.length, _chapterTile),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF213145),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _VideoPlaceholderPainter()),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xCC213145),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFFBA1A1A), size: 8),
                    SizedBox(width: 6),
                    Text(
                      'Recap Sync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () {},
                tooltip: 'Fullscreen',
                icon: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ),
            Center(
              child: IconButton.filled(
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                style: IconButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  fixedSize: const Size(56, 56),
                ),
                iconSize: 34,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                tooltip: _isPlaying ? 'Pause recording' : 'Play recording',
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 19,
                          child: ColoredBox(
                            color: _primaryContainer,
                            child: SizedBox(height: 5),
                          ),
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          flex: 30,
                          child: ColoredBox(
                            color: Color(0xFF00865C),
                            child: SizedBox(height: 5),
                          ),
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          flex: 35,
                          child: ColoredBox(
                            color: _purple,
                            child: SizedBox(height: 5),
                          ),
                        ),
                        SizedBox(width: 3),
                        Expanded(
                          flex: 16,
                          child: ColoredBox(
                            color: Color(0xFFCBDBF5),
                            child: SizedBox(height: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _chapters[_selectedChapter].time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '45:12',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chapterTile(int index) {
    final chapter = _chapters[index];
    final selected = _selectedChapter == index;

    return Material(
      color: selected ? const Color(0x66D8E2FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _selectedChapter = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  chapter.range,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _onSurface,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_circle,
                color: selected ? _primary : const Color(0xFF727785),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecapActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: _primaryContainer,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.chat_outlined, size: 20),
            label: const Text(
              'Share Summary via Team Chat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: _surfaceContainer,
              foregroundColor: _primary,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.calendar_month, size: 20),
            label: const Text(
              'Schedule Follow-Up',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _surfaceSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.assignee,
    this.due,
    this.overdue = false,
  });

  final String title;
  final String assignee;
  final String? due;
  final bool overdue;
}

class _Chapter {
  const _Chapter(this.range, this.title, this.time);

  final String range;
  final String title;
  final String time;
}

class _VideoPlaceholderPainter extends CustomPainter {
  const _VideoPlaceholderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF2C405A);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 72, paint);
    paint.color = const Color(0xFF354C68);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.66, size.width, size.height * 0.34),
      paint,
    );
    paint.color = const Color(0xFF60738A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.24,
          size.width * 0.28,
          size.height * 0.28,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
    paint.color = const Color(0xFF8092A8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.16,
          size.height * 0.29,
          size.width * 0.2,
          size.height * 0.025,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
    paint.color = const Color(0xFF536A85);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.39), 17, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.64,
          size.height * 0.47,
          size.width * 0.16,
          size.height * 0.18,
        ),
        const Radius.circular(18),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const TextStyle _metaStyle = TextStyle(
  color: _MeetingDetailsScreenState._onSurfaceVariant,
  fontSize: 12,
);
