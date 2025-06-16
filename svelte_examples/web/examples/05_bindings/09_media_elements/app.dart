import 'dart:async';
import 'dart:js_interop';

// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root = $.template<DocumentFragment>(
    '<h1>Caminandes: Llamigos</h1> <p>From <a href="https://studio.blender.org/films">Blender Studio</a>. CC-BY</p> <div class="svelte-11bzk4c"><video poster="https://sveltejs.github.io/assets/caminandes-llamigos.jpg" src="https://sveltejs.github.io/assets/caminandes-llamigos.mp4" class="svelte-11bzk4c"><track kind="captions"></video> <div class="controls svelte-11bzk4c"><progress class="svelte-11bzk4c"></progress> <div class="info svelte-11bzk4c"><span class="time svelte-11bzk4c"> </span> <span class="svelte-11bzk4c"> </span> <span class="time svelte-11bzk4c"> </span></div></div></div>',
    1,
  );

  @override
  void create(Node anchor) {
    $.push();
    $.appendStyles(anchor, 'svelte-11bzk4c', '''
  div.svelte-11bzk4c {
    position: relative;
  }

  .controls.svelte-11bzk4c {
    position: absolute;
    top: 0;
    width: 100%;
    transition: opacity 1s;
  }

  .info.svelte-11bzk4c {
    display: flex;
    width: 100%;
    justify-content: space-between;
  }

  span.svelte-11bzk4c {
    padding: 0.2em 0.5em;
    color: white;
    text-shadow: 0 0 8px black;
    font-size: 1.4em;
    opacity: 0.7;
  }

  .time.svelte-11bzk4c {
    width:3em;
  }

  .time.svelte-11bzk4c:last-child {
    text-align:right;
  }

  progress.svelte-11bzk4c {
    display:block;
    width:100%;
    height:10px;
    -webkit-appearance:none;
    appearance:none;
  }

  progress.svelte-11bzk4c::-webkit-progress-bar {
    background-color:rgba(0, 0, 0, 0.2);
  }

  progress.svelte-11bzk4c::-webkit-progress-value {
    background-color:rgba(255, 255, 255, 0.6);
  }

  video.svelte-11bzk4c {
    width:100%;
  }''');

    // These values are bound to properties of the video
    var time = $.source<double>(0);
    var duration = $.source<double?>(null);
    var paused = $.source<bool>(true);
    var showControls = $.source<bool>(true);
    Timer? showControlsTimer;
    // Used to track time of last mouse down event
    DateTime? lastMouseDown;

    void handleMove(HTMLElement element, MouseEvent event) {
      // Make the controls visible, but fade out after 2.5 seconds of
      // inactivity.
      showControlsTimer?.cancel();

      showControlsTimer = Timer(const Duration(milliseconds: 2500), () {
        showControls.set(false);
        showControlsTimer = null;
      });

      showControls.set(true);

      if (duration() == null) {
        // Video not loaded yet.
        return;
      }

      if (event.type != 'touchmove' && !(event.buttons & 1 == 1)) {
        // Mouse not down.
        return;
      }

      var clientX = event.type == 'touchmove'
          ? (event as TouchEvent).touches.item(0)!.clientX
          : event.clientX.toDouble();

      var rect = element.getBoundingClientRect();
      var left = rect.left;
      var right = rect.right;
      time.set(duration()! * (clientX - left) / (right - left));
    }

    // We can't rely on the built-in click event, because it fires
    // after a drag — we have to listen for clicks ourselves.
    void handleMouseDown(MouseEvent event) {
      lastMouseDown = DateTime.now();
    }

    void handleMouseUp(MouseEvent event) {
      if (DateTime.now().difference(lastMouseDown!) <
          Duration(milliseconds: 300)) {
        var video = event.target as HTMLVideoElement;

        if (paused()) {
          video.play();
        } else {
          video.pause();
        }
      }
    }

    String format(double? time) {
      if (time == null || time.isNaN || time.isInfinite) {
        return '...';
      }

      var minutes = (time / 60).floor();
      var seconds = (time % 60).floor();
      return '$minutes:${seconds < 10 ? '0$seconds' : seconds}';
    }

    var fragment = root();
    var div = $.sibling<HTMLDivElement>($.firstChild(fragment), 4);
    var video = $.child<HTMLVideoElement>(div);
    var div1 = $.sibling<HTMLDivElement>(video, 2);
    var progress = $.child<HTMLProgressElement>(div1);
    var div2 = $.sibling<HTMLDivElement>(progress, 2);
    var span = $.child<HTMLSpanElement>(div2);
    var text = $.child<Text>(span);

    $.templateEffect(() {
      $.setText(text, format(time()));
    });

    $.reset(span);

    var span1 = $.sibling<HTMLSpanElement>(span, 2);
    var text1 = $.child<Text>(span1);

    $.reset(span1);

    var span2 = $.sibling<HTMLSpanElement>(span1, 2);
    var text2 = $.child<Text>(span2, true);

    $.templateEffect(() {
      $.setText(text2, format(duration()));
    });

    $.reset(span2);
    $.reset(div2);
    $.reset(div1);
    $.reset(div);

    $.templateEffect(() {
      $.setAttribute(
        div1,
        'style',
        'opacity: ${duration() != null && showControls() ? 1 : 0}',
      );
      $.setElementValue(
        progress,
        duration() == null ? 0 : time() / duration()!,
      );
      $.setText(
        text1,
        'click anywhere to ${paused() ? 'play' : 'pause'} / drag to seek',
      );
    });

    $.event2<HTMLElement, MouseEvent>('mousemove', video, handleMove);

    $.event2<HTMLElement, MouseEvent>('touchmove', video, (element, event) {
      event.preventDefault();
      handleMove(element, event);
    });

    $.event('mousedown', video, handleMouseDown);
    $.event('mouseup', video, handleMouseUp);

    $.bindCurrentTime(video, time.call, time.set);

    $.bindProperty<JSNumber>('duration', 'durationchange', video, (value) {
      duration.set(value.toDartDouble);
    });

    $.bindPaused(video, paused.call, paused.set);
    $.append(anchor, fragment);
    $.pop();
  }
}
