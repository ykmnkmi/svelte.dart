<script type="text/x-dart">
  import 'dart:async'

  import 'package:svelte/svelte.dart';

  // These values are bound to properties of the video
  var time = state<double>(0);
  var duration = state<double?>(null);
  var paused = state<bool>(true);
  var showControls = state<bool>(true);
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

    if (event.type != 'touchmove' && event.buttons & 1 != 1) {
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
</script>

<h1>Caminandes: Llamigos</h1>
<p>From <a href="https://studio.blender.org/films">Blender Studio</a>. CC-BY</p>

<div>
  <video
    poster="https://sveltejs.github.io/assets/caminandes-llamigos.jpg"
    src="https://sveltejs.github.io/assets/caminandes-llamigos.mp4"
    onmousemove={handleMove}
    ontouchmove={(element, event) {
      event.preventDefault();
      handleMove(element, event);
    }}
    onmousedown={handleMousedown}
    onmouseup={handleMouseup}
    bind:currentTime={time}
    bind:duration
    bind:paused
  >
    <track kind="captions" />
  </video>

  <div class="controls" style="opacity: {duration && showControls() ? 1 : 0}">
    <progress value={time() / duration || 0}></progress>

    <div class="info">
      <span class="time">{format(time())}</span>
      <span>click anywhere to {paused() ? 'play' : 'pause'} / drag to seek</span>
      <span class="time">{format(duration())}</span>
    </div>
  </div>
</div>

<style>
  div {
    position: relative;
  }

  .controls {
    position: absolute;
    top: 0;
    width: 100%;
    transition: opacity 1s;
  }

  .info {
    display: flex;
    width: 100%;
    justify-content: space-between;
  }

  span {
    padding: 0.2em 0.5em;
    color: white;
    text-shadow: 0 0 8px black;
    font-size: 1.4em;
    opacity: 0.7;
  }

  .time {
    width: 3em;
  }

  .time:last-child {
    text-align: right;
  }

  progress {
    display: block;
    width: 100%;
    height: 10px;
    -webkit-appearance: none;
    appearance: none;
  }

  progress::-webkit-progress-bar {
    background-color: rgba(0, 0, 0, 0.2);
  }

  progress::-webkit-progress-value {
    background-color: rgba(255, 255, 255, 0.6);
  }

  video {
    width: 100%;
  }
</style>