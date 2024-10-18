const express = require('express');
var cors = require('cors');
const connection = require('./connection');
const personalRoute = require('./routes/personal'); 
const app = express();

app.use(cors());
app.use(express.urlencoded({extended: true}));
app.use(express.json());

app.use('/staff', personalRoute);

module.exports = app;