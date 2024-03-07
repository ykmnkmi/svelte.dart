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
        printToConsole("WebAssembly.String is undefined, adding polyfill");
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

  _113: (x0,x1) => x0.querySelector(x1),
_114: (x0,x1) => x0.querySelector(x1),
_115: f => finalizeWrapper(f,x0 => dartInstance.exports._115(f,x0)),
_116: (x0,x1,x2) => x0.addEventListener(x1,x2),
_121: (x0,x1) => x0.alert(x1),
_143: (x0,x1) => globalThis.$$.template(x0,x1),
_144: x0 => globalThis.$$.template(x0),
_145: (x0,x1,x2) => globalThis.$$.open(x0,x1,x2),
_146: (x0,x1,x2) => globalThis.$$.open_frag(x0,x1,x2),
_147: x0 => globalThis.$$.space(x0),
_148: x0 => globalThis.$$.comment(x0),
_149: (x0,x1) => globalThis.$$.close(x0,x1),
_150: (x0,x1) => globalThis.$$.close_frag(x0,x1),
_152: f => finalizeWrapper(f,x0 => dartInstance.exports._152(f,x0)),
_153: (x0,x1,x2,x3) => globalThis.$$.event(x0,x1,x2,x3),
_155: (x0,x1) => globalThis.$$.text_effect(x0,x1),
_156: f => finalizeWrapper(f,() => dartInstance.exports._156(f)),
_157: (x0,x1) => globalThis.$$.text(x0,x1),
_158: (x0,x1,x2) => globalThis.$$.html(x0,x1,x2),
_159: f => finalizeWrapper(f,() => dartInstance.exports._159(f)),
_160: (x0,x1,x2) => globalThis.$$.attr(x0,x1,x2),
_161: (x0,x1) => globalThis.$$.attr(x0,x1),
_163: x0 => globalThis.$$.spread_props(x0),
_164: x0 => ({target: x0}),
_167: (x0,x1) => globalThis.$$.mount(x0,x1),
_168: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._168(f,x0,x1)),
_169: x0 => globalThis.$$.unmount(x0),
_171: (x0,x1,x2) => globalThis.$$.prop(x0,x1,x2),
_172: () => globalThis.$$.init(),
_119: x0 => ({answer: x0}),
_120: x0 => x0.answer,
_117: x0 => ({answer: x0}),
_108: (x0,x1,x2,x3) => ({name: x0,version: x1,speed: x2,website: x3}),
_109: x0 => x0.name,
_110: x0 => x0.version,
_111: x0 => x0.speed,
_112: x0 => x0.website,
_7216: () => globalThis.document,
_1645: x0 => x0.value,
_2243: () => globalThis.window,
_126: (x0,x1,x2) => x0[x1] = x2,
_127: (x0,x1,x2,x3,x4) => globalThis.$$.each_indexed(x0,x1,x2,x3,x4),
_128: f => finalizeWrapper(f,() => dartInstance.exports._128(f)),
_129: f => finalizeWrapper(f,(x0,x1,x2) => dartInstance.exports._129(f,x0,x1,x2)),
_122: (x0,x1,x2,x3) => globalThis.$$.if_block(x0,x1,x2,x3),
_123: f => finalizeWrapper(f,() => dartInstance.exports._123(f)),
_124: f => finalizeWrapper(f,x0 => dartInstance.exports._124(f,x0)),
_125: f => finalizeWrapper(f,x0 => dartInstance.exports._125(f,x0)),
_103: x0 => globalThis.$$.child(x0),
_105: x0 => globalThis.$$.child_frag(x0),
_106: (x0,x1) => globalThis.$$.sibling(x0,x1),
_107: x0 => globalThis.$$.sibling(x0),
_354: x0 => globalThis.$$.pre_effect(x0),
_355: f => finalizeWrapper(f,() => dartInstance.exports._355(f)),
_356: x0 => globalThis.$$.render_effect(x0),
_357: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._357(f,x0,x1)),
_353: x0 => globalThis.$$.mutable_source(x0),
_343: x0 => globalThis.$$.get(x0),
_344: (x0,x1) => globalThis.$$.set(x0,x1),
_345: (x0,x1) => globalThis.$$.mutate(x0,x1),
_346: x0 => globalThis.$$.untrack(x0),
_347: f => finalizeWrapper(f,() => dartInstance.exports._347(f)),
_348: (x0,x1) => globalThis.$$.push(x0,x1),
_351: () => globalThis.$$.pop(),
_352: x0 => globalThis.$$.unwrap(x0),
_72: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
_73: s => printToConsole(stringFromDartString(s)),
_264: o => o === undefined,
_265: o => typeof o === 'boolean',
_266: o => typeof o === 'number',
_268: o => typeof o === 'string',
_271: o => o instanceof Int8Array,
_272: o => o instanceof Uint8Array,
_273: o => o instanceof Uint8ClampedArray,
_274: o => o instanceof Int16Array,
_275: o => o instanceof Uint16Array,
_276: o => o instanceof Int32Array,
_277: o => o instanceof Uint32Array,
_278: o => o instanceof Float32Array,
_279: o => o instanceof Float64Array,
_280: o => o instanceof ArrayBuffer,
_281: o => o instanceof DataView,
_282: o => o instanceof Array,
_283: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_287: (l, r) => l === r,
_288: o => o,
_289: o => o,
_290: o => o,
_291: b => !!b,
_292: o => o.length,
_295: (o, i) => o[i],
_296: f => f.dartFunction,
_297: l => arrayFromDartList(Int8Array, l),
_298: l => arrayFromDartList(Uint8Array, l),
_299: l => arrayFromDartList(Uint8ClampedArray, l),
_300: l => arrayFromDartList(Int16Array, l),
_301: l => arrayFromDartList(Uint16Array, l),
_302: l => arrayFromDartList(Int32Array, l),
_303: l => arrayFromDartList(Uint32Array, l),
_304: l => arrayFromDartList(Float32Array, l),
_305: l => arrayFromDartList(Float64Array, l),
_306: (data, length) => {
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
          }
          return view;
        },
