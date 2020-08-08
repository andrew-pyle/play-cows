// Set via Makefile
const APP_NAME = "Play-Cows";
const APP_VERSION = "0.2.0";
const ELM_MODULE = "Cows.elm.js";
const CURRENT_CACHE_NAME = createCacheName(APP_NAME, APP_VERSION);

self.addEventListener("install", (event) =>
  event.waitUntil(cacheAppShell(CURRENT_CACHE_NAME))
);

self.addEventListener("activate", (event) => {
  // Delete old cache versions
  event.waitUntil(removeOldCacheVersions(CURRENT_CACHE_NAME));
});

self.addEventListener("fetch", (event) => {
  event.respondWith(serveCacheFirst(event.request));
});

/**
 * Installs dependencies in the service worker cache. For use on "install" event.
 * @param {string} currentCache Name of current app cache version. Allows versioned resources.
 * @returns {Promise<void>} Promise representing success or failure of the add-to-cache operation.
 */
async function cacheAppShell(currentCache) {
  const newCache = await caches.open(currentCache);
  const addToCachePromise = await newCache.addAll([
    "/", // Document
    `/${ELM_MODULE}`, // Elm program
  ]);
  return addToCachePromise;
}

/**
 * Deletes all caches for this domain & service worker other than the one with
 * version matching the argument
 * @param {string} currentCache Semver of the cache to keep
 * @returns {Promise<void>} Promise representing success or failure of removing old caches
 */
async function removeOldCacheVersions(currentCache) {
  const allCacheNames = await caches.keys();
  const oldCaches = allCacheNames.filter(
    (name) => doesCacheBelongToThisApp(name) && name !== currentCache
  );
  await Promise.all(oldCaches.map((oldCache) => caches.delete(oldCache)));
}

/**
 * Serves resources from the cache, falling back to the network if cache miss
 * @param {RequestInfo} request request url
 */
async function serveCacheFirst(request) {
  const currentCache = await caches.open(CURRENT_CACHE_NAME);
  const response = await currentCache.match(request);
  return response || fetch(request);
}

/**
 * Creates predictable, versioned cache names so that we can maintain versioned
 * caches on service worker updates
 * @param {string} appName This app's name
 * @param {string} version The current version of this app's cache
 */
function createCacheName(appName, version) {
  return `${appName}@${version}`;
}

/**
 * Identifies caches created by this app
 * @param {string} cacheName Name of a cache belonging to this origin
 * @returns {boolean} Whether the cache name adheres to this app's naming scheme
 */
function doesCacheBelongToThisApp(cacheName) {
  const appName = cacheName.split("@")[0];
  return appName === APP_NAME;
}
