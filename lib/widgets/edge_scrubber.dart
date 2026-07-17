import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// One tick on the left-edge scrubber.
class ScrubEntry {
  ScrubEntry({required this.label, this.level = 2, GlobalKey? key})
    : key = key ?? GlobalKey();

  final String label;

  /// 1 = longest idle bar, 3 = shortest (visual hierarchy).
  final int level;
  final GlobalKey key;
}

/// Minimal left-edge bar scrubber.
///
/// Drag vertically to preview [ScrubEntry.label] on the right of the bars;
/// release to scroll that key into view. Drag right past [cancelDx] to cancel.
///
/// Bars use [Expanded] slots so dense tick lists never yellow-stripe overflow.
/// Prefer sparse anchors on New (month buckets). Pass [scrollController] when
/// the scrubber sits *outside* the scrollable (sibling in a [Stack]) so far
/// jumps can fall back to proportional [animateTo] then fine-align.
class EdgeScrubber extends StatefulWidget {
  const EdgeScrubber({
    super.key,
    required this.entries,
    this.scrollController,
    this.cancelDx = 56,
    this.minEntries = 2,
  });

  final List<ScrubEntry> entries;

  /// Optional controller of the scroll view being scrubbed (sibling case).
  final ScrollController? scrollController;
  final double cancelDx;
  final int minEntries;

  @override
  State<EdgeScrubber> createState() => _EdgeScrubberState();
}

class _EdgeScrubberState extends State<EdgeScrubber> {
  bool _active = false;
  bool _cancelled = false;
  int _index = 0;
  double _startX = 0;

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    if (entries.length < widget.minEntries) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final h = MediaQuery.sizeOf(context).height;
    final scrubTop = top + h * 0.20;
    final scrubBottom = bottom + h * 0.16 + 96;

    final barColor = isDark ? Colors.white : Colors.black;
    final labelBg = isDark ? const Color(0xE6181818) : const Color(0xF2FFFFFF);
    final labelBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final dense = entries.length > 18;
    final veryDense = entries.length > 36;

    return Positioned(
      left: 0,
      top: scrubTop,
      bottom: scrubBottom,
      width: _active ? 220 : 34,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: (d) {
          _startX = d.globalPosition.dx;
          setState(() {
            _active = true;
            _cancelled = false;
            _index = _indexFromLocalY(d.localPosition.dy, entries.length);
          });
          HapticFeedback.selectionClick();
        },
        onVerticalDragUpdate: (d) {
          final dx = d.globalPosition.dx - _startX;
          final next = _indexFromLocalY(d.localPosition.dy, entries.length);
          final cancel = dx > widget.cancelDx;
          if (cancel != _cancelled || next != _index) {
            if (next != _index && !cancel) {
              HapticFeedback.selectionClick();
            }
            setState(() {
              _cancelled = cancel;
              if (!cancel) _index = next;
            });
          }
        },
        onVerticalDragEnd: (_) {
          final jump = _active && !_cancelled;
          final i = _index.clamp(0, entries.length - 1);
          setState(() {
            _active = false;
            _cancelled = false;
          });
          if (jump) {
            _scrollToIndex(i);
          }
        },
        onVerticalDragCancel: () {
          setState(() {
            _active = false;
            _cancelled = false;
          });
        },
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              width: 18,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Expanded(
                      child: Center(
                        child: _ScrubBar(
                          level: entries[i].level,
                          selected: _active && !_cancelled && i == _index,
                          dimmed: _active && _cancelled,
                          color: barColor,
                          dense: dense,
                          veryDense: veryDense,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_active && !_cancelled)
              Positioned(
                left: 34,
                top: 0,
                bottom: 0,
                right: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final i = _index.clamp(0, entries.length - 1);
                    final n = entries.length;
                    final t = n <= 1 ? 0.5 : i / (n - 1);
                    const bubbleMaxH = 56.0;
                    final topPad = (t * (constraints.maxHeight - bubbleMaxH))
                        .clamp(0.0, double.infinity);
                    return Padding(
                      padding: EdgeInsets.only(top: topPad),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                            maxHeight: bubbleMaxH,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: labelBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: labelBorder,
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              entries[i].label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: isDark
                                    ? const Color(0xFFF0F0F0)
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_active && _cancelled)
              Positioned(
                left: 34,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: labelBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: labelBorder, width: 0.5),
                    ),
                    child: Text(
                      '松开取消',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF9A9A9A)
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _scrollToIndex(int index) async {
    final entries = widget.entries;
    if (entries.isEmpty) return;
    final i = index.clamp(0, entries.length - 1);
    final target = entries[i];

    if (await _ensureVisible(target)) {
      HapticFeedback.lightImpact();
      return;
    }

    // Key not built (far off-screen). Proportional jump then fine-align.
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients || entries.length < 2) {
      // One more frame in case layout just caught up.
      await Future<void>.delayed(Duration.zero);
      if (await _ensureVisible(target)) {
        HapticFeedback.lightImpact();
      }
      return;
    }

    final position = sc.position;
    final t = i / (entries.length - 1);
    final dest =
        position.minScrollExtent +
        t * (position.maxScrollExtent - position.minScrollExtent);
    await sc.animateTo(
      dest.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    // After rough land, align header if now mounted.
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (await _ensureVisible(target, durationMs: 200)) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<bool> _ensureVisible(ScrubEntry target, {int durationMs = 320}) async {
    final ctx = target.key.currentContext;
    if (ctx == null) return false;
    await Scrollable.ensureVisible(
      ctx,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
    return true;
  }

  int _indexFromLocalY(double localY, int n) {
    final box = context.findRenderObject() as RenderBox?;
    final height = box?.size.height ?? 1;
    if (height <= 0 || n <= 0) return 0;
    final t = (localY / height).clamp(0.0, 0.9999);
    return (t * n).floor().clamp(0, n - 1);
  }
}

class _ScrubBar extends StatelessWidget {
  const _ScrubBar({
    required this.level,
    required this.selected,
    required this.dimmed,
    required this.color,
    this.dense = false,
    this.veryDense = false,
  });

  final int level;
  final bool selected;
  final bool dimmed;
  final Color color;
  final bool dense;
  final bool veryDense;

  @override
  Widget build(BuildContext context) {
    final idleW = switch (level.clamp(1, 3)) {
      1 => dense ? 12.0 : 14.0,
      2 => dense ? 9.0 : 11.0,
      _ => dense ? 7.0 : 8.0,
    };
    final w = selected ? idleW + (dense ? 6 : 10) : idleW;
    final h = veryDense
        ? (selected ? 2.0 : 1.2)
        : dense
        ? (selected ? 2.5 : 1.5)
        : (selected ? 3.5 : 2.0);
    final opacity = dimmed
        ? 0.18
        : selected
        ? 0.92
        : 0.32;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
