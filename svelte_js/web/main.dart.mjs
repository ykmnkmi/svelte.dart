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
_138: (x0,x1) => globalThis.$$.template(x0,x1),
_139: x0 => globalThis.$$.template(x0),
_140: (x0,x1,x2) => globalThis.$$.open(x0,x1,x2),
_141: (x0,x1,x2) => globalThis.$$.open_frag(x0,x1,x2),
_142: x0 => globalThis.$$.space(x0),
_143: x0 => globalThis.$$.comment(x0),
_144: (x0,x1) => globalThis.$$.close(x0,x1),
_145: (x0,x1) => globalThis.$$.close_frag(x0,x1),
_147: f => finalizeWrapper(f,x0 => dartInstance.exports._147(f,x0)),
_148: (x0,x1,x2,x3) => globalThis.$$.event(x0,x1,x2,x3),
_150: (x0,x1) => globalThis.$$.text_effect(x0,x1),
_151: f => finalizeWrapper(f,() => dartInstance.exports._151(f)),
_152: (x0,x1) => globalThis.$$.text(x0,x1),
_153: (x0,x1,x2) => globalThis.$$.html(x0,x1,x2),
_154: f => finalizeWrapper(f,() => dartInstance.exports._154(f)),
_155: (x0,x1,x2) => globalThis.$$.attr(x0,x1,x2),
_156: (x0,x1) => globalThis.$$.attr(x0,x1),
_158: x0 => globalThis.$$.spread_props(x0),
_159: x0 => ({target: x0}),
_162: (x0,x1) => globalThis.$$.mount(x0,x1),
_163: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._163(f,x0,x1)),
_165: x0 => globalThis.$$.unmount(x0),
_119: x0 => ({answer: x0}),
_120: x0 => x0.answer,
_117: x0 => ({answer: x0}),
_108: (x0,x1,x2,x3) => ({name: x0,version: x1,speed: x2,website: x3}),
_109: x0 => x0.name,
_110: x0 => x0.version,
_111: x0 => x0.speed,
_112: x0 => x0.website,
_7210: () => globalThis.document,
_1639: x0 => x0.value,
_2237: () => globalThis.window,
_122: (x0,x1,x2,x3) => globalThis.$$.if_block(x0,x1,x2,x3),
_123: f => finalizeWrapper(f,() => dartInstance.exports._123(f)),
_124: f => finalizeWrapper(f,x0 => dartInstance.exports._124(f,x0)),
_103: x0 => globalThis.$$.child(x0),
_105: x0 => globalThis.$$.child_frag(x0),
_106: (x0,x1) => globalThis.$$.sibling(x0,x1),
_107: x0 => globalThis.$$.sibling(x0),
_348: x0 => globalThis.$$.pre_effect(x0),
_349: f => finalizeWrapper(f,() => dartInstance.exports._349(f)),
_350: x0 => globalThis.$$.render_effect(x0),
_351: f => finalizeWrapper(f,(x0,x1) => dartInstance.exports._351(f,x0,x1)),
_347: x0 => globalThis.$$.mutable_source(x0),
_336: x0 => globalThis.$$.get(x0),
_337: (x0,x1) => globalThis.$$.set(x0,x1),
_338: (x0,x1) => globalThis.$$.mutate(x0,x1),
_339: x0 => globalThis.$$.untrack(x0),
_340: f => finalizeWrapper(f,() => dartInstance.exports._340(f)),
_341: (x0,x1) => globalThis.$$.push(x0,x1),
_344: () => globalThis.$$.pop(),
_345: (x0,x1,x2) => globalThis.$$.prop(x0,x1,x2),
_346: () => globalThis.$$.init(),
_72: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
_73: s => printToConsole(stringFromDartString(s)),
_257: o => o === undefined,
_258: o => typeof o === 'boolean',
_259: o => typeof o === 'number',
_261: o => typeof o === 'string',
_264: o => o instanceof Int8Array,
_265: o => o instanceof Uint8Array,
_266: o => o instanceof Uint8ClampedArray,
_267: o => o instanceof Int16Array,
_268: o => o instanceof Uint16Array,
_269: o => o instanceof Int32Array,
_270: o => o instanceof Uint32Array,
_271: o => o instanceof Float32Array,
_272: o => o instanceof Float64Array,
_273: o => o instanceof ArrayBuffer,
_274: o => o instanceof DataView,
_275: o => o instanceof Array,
_276: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_280: (l, r) => l === r,
_281: o => o,
_282: o => o,
_283: o => o,
_284: b => !!b,
_285: o => o.length,
_288: (o, i) => o[i],
_289: f => f.dartFunction,
_290: l => arrayFromDartList(Int8Array, l),
_291: l => arrayFromDartList(Uint8Array, l),
_292: l => arrayFromDartList(Uint8ClampedArray, l),
_293: l => arrayFromDartList(Int16Array, l),
_294: l => arrayFromDartList(Uint16Array, l),
_295: l => arrayFromDartList(Int32Array, l),
_296: l => arrayFromDartList(Uint32Array, l),
_297: l => arrayFromDartList(Float32Array, l),
_298: l => arrayFromDartList(Float64Array, l),
_299: (data, length) => {
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
          }
          return view;
        },
_300: l => arrayFromDartList(Array, l),
_301: stringFromDartString,
_302: stringToDartString,
_303: () => ({}),
_309: (o, p) => o[p],
_305: l => new Array(l),
_313: o => String(o),
_216: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_166: (a, i) => a.push(i),
_177: a => a.length,
_179: (a, i) => a[i],
_180: (a, i, v) => a[i] = v,
_182: a => a.join(''),
_192: (s, p, i) => s.indexOf(p, i),
_195: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_196: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_197: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_198: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_199: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_200: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_201: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_204: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_205: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_207: WebAssembly.String.charCodeAt,
_210: WebAssembly.String.length,
_211: WebAssembly.String.equals,
_212: WebAssembly.String.compare,
_213: WebAssembly.String.fromCharCode,
_220: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_221: (b, o) => new DataView(b, o),
_223: Function.prototype.call.bind(DataView.prototype.getUint8),
_225: Function.prototype.call.bind(DataView.prototype.getInt8),
_227: Function.prototype.call.bind(DataView.prototype.getUint16),
_229: Function.prototype.call.bind(DataView.prototype.getInt16),
_231: Function.prototype.call.bind(DataView.prototype.getUint32),
_233: Function.prototype.call.bind(DataView.prototype.getInt32),
_239: Function.prototype.call.bind(DataView.prototype.getFloat32),
_241: Function.prototype.call.bind(DataView.prototype.getFloat64),
_83: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_16: (o,s) => o[s],
_17: (o,s,v) => o[s] = v,
_20: (x0,x1,x2) => x0.call(x1,x2),
_44: () => Symbol("jsBoxedDartObjectProperty"),
_334: (o, p, v) => o[p] = v,
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

