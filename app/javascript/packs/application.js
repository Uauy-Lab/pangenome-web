/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
 const images = require.context('../images', true)
 const imagePath = (name) => images(name, true)

// console.log('Hello World from Webpacker')

//export var test_function = function(){
//  console.log("TTEERRERETRET");
//}

//export let test_function;
//module.exports = test_function;
import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";
console.log(">................<");
///module.exports = d3 = require("d3");
//import '../images/logo.svg';
//require.context('./images/', true);
//require.context('./', true, /\.(scss|css)$/);

//const importAll = (r) => r.keys().map(r)
//importAll(require.context('../images', false, /\.(png|jpe?g|svg)$/));
//import('images/CropHaplotypesLogo.png')