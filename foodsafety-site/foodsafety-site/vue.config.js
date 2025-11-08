module.exports = {
  lintOnSave: false,
  configureWebpack: {
    resolve: {
      alias: {
        '@views': path.resolve(__dirname, 'src/views'),
        '@components': path.resolve(__dirname, 'src/components'),
        '@assets': path.resolve(__dirname, 'src/assets'),
      }
    }
  },
  devServer: {
    port: 8080,
    open: true,
  }
};