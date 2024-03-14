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

  _106: (x0,x1) => x0.querySelector(x1),
_107: (x0,x1) => x0.querySelector(x1),
_108: f => finalizeWrapper(f,x0 => dartInstance.exports._108(f,x0)),
_109: (x0,x1,x2) => x0.addEventListener(x1,x2),
_120: (x0,x1) => x0.alert(x1),
_105: () => ({}),
_118: x0 => ({answer: x0}),
_119: x0 => x0.answer,
_116: x0 => ({answer: x0}),
_111: (x0,x1,x2,x3) => ({name: x0,version: x1,speed: x2,website: x3}),
_112: x0 => x0.name,
_113: x0 => x0.version,
_114: x0 => x0.speed,
_115: x0 => x0.website,
_104: x0 => x0.current,
_173: (x0,x1,x2) => x0[x1] = x2,
_174: (x0,x1,x2,x3,x4,x5) => globalThis.$$.each_keyed(x0,x1,x2,x3,x4,x5),
_175: f => finalizeWrapper(f,() => dartInstance.exports._175(f)),
_176: f => finalizeWrapper(f,(x0,x1,x2) => dartInstance.exports._176(f,x0,x1,x2)),
_177: f => finalizeWrapper(f,(x0,x1,x2) => dartInstance.exports._177(f,x0,x1,x2)),
_179: (x0,x1,x2,x3,x4) => globalThis.$$.each_indexed(x0,x1,x2,x3,x4),
_180: f => finalizeWrapper(f,() => dartInstance.exports._180(f)),
_181: f => finalizeWrapper(f,(x0,x1,x2) => dartInstance.exports._181(f,x0,x1,x2)),
_169: (x0,x1,x2,x3) => globalThis.$$.if_block(x0,x1,x2,x3),
_170: f => finalizeWrapper(f,() => dartInstance.exports._170(f)),
_171: f => finalizeWrapper(f,x0 => dartInstance.exports._171(f,x0)),
_172: f => finalizeWrapper(f,x0 => dartInstance.exports._172(f,x0)),
_368: (x0,x1,x2) => globalThis.$$.set_getter(x0,x1,x2),
_369: f => finalizeWrapper(f,() => dartInstance.exports._369(f)),
_164: x0 => globalThis.$$.child(x0),
_165: (x0,x1) => globalThis.$$.child_frag(x0,x1),
_166: x0 => globalThis.$$.child_frag(x0),
_167: (x0,x1) => globalThis.$$.sibling(x0,x1),
_168: x0 => globalThis.$$.sibling(x0),
_194: x0 => globalThis.$$.pre_effect(x0),
_195: f => finalizeWrapper(f,() => dartInstance.exports._195(f)),
_196: x0 => globalThis.$$.render_effect(x0),
_197: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._197(f,x0,x1)),
_193: x0 => globalThis.$$.mutable_source(x0),
_133: (x0,x1) => globalThis.$$.template(x0,x1),
_134: x0 => globalThis.$$.template(x0),
_135: (x0,x1,x2) => globalThis.$$.open(x0,x1,x2),
_136: (x0,x1,x2) => globalThis.$$.open_frag(x0,x1,x2),
_137: x0 => globalThis.$$.space(x0),
_138: x0 => globalThis.$$.comment(x0),
_139: (x0,x1) => globalThis.$$.close(x0,x1),
_140: (x0,x1) => globalThis.$$.close_frag(x0,x1),
_142: f => finalizeWrapper(f,x0 => dartInstance.exports._142(f,x0)),
_143: (x0,x1,x2,x3) => globalThis.$$.event(x0,x1,x2,x3),
_145: (x0,x1) => globalThis.$$.text_effect(x0,x1),
_146: f => finalizeWrapper(f,() => dartInstance.exports._146(f)),
_147: (x0,x1) => globalThis.$$.text(x0,x1),
_148: (x0,x1,x2) => globalThis.$$.html(x0,x1,x2),
_149: f => finalizeWrapper(f,() => dartInstance.exports._149(f)),
_150: (x0,x1,x2) => globalThis.$$.attr_effect(x0,x1,x2),
_151: f => finalizeWrapper(f,() => dartInstance.exports._151(f)),
_152: (x0,x1,x2) => globalThis.$$.attr(x0,x1,x2),
_154: x0 => globalThis.$$.spread_props(x0),
_155: x0 => ({target: x0}),
_158: (x0,x1) => globalThis.$$.mount(x0,x1),
_159: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._159(f,x0,x1)),
_160: x0 => globalThis.$$.unmount(x0),
_162: (x0,x1,x2) => globalThis.$$.prop(x0,x1,x2),
_163: () => globalThis.$$.init(),
_183: x0 => globalThis.$$.get(x0),
_184: (x0,x1) => globalThis.$$.set(x0,x1),
_185: (x0,x1) => globalThis.$$.mutate(x0,x1),
_186: x0 => globalThis.$$.untrack(x0),
_187: f => finalizeWrapper(f,() => dartInstance.exports._187(f)),
_188: (x0,x1) => globalThis.$$.push(x0,x1),
_191: () => globalThis.$$.pop(),
_192: x0 => globalThis.$$.unwrap(x0),
_7228: () => globalThis.document,
_1657: x0 => x0.value,
_2255: () => globalThis.window,
_72: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
_73: s => printToConsole(stringFromDartString(s)),
_289: o => o === undefined,
_290: o => typeof o === 'boolean',
_291: o => typeof o === 'number',
_293: o => typeof o === 'string',
_296: o => o instanceof Int8Array,
_297: o => o instanceof Uint8Array,
_298: o => o instanceof Uint8ClampedArray,
_299: o => o instanceof Int16Array,
_300: o => o instanceof Uint16Array,
_301: o => o instanceof Int32Array,
_302: o => o instanceof Uint32Array,
_303: o => o instanceof Float32Array,
_304: o => o instanceof Float64Array,
_305: o => o instanceof ArrayBuffer,
_306: o => o instanceof DataView,
_307: o => o instanceof Array,
_308: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_312: (l, r) => l === r,
_313: o => o,
_314: o => o,
_315: o => o,
_316: b => !!b,
_317: o => o.length,
_320: (o, i) => o[i],
_321: f => f.dartFunction,
_322: l => arrayFromDartList(Int8Array, l),
_323: l => arrayFromDartList(Uint8Array, l),
_324: l => arrayFromDartList(Uint8ClampedArray, l),
_325: l => arrayFromDartList(Int16Array, l),
_326: l => arrayFromDartList(Uint16Array, l),
_327: l => arrayFromDartList(Int32Array, l),
_328: l => arrayFromDartList(Uint32Array, l),
_329: l => arrayFromDartList(Float32Array, l),
_330: l => arrayFromDartList(Float64Array, l),
_331: (data, length) => {
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
          }
          return view;
        },
