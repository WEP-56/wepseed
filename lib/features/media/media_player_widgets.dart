import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/app_toast.dart';
import '../../data/models/models.dart';
import '../../providers/media_session_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/liquid_glass.dart';

class DetailMediaPlayer extends ConsumerWidget {
  const DetailMediaPlayer({
    super.key,
    required this.article,
    required this.onExternalOpen,
  });

  final Article article;
  final VoidCallback onExternalOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return article.mediaType == ArticleMediaType.video
        ? _VideoSurface(article: article, onExternalOpen: onExternalOpen)
        : _AudioSurface(article: article, onExternalOpen: onExternalOpen);
  }
}

class _AudioSurface extends ConsumerWidget {
  const _AudioSurface({required this.article, required this.onExternalOpen});

  final Article article;
  final VoidCallback onExternalOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mediaSessionProvider);
    final active = session.article?.id == article.id;
    final state = active ? session : MediaSessionState(article: article);
    final duration =
        state.duration ??
        (article.durationSeconds == null
            ? null
            : Duration(seconds: article.durationSeconds!));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LiquidGlass(
      borderRadius: 22,
      blur: 28,
      opacity: isDark ? 0.09 : 0.56,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
      child: Column(
        children: [
          Row(
            children: [
              _Artwork(article: article, size: 58, radius: 14),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '正在聆听',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              _SpeedButton(
                speed: active ? state.speed : 1,
                onTap: active ? () => _cycleSpeed(ref, state.speed) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressSlider(
            position: state.position,
            duration: duration,
            onChanged: active
                ? (value) => ref
                      .read(mediaSessionProvider.notifier)
                      .seek(Duration(milliseconds: value.round()))
                : null,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: '后退 15 秒',
                onPressed: active
                    ? () => ref
                          .read(mediaSessionProvider.notifier)
                          .skip(const Duration(seconds: -15))
                    : null,
                icon: const Icon(Icons.replay_10_rounded),
              ),
              const SizedBox(width: 14),
              _PrimaryPlayButton(
                loading: state.loading,
                playing: active && state.playing,
                onTap: () => _toggle(ref, article, active),
              ),
              const SizedBox(width: 14),
              IconButton(
                tooltip: '前进 15 秒',
                onPressed: active
                    ? () => ref
                          .read(mediaSessionProvider.notifier)
                          .skip(const Duration(seconds: 15))
                    : null,
                icon: const Icon(Icons.forward_10_rounded),
              ),
            ],
          ),
          if (!article.hasPlayableMedia || state.error != null) ...[
            const SizedBox(height: 8),
            _MediaError(
              message: state.error ?? '未找到音频文件',
              onExternalOpen: onExternalOpen,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, Article article, bool active) async {
    final controller = ref.read(mediaSessionProvider.notifier);
    if (active) {
      await controller.toggle();
    } else {
      await controller.open(article);
    }
  }

  Future<void> _cycleSpeed(WidgetRef ref, double current) async {
    const speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 0.8];
    final index = speeds.indexWhere((value) => (value - current).abs() < 0.01);
    await ref
        .read(mediaSessionProvider.notifier)
        .setSpeed(speeds[(index + 1) % speeds.length]);
  }
}

class _VideoSurface extends ConsumerWidget {
  const _VideoSurface({required this.article, required this.onExternalOpen});

  final Article article;
  final VoidCallback onExternalOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mediaSessionProvider);
    final active = session.article?.id == article.id;
    final controller = active
        ? ref.read(mediaSessionProvider.notifier).videoController
        : null;
    final initialized = controller?.value.isInitialized == true;
    final aspect = initialized
        ? controller!.value.aspectRatio
        : (article.imageAspect == 1 ? 16 / 9 : article.imageAspect).clamp(
            0.8,
            2.1,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (initialized)
                VideoPlayer(controller!)
              else if (article.hasImage)
                AppNetworkImage(url: article.imageUrl!, fit: BoxFit.cover)
              else
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF252525), Color(0xFF050505)],
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.52),
                    ],
                  ),
                ),
              ),
              if (!active || !session.playing)
                Center(
                  child: _PrimaryPlayButton(
                    loading: active && session.loading,
                    playing: false,
                    light: true,
                    onTap: () async {
                      final media = ref.read(mediaSessionProvider.notifier);
                      if (active) {
                        await media.play();
                      } else {
                        await media.open(article);
                      }
                    },
                  ),
                ),
              if (initialized)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _VideoActionButton(
                        tooltip: session.playing ? '暂停' : '播放',
                        icon: session.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: () =>
                            ref.read(mediaSessionProvider.notifier).toggle(),
                      ),
                      const SizedBox(width: 6),
                      _VideoActionButton(
                        tooltip: '小窗播放',
                        icon: Icons.picture_in_picture_alt_rounded,
                        onPressed: () async {
                          final ok = await ref
                              .read(mediaSessionProvider.notifier)
                              .enterVideoPip();
                          if (!ok && context.mounted) {
                            showAppToast('此设备当前不支持小窗播放', context: context);
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      _VideoActionButton(
                        tooltip: '全屏',
                        icon: Icons.fullscreen_rounded,
                        onPressed: () => _openFullscreen(context, ref),
                      ),
                      const SizedBox(width: 6),
                      _VideoActionButton(
                        tooltip: '关闭播放器',
                        icon: Icons.close_rounded,
                        onPressed: () =>
                            ref.read(mediaSessionProvider.notifier).stop(),
                      ),
                    ],
                  ),
                ),
              if (!article.hasPlayableMedia ||
                  (active && session.error != null))
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: _MediaError(
                    message: session.error ?? '未找到视频文件',
                    onExternalOpen: onExternalOpen,
                    dark: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFullscreen(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _FullscreenVideoPage(),
      ),
    );
  }
}

