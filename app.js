var express = require('express');
var app = express();
var port = process.env.PORT ?
    process.env.PORT :
    1343;

app.use(express.static('www'));


app.all('/*', function(req, res, next) {
    // Just send the index.html for other files to support HTML5Mode
    res.sendfile('index.html', { root: __dirname + '/www' });

});

app.listen(port); //the port you want to use
console.log('App started at port :' + port);