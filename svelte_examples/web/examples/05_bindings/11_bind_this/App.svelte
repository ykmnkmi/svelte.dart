<script>
  import 'package:svelte/svelte.dart';

  HTMLCanvasElement? canvas;

  onMount<void Function()>(() {
    var context = canvas!.getContext('2d', CanvasRenderingContext2DSettings(willReadFrequently: true)) as CanvasRenderingContext2D;

    context.getContextAttributes();

    late int frame;

    void loop() {
      frame = window.requestAnimationFrame(loop.toJS);

      var imageData = context.getImageData(0, 0, canvas.width, canvas.height);

      for (var p = 0; p < imageData.data.length; p += 4) {
        var i = p / 4;
        var x = i % canvas!.width;
        var y = (i / canvas!.height).toInt();
        var t = window.performance.now();
        var r = (64 + 128 * x / canvas!.width + 64 * sin(t / 1000)).toInt();
        var g = (64 + 128 * y / canvas!.height + 64 * cos(t / 1400)).toInt();
        var b = 128;

        imageData.data[p + 0] = r;
        imageData.data[p + 1] = g;
        imageData.data[p + 2] = b;
        imageData.data[p + 3] = 255;

        context.putImageData(imageData, 0, 0);
      }
    }

    loop();

    return () {
      window.cancelAnimationFrame(frame);
    };
  });
</script>

<canvas bind:this={canvas} width={32} height={32}></canvas>

<style>
  canvas {
    width: 100%;
    height: 100%;
    background-color: #666;
    -webkit-mask: url(/svelte-logo-mask.svg) 50% 50% no-repeat;
    mask: url(/svelte-logo-mask.svg) 50% 50% no-repeat;
  }
</style>