const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.prepend('Provide',
new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    d3: 'd3'
  })
)




const customConfig = {
  resolve: {
    extensions: ['.css'],
    fallback: {
      dgram: false,
      fs: false,
      net: false,
      tls: false,
      child_process: false
    }
  }
};



environment.config.delete('node.dgram')
environment.config.delete('node.fs')
environment.config.delete('node.net')
environment.config.delete('node.tls')
environment.config.delete('node.child_process')

environment.config.merge(customConfig);


module.exports = environment
