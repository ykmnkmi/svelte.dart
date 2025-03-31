import 'dart:js_interop';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:web/web.dart';

void bindCurrentTime(
  HTMLMediaElement media,
  double Function() get,
  void Function(double currentTime) set,
) {
  late int handle;
  double? value;

  late JSExportedDartFunction jsCallback;

  // Ideally, listening to `timeupdate` would be enough, but it fires too
  // infrequently for the `currentTime` binding, which is why we use a
  // `requestAnimationFrame` loop, too. We additionally still listen to
  // `timeupdate` because the user could be scrubbing through the video using
  // the native controls when the media is paused.
  void callback() {
    window.cancelAnimationFrame(handle);

    if (!media.paused) {
      handle = window.requestAnimationFrame(jsCallback);
    }

    double nextValue = media.currentTime;

    if (value != nextValue) {
      set(value = nextValue);
    }
  }

  jsCallback = callback.toJS;
  handle = window.requestAnimationFrame(jsCallback);
  media.addEventListener('timeupdate', jsCallback);

  renderEffect<void>(() {
    double nextValue = get();

    if (value != nextValue && !nextValue.isNaN) {
      value = nextValue;
      media.currentTime = nextValue;
    }
  });

  teardown<void>(() {
    window.cancelAnimationFrame(handle);
  });
}

void bindBuffered(
  HTMLMediaElement media,
  void Function(TimeRanges buffered) set,
) {
  listen(media, <String>['loadedmetadata', 'progress'], () {
    set(media.buffered);
  });
}

void bindSeekable(
  HTMLMediaElement media,
  void Function(TimeRanges seekable) set,
) {
  listen(media, <String>['loadedmetadata'], () {
    set(media.seekable);
  });
}

void bindPlayed(HTMLMediaElement media, void Function(TimeRanges played) set) {
  listen(media, <String>['timeupdate'], () {
    set(media.played);
  });
}

void bindSeeking(HTMLMediaElement media, void Function(bool seeking) set) {
  listen(media, <String>['seeking', 'seeked'], () {
    set(media.seeking);
  });
}

void bindEnded(HTMLMediaElement media, void Function(bool ended) set) {
  listen(media, <String>['timeupdate', 'ended'], () {
    set(media.ended);
  });
}

void bindReadyState(HTMLMediaElement media, void Function(int readyState) set) {
  listen(
    media,
    <String>[
      'loadedmetadata',
      'loadeddata',
      'canplay',
      'canplaythrought',
      'playing',
      'waiting',
      'emptied',
    ],
    () {
      set(media.readyState);
    },
  );
}

void bindPlaybackRate(
  HTMLMediaElement media,
  double? Function() get,
  void Function(double playbackRate) set,
) {
  // Needs to happen after element is inserted into the DOM (which is guaranteed
  // by using effect), else playback will be set back to 1 by the browser.
  effect<void>(() {
    double value = get() ?? 0.0;

    if (value != media.playbackRate && !value.isNaN) {
      media.playbackRate = value;
    }
  });

  // Start listening to `ratechange` events after the element is inserted into
  // the DOM, else playback will be set to 1 by the browser.
  effect<void>(() {
    listen(media, <String>['ratechange'], () {
      set(media.playbackRate);
    });
  });
}

void bindPaused(
  HTMLMediaElement media,
  bool? Function() get,
  void Function(bool paused) set,
) {
  bool? paused = get();

  void update() {
    if (paused != media.paused) {
      set(paused = media.paused);
    }
  }

  // If someone switches the `src` while media is playing, the player will
  // pause. Listen to the `canplay` event to get notified of this situation.
  listen(media, ['play', 'pause', 'canplay'], update, paused == null);

  // Needs to be an effect to ensure media element is mounted: else, if paused
  // is `false` (i.e. should play right away) a "The play() request was
  // interrupted by a new load request" error would be thrown because the
  // resource isn't loaded yet.
  effect<void>(() {
    paused = get();

    if (paused != media.paused) {
      if (paused == true) {
        media.pause();
      } else {
        void onRejected() {
          set(paused = true);
        }

        media.play().catchError(onRejected.toJS);
      }
    }
  });
}

void bindVolume(
  HTMLMediaElement media,
  double? Function() get,
  void Function(double volume) set,
) {
  void callback() {
    set(media.volume);
  }

  if (get() == null) {
    callback();
  }

  listen(media, <String>['volumechange'], callback, false);

  renderEffect<void>(() {
    double value = get() ?? 0.0;

    if (value != media.volume && !value.isNaN) {
      media.volume = value;
    }
  });
}

void bindMuted(
  HTMLMediaElement media,
  bool? Function() get,
  void Function(bool muted) set,
) {
  void callback() {
    set(media.muted);
  }

  if (get() == null) {
    callback();
  }

  listen(media, <String>['volumechange'], callback, false);

  renderEffect<void>(() {
    bool value = get() == true;

    if (value != media.muted) {
      media.muted = value;
    }
  });
}

extension on JSPromise<JSAny?> {
  @JS('catch')
  external void catchError(JSFunction onRejected);
}