_307: l => arrayFromDartList(Array, l),
_308: stringFromDartString,
_309: stringToDartString,
_310: () => ({}),
_316: (o, p) => o[p],
_312: l => new Array(l),
_320: o => String(o),
_223: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_173: (a, i) => a.push(i),
_184: a => a.length,
_186: (a, i) => a[i],
_187: (a, i, v) => a[i] = v,
_189: a => a.join(''),
_199: (s, p, i) => s.indexOf(p, i),
_202: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_203: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_204: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_205: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_206: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_207: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_208: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_211: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_212: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_214: WebAssembly.String.charCodeAt,
_217: WebAssembly.String.length,
_218: WebAssembly.String.equals,
_219: WebAssembly.String.compare,
_220: WebAssembly.String.fromCharCode,
_227: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_228: (b, o) => new DataView(b, o),
_230: Function.prototype.call.bind(DataView.prototype.getUint8),
_232: Function.prototype.call.bind(DataView.prototype.getInt8),
_234: Function.prototype.call.bind(DataView.prototype.getUint16),
_236: Function.prototype.call.bind(DataView.prototype.getInt16),
_238: Function.prototype.call.bind(DataView.prototype.getUint32),
_240: Function.prototype.call.bind(DataView.prototype.getInt32),
_246: Function.prototype.call.bind(DataView.prototype.getFloat32),
_248: Function.prototype.call.bind(DataView.prototype.getFloat64),
_83: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_11: x0 => new Array(x0),
_16: (o,s) => o[s],
_17: (o,s,v) => o[s] = v,
_20: (x0,x1,x2) => x0.call(x1,x2),
_44: () => Symbol("jsBoxedDartObjectProperty"),
_341: (o, p, v) => o[p] = v,
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

