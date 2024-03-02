  let buildArgsList;

// `modulePromise` is a promise to the `WebAssembly.module` object to be
//   instantiated.
// `importObjectPromise` is a promise to an object that contains any additional
//   imports needed by the module that aren't provided by the standard runtime.
//   The fields on this object will be merged into the importObject with which
//   the module will be instantiated.
// This function returns a promise to the instantiated module.
export const instantiate = async (modulePromise, importObjectPromise) => {
    let dartInstance;

      function stringFromDartString(string) {
        const totalLength = dartInstance.exports.$stringLength(string);
        let result = '';
        let index = 0;
        while (index < totalLength) {
          let chunkLength = Math.min(totalLength - index, 0xFFFF);
          const array = new Array(chunkLength);
          for (let i = 0; i < chunkLength; i++) {
              array[i] = dartInstance.exports.$stringRead(string, index++);
          }
          result += String.fromCharCode(...array);
        }
        return result;
    }

    function stringToDartString(string) {
        const length = string.length;
        let range = 0;
        for (let i = 0; i < length; i++) {
            range |= string.codePointAt(i);
        }
        if (range < 256) {
            const dartString = dartInstance.exports.$stringAllocate1(length);
            for (let i = 0; i < length; i++) {
                dartInstance.exports.$stringWrite1(dartString, i, string.codePointAt(i));
            }
            return dartString;
        } else {
            const dartString = dartInstance.exports.$stringAllocate2(length);
            for (let i = 0; i < length; i++) {
                dartInstance.exports.$stringWrite2(dartString, i, string.charCodeAt(i));
            }
            return dartString;
        }
    }

      // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
        const length = dartInstance.exports.$listLength(list);
        const array = new constructor(length);
        for (let i = 0; i < length; i++) {
            array[i] = dartInstance.exports.$listRead(list, i);
        }
        return array;
    }

    buildArgsList = function(list) {
        const dartList = dartInstance.exports.$makeStringList();
        for (let i = 0; i < list.length; i++) {
            dartInstance.exports.$listAdd(dartList, stringToDartString(list[i]));
        }
        return dartList;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
        wrapped.dartFunction = dartFunction;
        wrapped[jsWrappedDartFunctionSymbol] = true;
        return wrapped;
    }

    if (WebAssembly.String === undefined) {
        WebAssembly.String = {
            "charCodeAt": (s, i) => s.charCodeAt(i),
            "compare": (s1, s2) => {
                if (s1 < s2) return -1;
                if (s1 > s2) return 1;
                return 0;
            },
            "concat": (s1, s2) => s1 + s2,
            "equals": (s1, s2) => s1 === s2,
            "fromCharCode": (i) => String.fromCharCode(i),
            "length": (s) => s.length,
            "substring": (s, a, b) => s.substring(a, b),
        };
    }

    // Imports
    const dart2wasm = {

  _121: (x0,x1) => x0.querySelector(x1),
_122: (x0,x1) => x0.querySelector(x1),
_123: f => finalizeWrapper(f,x0 => dartInstance.exports._123(f,x0)),
_124: (x0,x1,x2) => x0.addEventListener(x1,x2),
_129: (x0,x1) => x0.alert(x1),
_142: (x0,x1) => globalThis.$$.template(x0,x1),
_143: x0 => globalThis.$$.template(x0),
_144: (x0,x1,x2) => globalThis.$$.open(x0,x1,x2),
_145: (x0,x1,x2) => globalThis.$$.open_frag(x0,x1,x2),
_146: x0 => globalThis.$$.space(x0),
_147: x0 => globalThis.$$.comment(x0),
_148: (x0,x1) => globalThis.$$.close(x0,x1),
_149: (x0,x1) => globalThis.$$.close_frag(x0,x1),
_151: f => finalizeWrapper(f,x0 => dartInstance.exports._151(f,x0)),
_152: (x0,x1,x2,x3) => globalThis.$$.event(x0,x1,x2,x3),
_154: (x0,x1) => globalThis.$$.text_effect(x0,x1),
_155: f => finalizeWrapper(f,() => dartInstance.exports._155(f)),
_156: (x0,x1) => globalThis.$$.text(x0,x1),
_157: (x0,x1,x2) => globalThis.$$.html(x0,x1,x2),
_158: f => finalizeWrapper(f,() => dartInstance.exports._158(f)),
_159: (x0,x1,x2) => globalThis.$$.attr(x0,x1,x2),
_160: (x0,x1) => globalThis.$$.attr(x0,x1),
_162: x0 => globalThis.$$.spread_props(x0),
_163: x0 => ({target: x0}),
_166: (x0,x1) => globalThis.$$.mount(x0,x1),
_167: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._167(f,x0,x1)),
_169: x0 => globalThis.$$.unmount(x0),
_127: x0 => ({answer: x0}),
_128: x0 => x0.answer,
_125: x0 => ({answer: x0}),
_116: (x0,x1,x2,x3) => ({name: x0,version: x1,speed: x2,website: x3}),
_117: x0 => x0.name,
_118: x0 => x0.version,
_119: x0 => x0.speed,
_120: x0 => x0.website,
_7213: () => globalThis.document,
_1642: x0 => x0.value,
_2240: () => globalThis.window,
_111: x0 => globalThis.$$.child(x0),
_113: x0 => globalThis.$$.child_frag(x0),
_114: (x0,x1) => globalThis.$$.sibling(x0,x1),
_115: x0 => globalThis.$$.sibling(x0),
_351: x0 => globalThis.$$.pre_effect(x0),
_352: f => finalizeWrapper(f,() => dartInstance.exports._352(f)),
_353: x0 => globalThis.$$.render_effect(x0),
_354: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._354(f,x0,x1)),
_350: x0 => globalThis.$$.mutable_source(x0),
_340: x0 => globalThis.$$.get(x0),
_341: (x0,x1) => globalThis.$$.set(x0,x1),
_342: x0 => globalThis.$$.untrack(x0),
_343: f => finalizeWrapper(f,() => dartInstance.exports._343(f)),
_344: (x0,x1) => globalThis.$$.push(x0,x1),
_347: () => globalThis.$$.pop(),
_348: (x0,x1,x2) => globalThis.$$.prop(x0,x1,x2),
_349: () => globalThis.$$.init(),
_72: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
_73: s => printToConsole(stringFromDartString(s)),
_261: o => o === undefined,
_262: o => typeof o === 'boolean',
_263: o => typeof o === 'number',
_265: o => typeof o === 'string',
_268: o => o instanceof Int8Array,
_269: o => o instanceof Uint8Array,
_270: o => o instanceof Uint8ClampedArray,
_271: o => o instanceof Int16Array,
_272: o => o instanceof Uint16Array,
_273: o => o instanceof Int32Array,
_274: o => o instanceof Uint32Array,
_275: o => o instanceof Float32Array,
_276: o => o instanceof Float64Array,
_277: o => o instanceof ArrayBuffer,
_278: o => o instanceof DataView,
_279: o => o instanceof Array,
_280: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_284: (l, r) => l === r,
_285: o => o,
_286: o => o,
_287: o => o,
_288: b => !!b,
_289: o => o.length,
_292: (o, i) => o[i],
_293: f => f.dartFunction,
_294: l => arrayFromDartList(Int8Array, l),
_295: l => arrayFromDartList(Uint8Array, l),
_296: l => arrayFromDartList(Uint8ClampedArray, l),
_297: l => arrayFromDartList(Int16Array, l),
_298: l => arrayFromDartList(Uint16Array, l),
_299: l => arrayFromDartList(Int32Array, l),
_300: l => arrayFromDartList(Uint32Array, l),
_301: l => arrayFromDartList(Float32Array, l),
_302: l => arrayFromDartList(Float64Array, l),
_303: (data, length) => {
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
          }
          return view;
        },
