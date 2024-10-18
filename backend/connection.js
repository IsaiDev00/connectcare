const mysql = require('mysql');
const fs = require('fs');
require('dotenv').config();

var connection = mysql.createConnection({
    port: process.env.DB_PORT,
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: {
        key: fs.readFileSync(process.env.SSL_KEY_PATH),
        cert: fs.readFileSync(process.env.SSL_CERT_PATH),
        ca: fs.readFileSync(process.env.SSL_CA_PATH)
    }
});

connection.connect((err) => {
    if (!err) {
        console.log("connected");
    } else {
        console.log("Connection error: ", err);
    }
});

module.exports = connection;