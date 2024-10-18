const express = require('express');
const connection = require('../connection');
const router = express.Router();

// Signup Route
router.post('/signup', (req, res) => {
    const {
        id_personal,
        nombre,
        apellido_paterno,
        apellido_materno,
        tipo,
        correo_electronico,
        contrasena,
        telefono,
        estatus
    } = req.body;

    // Check if email or phone number already exists
    const checkQuery = `SELECT COUNT(*) AS count FROM personal WHERE correo_electronico = ? OR telefono = ?`;
    connection.query(checkQuery, [correo_electronico, telefono], (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Error checking existing user", details: err });
        }

        if (results[0].count > 0) {
            return res.status(400).json({ error: "Correo electrónico o teléfono ya registrado" });
        }

        // Insert new user with NULL values for asignado, clues, and firebase_uid
        const insertQuery = `INSERT INTO personal (id_personal, nombre, apellido_paterno, apellido_materno, tipo, correo_electronico, contrasena, telefono, estatus, asignado, clues, firebase_uid)
                             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL)`;
        const params = [id_personal, nombre, apellido_paterno, apellido_materno, tipo, correo_electronico, contrasena, telefono, estatus];

        connection.query(insertQuery, params, (err, results) => {
            if (err) {
                return res.status(500).json({ error: "Error registering user", details: err });
            }

            return res.status(201).json({ message: "Usuario registrado exitosamente" });
        });
    });
});

// Login Route
router.post('/login', (req, res) => {
    const { identifier, contrasena } = req.body; // 'identifier' puede ser telefono o correo

    const query = `SELECT * FROM personal WHERE (correo_electronico = ? OR telefono = ?) AND contrasena = ?`;

    connection.query(query, [identifier, identifier, contrasena], (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Error during login", details: err });
        }

        if (results.length === 0) {
            return res.status(400).json({ error: "Correo electrónico, teléfono o contraseña incorrectos" });
        }

        // Remove password before sending user data
        const user = results[0];
        delete user.contrasena;

        return res.status(200).json({ message: "Inicio de sesión exitoso", user });
    });
});

router.get('/getUser/:userId', (req, res) => {
    const userId = req.params.userId;

    const query = 'SELECT * FROM personal WHERE id_personal = ?';

    connection.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error al obtener los datos del usuario:', err);
            return res.status(500).json({ error: 'Error al obtener los datos del usuario', details: err });
        }

        if (results.length > 0) {
            res.status(200).json(results[0]);
        } else {
            res.status(404).json({ error: 'Usuario no encontrado' });
        }
    });
});


// Edit Profile Route
router.put('/editProfile/:userId', (req, res) => {
    const {
        id_personal,
        nombre,
        apellido_paterno,
        apellido_materno,
        tipo,
        correo_electronico,
        contrasena,
        telefono,
        estatus
    } = req.body;

    // Check if new email or phone number is already registered to another user
    const checkQuery = `SELECT COUNT(*) AS count FROM personal WHERE (correo_electronico = ? OR telefono = ?) AND id_personal != ?`;

    connection.query(checkQuery, [correo_electronico, telefono, id_personal], (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Error checking existing user", details: err });
        }

        if (results[0].count > 0) {
            return res.status(400).json({ error: "Correo electrónico o teléfono ya registrado a otro usuario" });
        }

        // Update user data
        const updateQuery = `UPDATE personal SET nombre = ?, apellido_paterno = ?, apellido_materno = ?, tipo = ?, correo_electronico = ?, contrasena = ?, telefono = ?, estatus = ? WHERE id_personal = ?`;

        const params = [nombre, apellido_paterno, apellido_materno, tipo, correo_electronico, contrasena, telefono, estatus, id_personal];

        connection.query(updateQuery, params, (err, results) => {
            if (err) {
                return res.status(500).json({ error: "Error updating profile", details: err });
            }

            return res.status(200).json({ message: "Perfil actualizado exitosamente" });
        });
    });
});

module.exports = router;