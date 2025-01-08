package com.example.connectcare

import android.nfc.*
import android.nfc.tech.*
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import java.io.IOException

class MainActivity: FlutterActivity(), NfcAdapter.ReaderCallback {
    private val CHANNEL = "com.tu_paquete/nfc"

    // Variables para manejar escritura/lectura de un bloque específico
    private var pendingWrite: Pair<Int, String>? = null
    private var writeResult: MethodChannel.Result? = null
    private var pendingRead: Int? = null
    private var readResult: MethodChannel.Result? = null

    // Variables para manejar la lectura de todos los bloques en una sola pasada
    private var pendingReadAll = false
    private var readAllResult: MethodChannel.Result? = null

    // NUEVO: Para manejar la escritura de MÚLTIPLES bloques en una sola pasada
    private var pendingMultipleWrites: List<Pair<Int, String>>? = null

    private var nfcAdapter: NfcAdapter? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "writeNFC" -> {
                        Log.d("NFC", "Método writeNFC llamado")
                        val block = call.argument<Int>("block")
                        val data = call.argument<String>("data")
                        if (block != null && data != null) {
                            writeNFC(block, data, result)
                        } else {
                            Log.e("NFC", "writeNFC: Bloque o datos faltantes")
                            result.error("INVALID_ARGUMENT", "Bloque o datos faltantes", null)
                        }
                    }
                    "writeMultipleNFCBlocks" -> {
                        Log.d("NFC", "Método writeMultipleNFCBlocks llamado")
                        val writes = call.argument<List<HashMap<String, String>>>("writes")
                        if (writes == null) {
                            result.error("INVALID_ARGUMENT", "No 'writes' provided", null)
                            return@setMethodCallHandler
                        }

                        // Convertimos la lista de HashMap en una lista de Pair<Int, String>
                        val parsedWrites = mutableListOf<Pair<Int, String>>()
                        for (item in writes) {
                            val blockStr = item["block"]
                            val dataStr = item["data"]
                            if (blockStr == null || dataStr == null) {
                                Log.e("NFC", "writeMultipleNFCBlocks: Elemento inválido")
                                result.error("INVALID_ARGUMENT", "Bloque o datos faltantes", null)
                                return@setMethodCallHandler
                            }
                            val blockInt = blockStr.toIntOrNull()
                            if (blockInt == null) {
                                Log.e("NFC", "writeMultipleNFCBlocks: 'block' no es un entero válido")
                                result.error("INVALID_ARGUMENT", "'block' no es un entero válido", null)
                                return@setMethodCallHandler
                            }
                            parsedWrites.add(Pair(blockInt, dataStr))
                        }

                        // Guardamos la petición de escritura múltiple
                        pendingMultipleWrites = parsedWrites
                        writeResult = result
                    }
                    "readNFC" -> {
                        Log.d("NFC", "Método readNFC llamado")
                        val block = call.argument<Int>("block")
                        if (block != null) {
                            readNFC(block, result)
                        } else {
                            Log.e("NFC", "readNFC: Bloque faltante")
                            result.error("INVALID_ARGUMENT", "Bloque faltante", null)
                        }
                    }
                    "readAllNFCBlocks" -> {
                        Log.d("NFC", "Método readAllNFCBlocks llamado")
                        // Marcamos que queremos leer todos los bloques en una sola pasada
                        if (nfcAdapter == null) {
                            result.error(
                                "NFC_UNSUPPORTED",
                                "NFC no está soportado en este dispositivo",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        if (!nfcAdapter!!.isEnabled) {
                            result.error("NFC_DISABLED", "NFC no está habilitado", null)
                            return@setMethodCallHandler
                        }
                        pendingReadAll = true
                        readAllResult = result
                    }
                    else -> {
                        Log.w("NFC", "Método no implementado: ${call.method}")
                        result.notImplemented()
                    }
                }
            }

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        if (nfcAdapter == null) {
            Log.e("NFC", "NFC no está soportado en este dispositivo")
        }
    }

    override fun onResume() {
        super.onResume()
        if (nfcAdapter != null) {
            nfcAdapter?.enableReaderMode(
                this,
                this,
                NfcAdapter.FLAG_READER_NFC_A or
                        NfcAdapter.FLAG_READER_NFC_B or
                        NfcAdapter.FLAG_READER_NFC_F or
                        NfcAdapter.FLAG_READER_NFC_V or
                        NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
                null
            )
            Log.d("NFC", "ReaderMode habilitado")
        }
    }

    override fun onPause() {
        super.onPause()
        if (nfcAdapter != null) {
            nfcAdapter?.disableReaderMode(this)
            Log.d("NFC", "ReaderMode deshabilitado")
        }
    }

    /**
     * Este callback se activa cuando el dispositivo detecta un Tag NFC
     */
    override fun onTagDiscovered(tag: Tag?) {
        if (tag == null) {
            Log.e("NFC", "Tag descubierto es null")
            return
        }

        val idHex = tag.id.joinToString("") { String.format("%02X", it) }
        Log.d("NFC", "Tag NFC detectado: $idHex")
        handleTag(tag)
    }

    /**
     * Lógica para delegar según la tecnología que soporte la etiqueta
     */
    private fun handleTag(tag: Tag) {
        val techList = tag.techList
        Log.d("NFC", "Tecnologías soportadas por la etiqueta: ${techList.joinToString(", ")}")

        when {
            Ndef.get(tag) != null -> {
                Log.d("NFC", "Etiqueta soporta NDEF")
                handleNdef(tag)
            }
            MifareClassic.get(tag) != null -> {
                Log.d("NFC", "Etiqueta es MIFARE Classic")
                handleMifareClassic(tag)
            }
            IsoDep.get(tag) != null -> {
                Log.d("NFC", "Etiqueta soporta IsoDep")
                handleIsoDep(tag)
            }
            else -> {
                Log.e("NFC", "Tecnología de etiqueta no soportada para lectura/escritura")
                writeResult?.error(
                    "UNSUPPORTED_TAG",
                    "Tecnología de etiqueta no soportada",
                    null
                )
                readResult?.error(
                    "UNSUPPORTED_TAG",
                    "Tecnología de etiqueta no soportada",
                    null
                )
                // También notificamos si estaba pendiente la lectura de "todos los bloques"
                if (pendingReadAll) {
                    readAllResult?.error(
                        "UNSUPPORTED_TAG",
                        "Tecnología de etiqueta no soportada",
                        null
                    )
                    pendingReadAll = false
                    readAllResult = null
                }
            }
        }
    }

    /**
     * Escritura de un bloque MifareClassic pendiente (single-block)
     */
    private fun writeNFC(block: Int, data: String, result: MethodChannel.Result) {
        Log.d("NFC", "Iniciando escritura en bloque $block con datos: $data")
        if (nfcAdapter == null) {
            Log.e("NFC", "NFC no está soportado en este dispositivo")
            result.error("NFC_UNSUPPORTED", "NFC no está soportado en este dispositivo", null)
            return
        }
        if (!nfcAdapter!!.isEnabled) {
            Log.e("NFC", "NFC está deshabilitado")
            result.error("NFC_DISABLED", "NFC no está habilitado", null)
            return
        }

        // Guardamos la petición de escritura para procesarla en handleTag
        pendingWrite = Pair(block, data)
        writeResult = result
    }

    /**
     * Lectura de un bloque MifareClassic (single-block)
     */
    private fun readNFC(block: Int, result: MethodChannel.Result) {
        Log.d("NFC", "Iniciando lectura del bloque $block")
        if (nfcAdapter == null) {
            Log.e("NFC", "NFC no está soportado en este dispositivo")
            result.error("NFC_UNSUPPORTED", "NFC no está soportado en este dispositivo", null)
            return
        }
        if (!nfcAdapter!!.isEnabled) {
            Log.e("NFC", "NFC está deshabilitado")
            result.error("NFC_DISABLED", "NFC no está habilitado", null)
            return
        }

        // Guardamos la petición de lectura para procesarla en handleTag
        pendingRead = block
        readResult = result
    }

    /**
     * Manejo específico para etiquetas MIFARE Classic
     */
    private fun handleMifareClassic(tag: Tag) {
        val mifareClassic = MifareClassic.get(tag) ?: run {
            Log.e("NFC", "MifareClassic no está soportado por esta etiqueta")
            writeResult?.error(
                "UNSUPPORTED_TAG",
                "MifareClassic no soportado por esta etiqueta",
                null
            )
            readResult?.error(
                "UNSUPPORTED_TAG",
                "MifareClassic no soportado por esta etiqueta",
                null
            )
            // También notificamos si estaba pendiente la lectura global
            if (pendingReadAll) {
                readAllResult?.error(
                    "UNSUPPORTED_TAG",
                    "MifareClassic no soportado por esta etiqueta",
                    null
                )
                pendingReadAll = false
                readAllResult = null
            }
            return
        }

        try {
            mifareClassic.connect()
            Log.d("NFC", "Conexión MifareClassic establecida")

            // -------------------------------------------------
            // 1) ¿Hay escritura pendiente de UN solo bloque?
            // -------------------------------------------------
            if (pendingWrite != null) {
                val (block, data) = pendingWrite!!
                Log.d("NFC", "Procesando escritura MifareClassic de UN solo bloque")

                val sector = mifareClassic.blockToSector(block)
                Log.d("NFC", "Sector calculado: $sector")

                val auth = mifareClassic.authenticateSectorWithKeyA(
                    sector,
                    byteArrayOf(
                        0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
                        0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
                    )
                )

                if (!auth) {
                    Log.e("NFC", "Autenticación fallida para escritura en sector $sector")
                    writeResult?.error("AUTH_FAILED", "Autenticación fallida", null)
                } else {
                    val bytes = data.toByteArray(Charsets.UTF_8)
                    val paddedBytes = ByteArray(16) { 0x00 }
                    System.arraycopy(
                        bytes,
                        0,
                        paddedBytes,
                        0,
                        bytes.size.coerceAtMost(16)
                    )
                    Log.d("NFC", "Datos a escribir: ${paddedBytes.contentToString()}")

                    try {
                        mifareClassic.writeBlock(block, paddedBytes)
                        Log.d("NFC", "Escritura exitosa en bloque $block")
                        writeResult?.success(true)
                    } catch (e: IOException) {
                        Log.e("NFC", "Error de E/S durante la escritura: ${e.message}")
                        writeResult?.error("IO_ERROR", "Error de E/S durante la escritura", null)
                    } catch (e: TagLostException) {
                        Log.e("NFC", "Etiqueta perdida durante la escritura: ${e.message}")
                        writeResult?.error("TAG_LOST", "Etiqueta perdida durante la escritura", null)
                    } catch (e: Exception) {
                        Log.e("NFC", "Error inesperado durante la escritura: ${e.message}")
                        writeResult?.error("UNKNOWN_ERROR", e.message, null)
                    }
                }
                // Reseteamos variables de escritura single-block
                pendingWrite = null
                writeResult = null
            }

            // -------------------------------------------------
            // 2) ¿Hay escritura pendiente de MÚLTIPLES bloques?
            // -------------------------------------------------
            if (pendingMultipleWrites != null) {
                Log.d("NFC", "Procesando escritura MifareClassic de MÚLTIPLES bloques")
                var successTotal = true

                for ((block, data) in pendingMultipleWrites!!) {
                    val sector = mifareClassic.blockToSector(block)
                    Log.d("NFC", "Bloque $block -> sector $sector")

                    val auth = mifareClassic.authenticateSectorWithKeyA(
                        sector,
                        byteArrayOf(
                            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
                            0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
                        )
                    )

                    if (!auth) {
                        Log.e("NFC", "Autenticación fallida en sector $sector, bloque $block")
                        successTotal = false
                        break
                    } else {
                        val bytes = data.toByteArray(Charsets.UTF_8)
                        val paddedBytes = ByteArray(16) { 0x00 }
                        System.arraycopy(
                            bytes,
                            0,
                            paddedBytes,
                            0,
                            bytes.size.coerceAtMost(16)
                        )

                        try {
                            mifareClassic.writeBlock(block, paddedBytes)
                            Log.d("NFC", "Escritura exitosa en bloque $block")
                        } catch (e: IOException) {
                            Log.e("NFC", "Error de E/S durante la escritura: ${e.message}")
                            successTotal = false
                            break
                        } catch (e: TagLostException) {
                            Log.e("NFC", "Etiqueta perdida durante la escritura: ${e.message}")
                            successTotal = false
                            break
                        } catch (e: Exception) {
                            Log.e("NFC", "Error inesperado durante la escritura: ${e.message}")
                            successTotal = false
                            break
                        }
                    }
                }

                writeResult?.success(successTotal)
                pendingMultipleWrites = null
                writeResult = null
            }

            // -------------------------------------------------
            // 3) ¿Hay lectura pendiente de UN solo bloque?
            // -------------------------------------------------
            if (pendingRead != null) {
                val block = pendingRead!!
                Log.d("NFC", "Procesando lectura MifareClassic del bloque $block")

                val sector = mifareClassic.blockToSector(block)
                Log.d("NFC", "Sector calculado: $sector")

                val auth = mifareClassic.authenticateSectorWithKeyA(
                    sector,
                    byteArrayOf(
                        0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
                        0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
                    )
                )

                if (!auth) {
                    Log.e("NFC", "Autenticación fallida para lectura en sector $sector")
                    readResult?.error("AUTH_FAILED", "Autenticación fallida", null)
                } else {
                    try {
                        val data = mifareClassic.readBlock(block)
                        Log.d("NFC", "Datos leídos del bloque $block: ${data.contentToString()}")
                        val textoLeido = String(data, Charsets.UTF_8).trimEnd('\u0000')
                        Log.d("NFC", "Texto leído: $textoLeido")
                        readResult?.success(textoLeido)
                    } catch (e: IOException) {
                        Log.e("NFC", "Error de E/S durante la lectura: ${e.message}")
                        readResult?.error("IO_ERROR", "Error de E/S durante la lectura", null)
                    } catch (e: TagLostException) {
                        Log.e("NFC", "Etiqueta perdida durante la lectura: ${e.message}")
                        readResult?.error("TAG_LOST", "Etiqueta perdida durante la lectura", null)
                    } catch (e: Exception) {
                        Log.e("NFC", "Error inesperado durante la lectura: ${e.message}")
                        readResult?.error("UNKNOWN_ERROR", e.message, null)
                    }
                }
                // Reseteamos variables de lectura single-block
                pendingRead = null
                readResult = null
            }

            // -------------------------------------------------
            // 4) ¿Hay lectura pendiente de TODOS los bloques?
            // -------------------------------------------------
            if (pendingReadAll) {
                Log.d("NFC", "Procesando lectura de TODOS los bloques MifareClassic")

                try {
                    val startBlock = 8       // Bloque inicial
                    val maxBlocks = 16       // Cantidad de bloques a leer
                    val totalData = StringBuilder()

                    for (i in 0 until maxBlocks) {
                        val blockToRead = startBlock + i
                        // Saltar bloques tráiler (cada 4to bloque en MifareClassic)
                        if (blockToRead % 4 == 3) {
                            continue
                        }
                        // Determinar sector y autenticar
                        val sector = mifareClassic.blockToSector(blockToRead)
                        val auth = mifareClassic.authenticateSectorWithKeyA(
                            sector,
                            byteArrayOf(
                                0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
                                0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte()
                            )
                        )
                        if (!auth) {
                            // Si falla la autenticación en algún sector, puedes parar o continuar
                            Log.e("NFC", "Autenticación fallida en sector $sector, bloque $blockToRead")
                            break
                        }

                        val data = mifareClassic.readBlock(blockToRead)
                        val text = String(data, Charsets.UTF_8).trimEnd('\u0000')

                        // Si lees un bloque vacío, puedes romper o continuar
                        if (text.isEmpty()) {
                            break
                        }
                        totalData.append(text)
                    }
                    // Regresamos todo lo leído a Flutter
                    Log.d("NFC", "Lectura completa: $totalData")
                    readAllResult?.success(totalData.toString())

                } catch (e: Exception) {
                    Log.e("NFC", "Error al leer todos los bloques: ${e.message}")
                    readAllResult?.error("NFC_READ_ERROR", e.message, null)
                }

                // Reseteamos variables de lectura global
                pendingReadAll = false
                readAllResult = null
            }

        } catch (e: Exception) {
            Log.e("NFC", "Error al manejar MifareClassic: ${e.message}")
            writeResult?.error("MIFARE_ERROR", e.message, null)
            readResult?.error("MIFARE_ERROR", e.message, null)
            // Si estaba pendiente la lectura global, también notificamos
            if (pendingReadAll) {
                readAllResult?.error("MIFARE_ERROR", e.message, null)
                pendingReadAll = false
                readAllResult = null
            }
        } finally {
            try {
                mifareClassic.close()
                Log.d("NFC", "Conexión MifareClassic cerrada")
            } catch (e: IOException) {
                Log.e("NFC", "Error al cerrar conexión MifareClassic: ${e.message}")
            }
        }
    }

    /**
     * Manejo para etiquetas NDEF (no MIFARE Classic)
     */
    private fun handleNdef(tag: Tag) {
        val ndef = Ndef.get(tag) ?: run {
            Log.e("NFC", "NDEF no está soportado por esta etiqueta")
            writeResult?.error("UNSUPPORTED_TAG", "NDEF no soportado por esta etiqueta", null)
            readResult?.error("UNSUPPORTED_TAG", "NDEF no soportado por esta etiqueta", null)
            if (pendingReadAll) {
                readAllResult?.error("UNSUPPORTED_TAG", "NDEF no soportado para readAll", null)
                pendingReadAll = false
                readAllResult = null
            }
            return
        }

        try {
            ndef.connect()
            Log.d("NFC", "Conexión NDEF establecida")

            // En caso de que quisieras escribir/leer NDEF, se haría aquí...
            // No se implementa en este ejemplo, pues usamos MifareClassic.

        } catch (e: Exception) {
            Log.e("NFC", "Error al manejar NDEF: ${e.message}")
            writeResult?.error("NDEF_ERROR", e.message, null)
            readResult?.error("NDEF_ERROR", e.message, null)
            if (pendingReadAll) {
                readAllResult?.error("NDEF_ERROR", e.message, null)
                pendingReadAll = false
                readAllResult = null
            }
        } finally {
            try {
                ndef.close()
                Log.d("NFC", "Conexión NDEF cerrada")
            } catch (e: IOException) {
                Log.e("NFC", "Error al cerrar conexión NDEF: ${e.message}")
            }
        }
    }

    /**
     * Manejo para etiquetas IsoDep (no se implementa aquí)
     */
    private fun handleIsoDep(tag: Tag) {
        val isoDep = IsoDep.get(tag) ?: run {
            Log.e("NFC", "IsoDep no está soportado por esta etiqueta")
            writeResult?.error(
                "UNSUPPORTED_TAG",
                "IsoDep no soportado por esta etiqueta",
                null
            )
            readResult?.error(
                "UNSUPPORTED_TAG",
                "IsoDep no soportado por esta etiqueta",
                null
            )
            if (pendingReadAll) {
                readAllResult?.error("UNSUPPORTED_TAG", "IsoDep no soportado para readAll", null)
                pendingReadAll = false
                readAllResult = null
            }
            return
        }

        try {
            isoDep.connect()
            Log.d("NFC", "Conexión IsoDep establecida")
            // Aquí irían operaciones APDU, si fuera el caso...
        } catch (e: Exception) {
            Log.e("NFC", "Error al manejar IsoDep: ${e.message}")
            writeResult?.error("ISO_DEP_ERROR", e.message, null)
            readResult?.error("ISO_DEP_ERROR", e.message, null)
            if (pendingReadAll) {
                readAllResult?.error("ISO_DEP_ERROR", e.message, null)
                pendingReadAll = false
                readAllResult = null
            }
        } finally {
            try {
                isoDep.close()
                Log.d("NFC", "Conexión IsoDep cerrada")
            } catch (e: IOException) {
                Log.e("NFC", "Error al cerrar conexión IsoDep: ${e.message}")
            }
        }
    }
}
