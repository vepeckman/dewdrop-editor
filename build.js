const Bundler = require('parcel-bundler');
const Path = require('path');

const entryFiles = Path.join(__dirname, './client/index.html');

// Bundler options
const options = {
  outDir: './dist', // The out directory to put the build files in, defaults to dist
  outFile: 'index.html', // The name of the outputFile
  publicUrl: './', // The url to serve on, defaults to dist
  watch: false,
  cache: true, // Enabled or disables caching, defaults to true
  cacheDir: '.cache', // The directory cache gets put in, defaults to .cache
  minify: true, // Minify files, enabled if process.env.NODE_ENV === 'production'
  target: 'browser', // Browser/node/electron, defaults to browser
  logLevel: 3, // 3 = log everything, 2 = log warnings & errors, 1 = log errors
  sourceMaps: false, // Enable or disable sourcemaps, defaults to enabled (minified builds currently always create sourcemaps)
  detailedReport: false // Prints a detailed report of the bundles, assets, filesizes and times, defaults to false, reports are only printed if watch is disabled
};

(async function() {
  // Initializes a bundler using the entrypoint location and options provided
  const bundler = new Bundler(entryFiles, options);

  // Run the bundler, this returns the main bundle
  // Use the events if you're using watch mode as this promise will only trigger once and not for every rebuild
  const bundle = await bundler.bundle();
})();
