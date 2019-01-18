var tailwindcss = require('tailwindcss');

module.exports = {
  "plugins": [
      tailwindcss("./src/client/assets/tailwind.js"),
      require('autoprefixer'),
  ]
}
