const { environment } = require('@rails/webpacker')


const webpack = require('webpack')

environment.plugins.prepend('Provide',
new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    d3: 'd3'
  })
)



module.exports = environment
