require('./main.css');
require('./skeleton.css');
require('./normalize.css');
var logoPath = require('./logo.svg');
var Elm = require('./Main.elm');
var contentful = require('contentful')

var root = document.getElementById('root');
var app = Elm.Main.embed(root, logoPath);

const SPACE_ID = 'txvuwty7qtti'
const ACCESS_TOKEN = '57b323d8f5223ed6cb4e6cba64b51646c54f4f74805e133f4c6e3297d68ce1f9'

var client = contentful.createClient({
  space: SPACE_ID,
  accessToken: ACCESS_TOKEN
})

client.getEntries().then((response) => {
  console.log(response.items);
  // const blogEntry = response.items[0]
  // console.log(response.items[0]);
  app.ports.blogEntry.send([response.items[0]]);

})
  .catch((error) => {
    console.log('\x1b[31merror occured')
    console.log(error)
  })