class _VideoActionButton extends StatelessWidget {
  const _VideoActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.42),
        foregroundColor: Colors.white,
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

/// The complete Flutter page is replaced by this widget while Android shows
/// the activity in PiP mode, leaving only the active video surface visible.
class PipVideoSurface extends ConsumerWidget {
  const PipVideoSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mediaSessionProvider.notifier).videoController;
    if (controller?.value.isInitialized != true) {
      return const ColoredBox(color: Colors.black);
    }
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _FullscreenVideoPage extends ConsumerStatefulWidget {
  const _FullscreenVideoPage();

  @override
  ConsumerState<_FullscreenVideoPage> createState() =>
      _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends ConsumerState<_FullscreenVideoPage> {
  var _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaSessionProvider);
    final controller = ref.read(mediaSessionProvider.notifier).videoController;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _controlsVisible = !_controlsVisible),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller?.value.isInitialized == true)
              Center(
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.58),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 12,
                          top: 8,
                          child: IconButton(
                            onPressed: Navigator.of(context).pop,
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        Center(
                          child: _PrimaryPlayButton(
                            playing: state.playing,
                            loading: state.loading,
                            light: true,
                            onTap: () => ref
                                .read(mediaSessionProvider.notifier)
                                .toggle(),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 14,
                          child: _ProgressSlider(
                            position: state.position,
                            duration: state.duration,
                            light: true,
                            onChanged: (value) => ref
                                .read(mediaSessionProvider.notifier)
                                .seek(Duration(milliseconds: value.round())),
                          ),
                        ),
                      ],
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
}

class MiniMediaPlayer extends ConsumerWidget {
  const MiniMediaPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mediaSessionProvider);
    final article = state.article;
    if (article == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LiquidGlass(
        borderRadius: 18,
        blur: 30,
        opacity: isDark ? 0.11 : 0.68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(
                '/article/${Uri.encodeComponent(article.id)}?autoplay=1',
              ),
              child: SizedBox(
                height: 62,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    _Artwork(article: article, size: 46, radius: 12),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${article.mediaType == ArticleMediaType.audio ? '音频' : '视频'} · ${article.source.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(mediaSessionProvider.notifier).toggle(),
                      icon: state.loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              state.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                    ),
                    IconButton(
                      tooltip: '关闭播放器',
                      onPressed: () =>
                          ref.read(mediaSessionProvider.notifier).stop(),
                      icon: const Icon(Icons.close_rounded, size: 19),
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
              ),
            ),
            _ThinProgress(position: state.position, duration: state.duration),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.article,
    required this.size,
    required this.radius,
  });

  final Article article;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: article.hasImage
            ? AppNetworkImage(url: article.imageUrl!, fit: BoxFit.cover)
            : ColoredBox(
                color: isDark ? AppColors.inkSoft : AppColors.wash,
                child: Icon(
                  article.mediaType == ArticleMediaType.audio
                      ? Icons.graphic_eq_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
      ),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({
    required this.playing,
    required this.loading,
    required this.onTap,
    this.light = false,
  });

  final bool playing;
  final bool loading;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = light
        ? Colors.white.withValues(alpha: 0.92)
        : (isDark ? Colors.white : Colors.black);
    final foreground = light
        ? Colors.black
        : (isDark ? Colors.black : Colors.white);
    return Material(
      color: background,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 54,
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(17),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: foreground,
                  ),
                )
              : Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 30,
                  color: foreground,
                ),
        ),
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.speed, required this.onTap});

  final double speed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        minimumSize: Size.zero,
      ),
      child: Text(
        '${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}×',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProgressSlider extends StatelessWidget {
  const _ProgressSlider({
    required this.position,
    required this.duration,
    required this.onChanged,
    this.light = false,
  });

  final Duration position;
  final Duration? duration;
  final ValueChanged<double>? onChanged;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final max = (duration?.inMilliseconds ?? 0).clamp(1, 1 << 53).toDouble();
    final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
    final color = light
        ? Colors.white
        : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black);
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.18),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 2.4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          ),
          child: Slider(value: value, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                _formatDuration(position),
                style: _timeStyle(context, light),
              ),
              const Spacer(),
              Text(
                duration == null ? '--:--' : _formatDuration(duration!),
                style: _timeStyle(context, light),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThinProgress extends StatelessWidget {
  const _ThinProgress({required this.position, required this.duration});

  final Duration position;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final total = duration?.inMilliseconds ?? 0;
    final progress = total <= 0 ? 0.0 : position.inMilliseconds / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 2,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(
          isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError({
    required this.message,
    required this.onExternalOpen,
    this.dark = false,
  });

  final String message;
  final VoidCallback onExternalOpen;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: dark ? Colors.white70 : null,
            ),
          ),
        ),
        TextButton(onPressed: onExternalOpen, child: const Text('外部打开')),
      ],
    );
  }
}

TextStyle? _timeStyle(BuildContext context, bool light) {
  return Theme.of(context).textTheme.labelSmall?.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
    color: light ? Colors.white70 : null,
  );
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
