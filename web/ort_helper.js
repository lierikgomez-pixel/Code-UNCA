/* Inferecia local del modelo de limón con ONNX Runtime Web. */
(function () {
  'use strict';

  var ort = window.ort;
  if (!ort) {
    console.error('[LimonORT] Falta la librería ort.min.js');
    return;
  }

  // Un solo hilo evita requerir SharedArrayBuffer/COOP/COEP en Vercel.
  ort.env.wasm.numThreads = 1;
  ort.env.wasm.wasmPaths = 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.23.2/dist/';
  ort.env.logLevel = 'error';

  var initPromise = null;

  window.LimonORT = {
    status: function () {
      return ort ? 'listo' : null;
    },
    init: function () {
      if (!initPromise) {
        initPromise = ort.InferenceSession.create('modelo_limon.onnx', {
          executionProviders: ['wasm'],
          graphOptimizationLevel: 'all',
        }).then(function (session) {
          window.LimonORT.session = session;
          return session;
        }).catch(function (error) {
          initPromise = null;
          throw error;
        });
      }
      return initPromise;
    },
    predict: async function (input) {
      var session = window.LimonORT.session;
      if (!session) {
        await window.LimonORT.init();
        session = window.LimonORT.session;
      }
      var tensor = new ort.Tensor('float32', input, [1, 3, 224, 224]);
      var results = await session.run({ images: tensor });
      return results.logits.data;
    },
  };
})();
