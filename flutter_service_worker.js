'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "27f84c9d1b7bc35fa5acbcd4cd17d385",
"assets/AssetManifest.bin.json": "b4ff18c9232c1328651cf5bced3abb1b",
"assets/AssetManifest.json": "63c174e43c1f076422bbba412dae28ee",
"assets/assets/images/askai_illustration.png": "1d8359996ee24f62f64ee71da4c7f042",
"assets/assets/images/bestforyou_illustration.png": "35afffbe4ee794a0ac4468e3f90cc583",
"assets/assets/images/data-trend_illustration.png": "42f76f66951394470749297cffe0e11d",
"assets/assets/images/document-analysis_illustration.png": "31b7b02fd7a99fdfa40e00b1c4e3622d",
"assets/assets/images/explore_illustration.png": "b6afe0517f80868530300d273b6a0aa1",
"assets/assets/images/finance_illustration.png": "b38827bb7bae2a389ec639ca519cfb36",
"assets/assets/images/Fin_app_icon.png": "f9cdbe1568872ba65f4cfee75d5cbfb1",
"assets/assets/images/Fin_app_icon_reverse_80px.png": "0654d511f0541cbdb0cd0bf4efdabb36",
"assets/assets/images/Fin_logo.png": "126fdfd57af2618f9b777795f6e583a1",
"assets/assets/images/google_logo.png": "937c87b4439809d5b17b82728df09639",
"assets/assets/images/login_illustration.png": "e3db8b90289bde820117617217835338",
"assets/assets/langs/bn.json": "596e4dfc0f97fcb3a6d16fac3080aace",
"assets/assets/langs/en.json": "b2074f8b9e796b395e89b4a9d408889b",
"assets/assets/langs/gu.json": "85f97e3fd541a16fc3f2bc5fb033eeb8",
"assets/assets/langs/hi.json": "175ef8d9b532093e9f2d3c60c092da21",
"assets/assets/langs/kn.json": "4ab5e337d3a1dc3f92c34416da153890",
"assets/assets/langs/ml.json": "530e67dc5a359ccaedbfe3fcc7e4a797",
"assets/assets/langs/mr.json": "aa2e6323f196b447b0de6492b0dda01e",
"assets/assets/langs/ta.json": "e5b3e532bb4a15963620130567af0cfe",
"assets/assets/langs/te.json": "7aad67db0b10dc93b2568bd93a457af4",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/fonts/MaterialIcons-Regular.otf": "f07a22d025314907a4523e973cece8a6",
"assets/NOTICES": "0e1ec9a6bc0a1852957c84f0258cad3d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "e0d29696df3895a8f950e6024d0a6fec",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "28d590e64defb897f9fa660d30eb6653",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "809a3fcfd066054b98ce0b7db6f3462a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "786b4db261f00b7536e1f8fa08236ab3",
"/": "786b4db261f00b7536e1f8fa08236ab3",
"main.dart.js": "7c28ee33c181a6ec4623f2d1d244d509",
"manifest.json": "80c81426b16e74e31df9f63b0987bade",
"splash/img/dark-1x.png": "2c7e6ada68008890944df6727bb7b904",
"splash/img/dark-2x.png": "13a793f34a26f4e62d11ea4d63244aa0",
"splash/img/dark-3x.png": "0bb68c63b942a788cb0e31c1a332f430",
"splash/img/dark-4x.png": "7f05c1949da363f19127eab2c9d9441e",
"splash/img/light-1x.png": "2c7e6ada68008890944df6727bb7b904",
"splash/img/light-2x.png": "13a793f34a26f4e62d11ea4d63244aa0",
"splash/img/light-3x.png": "0bb68c63b942a788cb0e31c1a332f430",
"splash/img/light-4x.png": "7f05c1949da363f19127eab2c9d9441e",
"version.json": "9464b94cb01f9199503d9eac7e652bcf"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
