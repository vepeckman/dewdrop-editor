var tailwindcss = require('tailwindcss');

module.exports = {
  "plugins": [
      tailwindcss("./src/client/tailwind.js"),
      require('autoprefixer'),
  ]
}
