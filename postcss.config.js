var tailwindcss = require('tailwindcss');

module.exports = {
  "plugins": [
      tailwindcss("./client/tailwind.js"),
      require('autoprefixer'),
  ]
}
