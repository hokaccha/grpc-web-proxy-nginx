const path = require('path');

module.exports = {
  mode: 'development',
  devtool: 'cheap-module-source-map',
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  devServer: {
    contentBase: path.join(__dirname, 'public'),
    port: 4000,
    host: '0.0.0.0',
    overlay: {
      warnings: false,
      errors: true
    },
    stats: 'errors-only'
  }
};