_332: l => arrayFromDartList(Array, l),
_333: stringFromDartString,
_334: stringToDartString,
_335: () => ({}),
_341: (o, p) => o[p],
_337: l => new Array(l),
_345: o => String(o),
_248: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_250: o => o.buffer,
_198: (a, i) => a.push(i),
_206: (a, s, e) => a.slice(s, e),
_209: a => a.length,
_211: (a, i) => a[i],
_212: (a, i, v) => a[i] = v,
_214: a => a.join(''),
_224: (s, p, i) => s.indexOf(p, i),
_226: (o, offsetInBytes, lengthInBytes) => {
      var dst = new ArrayBuffer(lengthInBytes);
      new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
      return new DataView(dst);
    },
_227: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_228: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_229: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_230: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_231: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_232: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_233: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_236: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_237: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_239: WebAssembly.String.charCodeAt,
_242: WebAssembly.String.length,
_243: WebAssembly.String.equals,
_244: WebAssembly.String.compare,
_245: WebAssembly.String.fromCharCode,
_251: o => o.byteOffset,
_252: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_253: (b, o) => new DataView(b, o),
_255: Function.prototype.call.bind(DataView.prototype.getUint8),
_257: Function.prototype.call.bind(DataView.prototype.getInt8),
_259: Function.prototype.call.bind(DataView.prototype.getUint16),
_261: Function.prototype.call.bind(DataView.prototype.getInt16),
_263: Function.prototype.call.bind(DataView.prototype.getUint32),
_265: Function.prototype.call.bind(DataView.prototype.getInt32),
_271: Function.prototype.call.bind(DataView.prototype.getFloat32),
_273: Function.prototype.call.bind(DataView.prototype.getFloat64),
_83: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_11: x0 => new Array(x0),
_16: (o,s) => o[s],
_17: (o,s,v) => o[s] = v,
_20: (x0,x1,x2) => x0.call(x1,x2),
_44: () => Symbol("jsBoxedDartObjectProperty"),
_366: (o, p, v) => o[p] = v,
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