_304: l => arrayFromDartList(Array, l),
_305: stringFromDartString,
_306: stringToDartString,
_307: () => ({}),
_313: (o, p) => o[p],
_309: l => new Array(l),
_317: o => String(o),
_220: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_170: (a, i) => a.push(i),
_181: a => a.length,
_183: (a, i) => a[i],
_184: (a, i, v) => a[i] = v,
_186: a => a.join(''),
_196: (s, p, i) => s.indexOf(p, i),
_199: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_200: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_201: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_202: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_203: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_204: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_205: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_208: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_209: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_211: WebAssembly.String.charCodeAt,
_214: WebAssembly.String.length,
_215: WebAssembly.String.equals,
_216: WebAssembly.String.compare,
_217: WebAssembly.String.fromCharCode,
_224: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_225: (b, o) => new DataView(b, o),
_227: Function.prototype.call.bind(DataView.prototype.getUint8),
_229: Function.prototype.call.bind(DataView.prototype.getInt8),
_231: Function.prototype.call.bind(DataView.prototype.getUint16),
_233: Function.prototype.call.bind(DataView.prototype.getInt16),
_235: Function.prototype.call.bind(DataView.prototype.getUint32),
_237: Function.prototype.call.bind(DataView.prototype.getInt32),
_243: Function.prototype.call.bind(DataView.prototype.getFloat32),
_245: Function.prototype.call.bind(DataView.prototype.getFloat64),
_91: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_16: (o,s) => o[s],
_17: (o,s,v) => o[s] = v,
_20: (x0,x1,x2) => x0.call(x1,x2),
_44: () => Symbol("jsBoxedDartObjectProperty"),
_338: (o, p, v) => o[p] = v,
_48: v => stringToDartString(v.toString()),
_63: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        }
      };

    const baseImports = {
        dart2wasm: dart2wasm,

  
          Math: Math,
        Date: Date,
        Object: Object,
        Array: Array,
        Reflect: Reflect,
    };
    dartInstance = await WebAssembly.instantiate(await modulePromise, {
        ...baseImports,
        ...(await importObjectPromise),
    });

    return dartInstance;
}

// Call the main function for the instantiated module
// `moduleInstance` is the instantiated dart2wasm module
// `args` are any arguments that should be passed into the main function.
export const invoke = (moduleInstance, ...args) => {
    const dartMain = moduleInstance.exports.$getMain();
    const dartArgs = buildArgsList(args);
    moduleInstance.exports.$invokeMain(dartMain, dartArgs);
}

