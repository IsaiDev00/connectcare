const express = require('express');
var cors = require('cors');
const connection = require('./connection');
//const productRoute = require('./routes/product');      Import the product route
const app = express();

app.use(cors());
app.use(express.urlencoded({extended: true}));
app.use(express.json());

//app.use('/products', productRoute);      Use the product route

module.exports = app;