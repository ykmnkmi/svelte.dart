let buildArgsList;

export const instantiate = async () => {
  let dartInstance;

  function stringFromDartString(string) {
    return dartInstance.exports.$jsStringFromJSStringImpl(string);
  }

  function stringToDartString(string) {
    return dartInstance.exports.$jsStringToJSStringImpl(string);
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

  buildArgsList = function (list) {
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

    _113: () => globalThis.$$.init(),
    _114: (x0, x1, x2) => globalThis.$$.open(x0, x1, x2),
    _115: (x0, x1) => globalThis.$$.close(x0, x1),
    _116: () => globalThis.$$.pop(),
    _117: x0 => globalThis.$$.template(x0),
    _142: x0 => ({ target: x0 }),
    _148: f => finalizeWrapper(f, x0 => dartInstance.exports._148(f, x0)),
    _149: (x0, x1, x2, x3) => globalThis.$$.event(x0, x1, x2, x3),
    _151: (x0, x1) => globalThis.$$.text_effect(x0, x1),
    _152: f => finalizeWrapper(f, () => dartInstance.exports._152(f)),
    _158: (x0, x1) => globalThis.$$.mount(x0, x1),
    _159: f => finalizeWrapper(f, (x0, x1) => dartInstance.exports._159(f, x0, x1)),
    _7188: () => globalThis.document,
    _7278: x0 => x0.body,
    _110: x0 => globalThis.$$.child(x0),
    _139: x0 => globalThis.$$.mutable_source(x0),
    _130: x0 => globalThis.$$.get(x0),
    _131: (x0, x1) => globalThis.$$.set(x0, x1),
    _135: (x0, x1) => globalThis.$$.push(x0, x1),
    _79: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
    _80: s => printToConsole(stringFromDartString(s)),
    _250: o => o === undefined,
    _251: o => typeof o === 'boolean',
    _252: o => typeof o === 'number',
    _254: o => typeof o === 'string',
    _257: o => o instanceof Int8Array,
    _258: o => o instanceof Uint8Array,
    _259: o => o instanceof Uint8ClampedArray,
    _260: o => o instanceof Int16Array,
    _261: o => o instanceof Uint16Array,
    _262: o => o instanceof Int32Array,
    _263: o => o instanceof Uint32Array,
    _264: o => o instanceof Float32Array,
    _265: o => o instanceof Float64Array,
    _266: o => o instanceof ArrayBuffer,
    _267: o => o instanceof DataView,
    _268: o => o instanceof Array,
    _269: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
    _273: (l, r) => l === r,
    _274: o => o,
    _275: o => o,
    _276: o => o,
    _277: b => !!b,
    _278: o => o.length,
    _281: (o, i) => o[i],
    _282: f => f.dartFunction,
    _283: l => arrayFromDartList(Int8Array, l),
    _284: l => arrayFromDartList(Uint8Array, l),
    _285: l => arrayFromDartList(Uint8ClampedArray, l),
    _286: l => arrayFromDartList(Int16Array, l),
    _287: l => arrayFromDartList(Uint16Array, l),
    _288: l => arrayFromDartList(Int32Array, l),
    _289: l => arrayFromDartList(Uint32Array, l),
    _290: l => arrayFromDartList(Float32Array, l),
    _291: l => arrayFromDartList(Float64Array, l),
    _292: (data, length) => {
      const view = new DataView(new ArrayBuffer(length));
      for (let i = 0; i < length; i++) {
        view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
      }
      return view;
    },
    _293: l => arrayFromDartList(Array, l),
    _294: stringFromDartString,
    _295: stringToDartString,
    _296: () => ({}),
    _302: (o, p) => o[p],
    _298: l => new Array(l),
    _306: o => String(o),
    _203: WebAssembly.String.concat,
    _211: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
    _161: (a, i) => a.push(i),
    _172: a => a.length,
    _174: (a, i) => a[i],
    _175: (a, i, v) => a[i] = v,
    _177: a => a.join(''),
    _187: (s, p, i) => s.indexOf(p, i),
    _190: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
    _191: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
    _192: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
    _193: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
    _194: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
    _195: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
    _196: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
    _199: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
    _200: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
    _202: WebAssembly.String.charCodeAt,
    _205: WebAssembly.String.length,
    _206: WebAssembly.String.equals,
    _207: WebAssembly.String.compare,
    _208: WebAssembly.String.fromCharCode,
    _210: l => new DataView(new ArrayBuffer(l)),
    _215: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
    _216: (b, o) => new DataView(b, o),
    _218: Function.prototype.call.bind(DataView.prototype.getUint8),
    _220: Function.prototype.call.bind(DataView.prototype.getInt8),
    _222: Function.prototype.call.bind(DataView.prototype.getUint16),
    _224: Function.prototype.call.bind(DataView.prototype.getInt16),
    _226: Function.prototype.call.bind(DataView.prototype.getUint32),
    _227: Function.prototype.call.bind(DataView.prototype.setUint32),
    _228: Function.prototype.call.bind(DataView.prototype.getInt32),
    _234: Function.prototype.call.bind(DataView.prototype.getFloat32),
    _236: Function.prototype.call.bind(DataView.prototype.getFloat64),
    _90: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
    _16: (o, s) => o[s],
    _17: (o, s, v) => o[s] = v,
    _44: () => Symbol("jsBoxedDartObjectProperty"),
    _48: v => stringToDartString(v.toString()),
    _54: (n) => n.toString(),
    _67: () => {
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

    s: [
      "other",
      "Index out of range",
      "type '",
      "' is not a subtype of ",
      "' of '",
      "'",
      "null",
      "value",
      "Type '",
      "' is not a subtype of type '",
      " in type cast",
      "",
      " (",
      ")",
      ": ",
      "Instance of '",
      ": index must not be negative",
      ": no indices are valid",
      ": index should be less than ",
      "RangeError",
      "<",
      ", ",
      "X",
      " extends ",
      ">",
      "(",
      "[",
      "]",
      "{",
      "}",
      " => ",
      "bool",
      "_BoxedBool",
      "_BoxedDouble",
      "_BoxedInt",
      "JSStringImpl",
      "_BottomType",
      "_TopType",
      "_InterfaceTypeParameterType",
      "_FunctionTypeParameterType",
      "_FutureOrType",
      "_InterfaceType",
      "_AbstractFunctionType",
      "_FunctionType",
      "_AbstractRecordType",
      "_RecordType",
      "_CompactLinkedIdentityHashMap",
      "_CompactLinkedCustomHashMap",
      "_WasmDefaultMap",
      "_WasmDefaultSet",
      "_WasmImmutableMap",
      "_WasmImmutableSet",
      "Record_2",
      "Record_3",
      "Record_4",
      "Record_5",
      "Record_6",
      "Record_7",
      "Record_8",
      "Record_9",
      "_CompactIteratorImmutable",
      "_CompactIterator",
      "UnmodifiableMapView",
      "_TypeTest",
      "_GrowableList",
      "_List",
      "_ImmutableList",
      "MapEntry",
      "_StringStackTrace",
      "_Closure",
      "_GrowableListIterator",
      "_FixedSizeListIterator",
      "StringBuffer",
      "_NamedParameter",
      "_Environment",
      "_SuspendState",
      "_SyncStarIterator",
      "pragma",
      "DeferredNotLoadedError",
      "_TypeError",
      "_JavaScriptError",
      "_TypeCheckVerificationError",
      "AssertionError",
      "ArgumentError",
      "IndexError",
      "NoSuchMethodError",
      "UnsupportedError",
      "StateError",
      "ConcurrentModificationError",
      "IntegerDivisionByZeroException",
      "_Invocation",
      "MappedIterable",
      "_SyncStarIterable",
      "_CompactIterable",
      "_CompactIterableImmutable",
      "_TypeUniverse",
      "StringMatch",
      "Pointer",
      "_RootZone",
      "_ZoneFunction",
      "_AsyncCallbackEntry",
      "_Future",
      "_FutureListener",
      "_AsyncCompleter",
      "AsyncError",
      "_AsyncSuspendState",
      "_JSFloat32ArrayIterator",
      "_JSFloat64ArrayIterator",
      "_JSUint8ArrayIterator",
      "_JSInt8ArrayIterator",
      "_JSUint16ArrayIterator",
      "_JSInt16ArrayIterator",
      "_JSUint32ArrayIterator",
      "_JSInt32ArrayIterator",
      "JSDataViewImpl",
      "JSUint8ArrayImpl",
      "JSInt8ArrayImpl",
      "JSUint8ClampedArrayImpl",
      "JSUint16ArrayImpl",
      "JSInt16ArrayImpl",
      "JSUint32ArrayImpl",
      "JSInt32ArrayImpl",
      "JSFloat32ArrayImpl",
      "JSFloat64ArrayImpl",
      "JSArrayBufferImpl",
      "JSArrayImplIterator",
      "ClassID",
      "JSValue",
      "Symbol",
      "MappedIterator",
      "SentinelValue",
      "_Random",
      "JSArrayImpl",
      "WasmAnyRef",
      "WasmEqRef",
      "WasmStructRef",
      "WasmArrayRef",
      "WasmArray",
      "WasmExternRef",
      "WasmFuncRef",
      "WasmFunction",
      "WasmI8",
      "WasmI16",
      "WasmI32",
      "WasmI64",
      "WasmF32",
      "WasmF64",
      "WasmVoid",
      "WasmTable",
      "Object",
      "num",
      "double",
      "int",
      "_Type",
      "_HashFieldBase",
      "ByteBuffer",
      "Float64List",
      "String",
      "Record",
      "ByteData",
      "Function",
      "Float32List",
      "Uint32List",
      "Int32List",
      "Uint16List",
      "Int16List",
      "Uint8ClampedList",
      "Uint8List",
      "Int8List",
      "UnmodifiableByteDataView",
      "TypedData",
      "_TypedIntList",
      "_TypedFloatList",
      "_LinkedHashSetMixin",
      "_UnmodifiableSetMixin",
      "_LinkedHashMapMixin",
      "_CustomEqualsAndHashCode",
      "LinkedHashSet",
      "_OperatorEqualsAndHashCode",
      "SetBase",
      "_EqualsAndHashCode",
      "MapView",
      "_HashAbstractBase",
      "_HashAbstractImmutableBase",
      "_HashBase",
      "MapBase",
      "_ImmutableLinkedHashMapMixin",
      "_UnmodifiableMapMixin",
      "ListBase",
      "_ListBase",
      "_ModifiableList",
      "LinkedHashMap",
      "_IdenticalAndIdentityHashCode",
      "_ImmutableLinkedHashSetMixin",
      "Map",
      "Null",
      "Pattern",
      "Match",
      "_SetIterable",
      "Set",
      "StackTrace",
      "_ListIterable",
      "StringSink",
      "Comparable",
      "Error",
      "_Error",
      "TypeError",
      "Exception",
      "Type",
      "Invocation",
      "Iterable",
      "EfficientLengthIterable",
      "Iterator",
      "List",
      "Completer",
      "SizedNativeType",
      "NativeType",
      "_Zone",
      "Zone",
      "ZoneDelegate",
      "_AsyncRun",
      "_Completer",
      "_Compound",
      "Future",
      "_JSEventLoop",
      "RangeErrorUtils",
      "_DoubleArrayIteratorBase",
      "_IntListMixin",
      "_IntArrayIteratorBase",
      "_DoubleListMixin",
      "JSArrayBase",
      "Sort",
      "UnmodifiableListMixin",
      "FixedLengthListMixin",
      "HideEfficientLengthIterable",
      "SystemHash",
      "Random",
      "IndexErrorUtils",
      "_WasmBase",
      "minified:Class",
      "?",
      "Object?",
      "dynamic",
      "void",
      "Invalid top type kind",
      "Never",
      "NaN",
      "Infinity",
      "-Infinity",
      "-0.0",
      "0.0",
      "e",
      ".0",
      "[]=",
      "Infinity or NaN toInt",
      "Unsupported operation: ",
      "Invalid value",
      ": Not in inclusive range ",
      "..",
      ": Valid value range is empty",
      ": Only valid value is ",
      "Invalid argument",
      "(s)",
      "[]",
      "...",
      "Concurrent modification during iteration: ",
      ".",
      "true",
      "false",
      "Closure: ",
      "Type argument substitution not supported for ",
      "required ",
      " ",
      "FutureOr",
      "Type parameter should have been substituted already.",
      "T",
      "buffer",
      "Attempt to execute code removed by Dart AOT compiler (TFA)",
      "Null check operator used on a null value",
      "max",
      "Must be positive and <= 2^32",
      "Division resulted in non-finite value",
      "{...}",
      "Function?",
      "Expected integer value, but was not integer.",
      "Cannot add to a fixed-length list",
      "Could not call main",
      "JavaScriptError",
      "Cannot add to an unmodifiable list",
      "Clicked ",
      "time",
      "times",
      "Expected a wrapped Dart object, but got a JS object or a wrapped Dart object from a separate runtime instead.",
      "click",
      "<button> </button>"
    ],
    Math: Math,
    Date: Date,
    Object: Object,
    Array: Array,
    Reflect: Reflect,
  };

  const module = await WebAssembly.instantiateStreaming(fetch('main.dart.wasm'), baseImports);
  dartInstance = module.instance;
  return dartInstance;
}

export const invoke = (moduleInstance, ...args) => {
  const dartMain = moduleInstance.exports.$getMain();
  const dartArgs = buildArgsList(args);
  moduleInstance.exports.$invokeMain(dartMain, dartArgs);
}

