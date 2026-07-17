import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../data/models/models.dart';

final mediaSessionProvider =
    NotifierProvider<MediaSessionController, MediaSessionState>(
      MediaSessionController.new,
    );

class MediaSessionState {
  const MediaSessionState({
    this.article,
    this.position = Duration.zero,
    this.duration,
    this.playing = false,
    this.loading = false,
    this.speed = 1,
    this.error,
  });

  final Article? article;
  final Duration position;
  final Duration? duration;
  final bool playing;
  final bool loading;
  final double speed;
  final String? error;

  bool get hasSession => article != null;
  bool get isAudio => article?.mediaType == ArticleMediaType.audio;
  bool get isVideo => article?.mediaType == ArticleMediaType.video;

  MediaSessionState copyWith({
    Article? article,
    Duration? position,
    Duration? duration,
    bool? playing,
    bool? loading,
    double? speed,
    String? error,
    bool clearArticle = false,
    bool clearDuration = false,
    bool clearError = false,
  }) {
    return MediaSessionState(
      article: clearArticle ? null : (article ?? this.article),
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
      playing: playing ?? this.playing,
      loading: loading ?? this.loading,
      speed: speed ?? this.speed,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MediaSessionController extends Notifier<MediaSessionState> {
  final AudioPlayer _audio = AudioPlayer();
  VideoPlayerController? _video;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  VideoPlayerController? get videoController => _video;

  @override
  MediaSessionState build() {
    _subscriptions.add(
      _audio.positionStream.listen((position) {
        if (state.isAudio) state = state.copyWith(position: position);
      }),
    );
    _subscriptions.add(
      _audio.durationStream.listen((duration) {
        if (state.isAudio) {
          state = duration == null
              ? state.copyWith(clearDuration: true)
              : state.copyWith(duration: duration);
        }
      }),
    );
    _subscriptions.add(
      _audio.playerStateStream.listen((playerState) {
        if (!state.isAudio) return;
        final loading =
            playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering;
        state = state.copyWith(playing: playerState.playing, loading: loading);
      }),
    );
    ref.onDispose(() {
      for (final subscription in _subscriptions) {
        unawaited(subscription.cancel());
      }
      unawaited(_audio.dispose());
      unawaited(_video?.dispose());
    });
    return const MediaSessionState();
  }

  Future<void> open(Article article, {bool autoplay = true}) async {
    if (!article.hasPlayableMedia) {
      state = MediaSessionState(article: article, error: '未找到可播放的媒体文件');
      return;
    }
    if (state.article?.id == article.id && state.error == null) {
      if (autoplay && !state.playing) await play();
      return;
    }

    await _audio.stop();
    await _disposeVideo();
    state = MediaSessionState(
      article: article,
      loading: true,
      duration: article.durationSeconds == null
          ? null
          : Duration(seconds: article.durationSeconds!),
    );

    try {
      if (article.mediaType == ArticleMediaType.audio) {
        await _openAudio(article, autoplay: autoplay);
      } else {
        await _openVideo(article, autoplay: autoplay);
      }
    } catch (_) {
      state = state.copyWith(
        playing: false,
        loading: false,
        error: '媒体加载失败，可尝试外部打开',
      );
    }
  }

  Future<void> _openAudio(Article article, {required bool autoplay}) async {
    final artUri = Uri.tryParse(article.imageUrl ?? '');
    await _audio.setAudioSource(
      AudioSource.uri(
        Uri.parse(article.enclosureUrl!),
        tag: MediaItem(
          id: article.id,
          title: article.title,
          album: article.source.name,
          artUri: artUri?.hasScheme == true ? artUri : null,
          duration: article.durationSeconds == null
              ? null
              : Duration(seconds: article.durationSeconds!),
        ),
      ),
    );
    state = state.copyWith(
      duration: _audio.duration,
      loading: false,
      clearError: true,
    );
    if (autoplay) await _audio.play();
  }

  Future<void> _openVideo(Article article, {required bool autoplay}) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(article.enclosureUrl!),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    _video = controller;
    await controller.initialize();
    controller.addListener(_syncVideoState);
    state = state.copyWith(
      duration: controller.value.duration,
      loading: false,
      clearError: true,
    );
    if (autoplay) await controller.play();
  }

  void _syncVideoState() {
    final value = _video?.value;
    if (value == null || !state.isVideo) return;
    state = state.copyWith(
      position: value.position,
      duration: value.duration,
      playing: value.isPlaying,
      loading: value.isBuffering,
      error: value.hasError ? '视频播放失败，可尝试外部打开' : null,
      clearError: !value.hasError,
    );
  }

  Future<void> play() async {
    if (state.isAudio) {
      await _audio.play();
    } else {
      await _video?.play();
    }
  }

  Future<void> pause() async {
    if (state.isAudio) {
      await _audio.pause();
    } else {
      await _video?.pause();
    }
  }

  Future<void> toggle() => state.playing ? pause() : play();

  Future<void> seek(Duration position) async {
    final duration = state.duration;
    final maxMs = duration?.inMilliseconds ?? position.inMilliseconds;
    final clamped = Duration(
      milliseconds: position.inMilliseconds.clamp(0, maxMs),
    );
    if (state.isAudio) {
      await _audio.seek(clamped);
    } else {
      await _video?.seekTo(clamped);
    }
  }

  Future<void> skip(Duration offset) => seek(state.position + offset);

  Future<void> setSpeed(double speed) async {
    final normalized = speed.clamp(0.8, 2.0);
    if (state.isAudio) await _audio.setSpeed(normalized);
    state = state.copyWith(speed: normalized);
  }

  Future<void> stop() async {
    await _audio.stop();
    await _disposeVideo();
    state = const MediaSessionState();
  }

  Future<void> _disposeVideo() async {
    final video = _video;
    _video = null;
    if (video == null) return;
    video.removeListener(_syncVideoState);
    await video.dispose();
  }
}
