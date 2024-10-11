-- Crear tabla de pisos
CREATE TABLE piso (
    numero_piso BIGINT AUTO_INCREMENT PRIMARY KEY
);

-- Crear tabla de familiares con tipo restringido
CREATE TABLE familiar (
    id_familiar BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido_paterno VARCHAR(255) NOT NULL,
    apellido_materno VARCHAR(255) NOT NULL,
    correo_electronico VARCHAR(255),
    contrasena VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    tipo VARCHAR(50) NOT NULL,
    CHECK (tipo IN ('principal', 'regular', 'conexion ocasional'))
);

-- Crear tabla de pacientes
CREATE TABLE paciente (
    nss_paciente BIGINT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido_paterno VARCHAR(255) NOT NULL,
    apellido_materno VARCHAR(255) NOT NULL,
    lpm VARCHAR(255),
    estatura DECIMAL(5,2),
    peso DECIMAL(5,2),
    fecha_entrada DATE,
    habilitar_visita BOOLEAN,
    estado VARCHAR(50),
    sexo ENUM('Masculino', 'Femenino') NOT NULL,
    fecha_nacimiento DATE,
    gpo_y_rh VARCHAR(10),
    visitantes INT,
    alergias TEXT,
    numero_piso BIGINT,
    FOREIGN KEY (numero_piso) REFERENCES piso(numero_piso)
);

-- Crear tabla de servicios
CREATE TABLE servicio (
    id_servicio BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    numero_piso BIGINT,
    FOREIGN KEY (numero_piso) REFERENCES piso(numero_piso)
);

-- Crear tabla de salas
CREATE TABLE sala (
    numero_sala BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    lleno BOOLEAN,
    id_servicio BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
);

-- Crear tabla de horarios de visita
CREATE TABLE horario_visita (
    id_horario_visita BIGINT AUTO_INCREMENT PRIMARY KEY,
    inicio TIME NOT NULL,
    fin TIME NOT NULL,
    visitantes INT,
    id_sala BIGINT,
    FOREIGN KEY (id_sala) REFERENCES sala(numero_sala)
);

-- Crear tabla de procedimientos
CREATE TABLE procedimiento (
    id_procedimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    cantidad_enfermeros INT,
    cantidad_medicos INT
);

-- Crear tabla de relación sala-procedimiento
CREATE TABLE sala_procedimiento (
    numero_sala BIGINT,
    id_procedimiento BIGINT,
    FOREIGN KEY (numero_sala) REFERENCES sala(numero_sala),
    FOREIGN KEY (id_procedimiento) REFERENCES procedimiento(id_procedimiento)
);

-- Crear tabla de camas
CREATE TABLE cama (
    numero_cama BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    en_uso BOOLEAN,
    numero_sala BIGINT,
    FOREIGN KEY (numero_sala) REFERENCES sala(numero_sala)
);

-- Crear tabla de agenda de procedimientos
CREATE TABLE agenda_procedimiento (
    id_agenda_procedimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    id_procedimiento BIGINT,
    FOREIGN KEY (id_procedimiento) REFERENCES procedimiento(id_procedimiento)
);

-- Crear tabla de hospitales
CREATE TABLE hospital (
    clues BIGINT PRIMARY KEY,
    colonia VARCHAR(255) NOT NULL,
    estatus VARCHAR(50) NOT NULL,
    cp VARCHAR(10) NOT NULL,
    calle VARCHAR(255) NOT NULL,
    numero_calle VARCHAR(10) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    municipio VARCHAR(50) NOT NULL,
    nombre VARCHAR(255) NOT NULL
);

-- Crear tabla de personal
CREATE TABLE personal (
    id_personal BIGINT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido_paterno VARCHAR(255) NOT NULL,
    apellido_materno VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    correo_electronico VARCHAR(255),
    contrasena VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    estatus VARCHAR(50),
    asignado CHAR(1) CHECK (asignado IN ('y', 'n')),
    clues BIGINT,
    FOREIGN KEY (clues) REFERENCES hospital(clues)
);

-- Crear tabla de médicos
CREATE TABLE medico (
    id_medico BIGINT AUTO_INCREMENT PRIMARY KEY,
    especialidad VARCHAR(255) NOT NULL,
    jerarquia VARCHAR(50),
    horario VARCHAR(255),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de camilleros
CREATE TABLE camillero (
    id_camillero BIGINT AUTO_INCREMENT PRIMARY KEY,
    jerarquia VARCHAR(50),
    horario VARCHAR(255),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de enfermeros
CREATE TABLE enfermero (
    id_enfermero BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    jerarquia VARCHAR(50),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de trabajo social
CREATE TABLE trabajo_social (
    id_trabajo_social BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de relación paciente-familiar
CREATE TABLE paciente_familiar (
    nss_paciente BIGINT,
    id_familiar BIGINT,
    fecha DATE NOT NULL,
    relacion VARCHAR(255),
    id_trabajo_social BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente),
    FOREIGN KEY (id_familiar) REFERENCES familiar(id_familiar),
    FOREIGN KEY (id_trabajo_social) REFERENCES trabajo_social(id_trabajo_social)
);

-- Crear tabla de recursos humanos
CREATE TABLE rh (
    id_rh BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de administradores
CREATE TABLE administrador (
    id_administrador BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    clues BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (clues) REFERENCES hospital(clues),
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de medicamentos
CREATE TABLE medicamento (
    id_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    marca VARCHAR(255),
    tipo VARCHAR(50),
    cantidad_presentacion INT,
    concentracion VARCHAR(50),
    cantidad_stock INT,
    caducidad DATE,
    id_administrador BIGINT,
    FOREIGN KEY (id_administrador) REFERENCES administrador(id_administrador)
);

-- Crear tabla de solicitudes a hospitales
CREATE TABLE solicitud_a_hospital (
    id_solicitud_a_hospital BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    peticion TEXT,
    clues BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (clues) REFERENCES hospital(clues),
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de movimientos
CREATE TABLE movimiento (
    id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES personal(id_personal)
);

-- Crear tabla de padecimientos
CREATE TABLE padecimiento (
    id_padecimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    gravedad VARCHAR(50),
    periodo_reposo VARCHAR(255)
);

-- Crear tabla de periodos de padecimiento
CREATE TABLE periodo_padecimiento (
    id_periodo_padecimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    periodo_reposo VARCHAR(255),
    edad INT,
    gravedad VARCHAR(50),
    f_inicio DATE,
    f_fin DATE
);

-- Crear tabla de traslados
CREATE TABLE traslado (
    id_traslado BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    nss_paciente BIGINT,
    numero_cama BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente),
    FOREIGN KEY (numero_cama) REFERENCES cama(numero_cama)
);

-- Crear tabla de indicaciones médicas
CREATE TABLE indicaciones_medicas (
    id_indicaciones_medicas BIGINT AUTO_INCREMENT PRIMARY KEY,
    solicitud_medicamento TEXT,
    formula TEXT,
    nutricion TEXT,
    soluciones TEXT,
    lntp TEXT,
    indicaciones TEXT,
    diagnostico TEXT,
    lve TEXT,
    ret TEXT,
    fecha DATE NOT NULL,
    medidas TEXT,
    pendientes TEXT,
    cuidados TEXT,
    nss_paciente BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente)
);

-- Crear tabla de notas de evolución
CREATE TABLE nota_de_evolucion (
    id_nota_de_evolucion BIGINT AUTO_INCREMENT PRIMARY KEY,
    saturacion_oxigeno DECIMAL(5,2),
    temperatura DECIMAL(5,2),
    frecuencia_cardiaca INT,
    frecuencia_respiratoria INT,
    ta_diastolica INT,
    ta_sistolica INT,
    evolucion TEXT,
    somatometria TEXT,
    exploracion_fisica TEXT,
    laboratorio TEXT,
    imagen TEXT,
    diagnostico TEXT,
    plan TEXT,
    pronostico TEXT,
    comentario TEXT,
    nota TEXT,
    destino_hospitalario TEXT,
    resultado_cultivo TEXT,
    fecha_solicitud_cultivo DATE,
    infeccion_nosocomial BOOLEAN,
    fecha_intubacion DATE,
    fecha_cateter DATE,
    nss_paciente BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente)
);

-- Crear tabla de hojas de enfermería
CREATE TABLE hoja_de_enfermeria (
    id_hoja_de_enfermeria BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    codigo_temperatura VARCHAR(50),
    temperatura DECIMAL(5,2),
    problema_interdependiente TEXT,
    ta_sistolica INT,
    ta_diastolica INT,
    frecuencia_respiratoria INT,
    frecuencia_cardiaca INT,
    temperatura_interna DECIMAL(5,2),
    pvc DECIMAL(5,2),
    perimetro DECIMAL(5,2),
    infusion_intravenosa TEXT,
    control_liquidos TEXT,
    escalas TEXT,
    pf TEXT,
    signos TEXT,
    sintomas TEXT,
    peso DECIMAL(5,2),
    intervenciones_colaboracion TEXT,
    dx_medico TEXT,
    nss_paciente BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente)
);

-- Crear tabla de triage
CREATE TABLE triage (
    id_triage BIGINT AUTO_INCREMENT PRIMARY KEY,
    diagnostico TEXT,
    tratamiento TEXT,
    g_capilar DECIMAL(5,2),
    frecuencia_respiratoria INT,
    frecuencia_cardiaca INT,
    ta_diastolica INT,
    ta_sistolica INT,
    fecha_fin DATE,
    hora_fin TIME,
    fecha_inicio DATE,
    hora_inicio TIME,
    temperatura DECIMAL(5,2),
    peso DECIMAL(5,2),
    estatura DECIMAL(5,2),
    escala_glasgow INT,
    gravedad VARCHAR(50),
    motivo TEXT,
    interrogatorio TEXT,
    exploracion_fisica TEXT,
    auxiliares_diagnostico TEXT,
    nss_paciente BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente)
);

-- Crear tabla de historial
CREATE TABLE historial (
    id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,
    nss_paciente BIGINT,
    id_traslado BIGINT,
    id_procedimiento BIGINT,
    id_indicaciones_medicas BIGINT,
    id_nota_de_evolucion BIGINT,
    id_hoja_de_enfermeria BIGINT,
    id_triage BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente),
    FOREIGN KEY (id_traslado) REFERENCES traslado(id_traslado),
    FOREIGN KEY (id_procedimiento) REFERENCES procedimiento(id_procedimiento),
    FOREIGN KEY (id_indicaciones_medicas) REFERENCES indicaciones_medicas(id_indicaciones_medicas),
    FOREIGN KEY (id_nota_de_evolucion) REFERENCES nota_de_evolucion(id_nota_de_evolucion),
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES hoja_de_enfermeria(id_hoja_de_enfermeria),
    FOREIGN KEY (id_triage) REFERENCES triage(id_triage)
);

-- Crear tabla de uso de medicamentos
CREATE TABLE uso_medicamento (
    id_uso_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    id_medicamento BIGINT,
    id_hoja_de_enfermeria BIGINT,
    FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento),
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES hoja_de_enfermeria(id_hoja_de_enfermeria)
);

-- Crear tabla de solicitud de medicamentos
CREATE TABLE solicitud_medicamento (
    id_solicitud_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    concentracion VARCHAR(50),
    cantidad_presentacion INT,
    nombre VARCHAR(255) NOT NULL,
    marca VARCHAR(255),
    tipo VARCHAR(50),
    id_hoja_de_enfermeria BIGINT,
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES hoja_de_enfermeria(id_hoja_de_enfermeria)
);

-- Crear tabla de medicina personalizada
CREATE TABLE medicina_pers (
    id_medicina_pers BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud_medicamento BIGINT,
    concentracion VARCHAR(50),
    caducidad DATE,
    cantidad_stock INT,
    tipo VARCHAR(50),
    marca VARCHAR(255),
    nombre VARCHAR(255) NOT NULL,
    cantidad_presentacion INT,
    nss_paciente BIGINT,
    FOREIGN KEY (id_solicitud_medicamento) REFERENCES solicitud_medicamento(id_solicitud_medicamento),
    FOREIGN KEY (nss_paciente) REFERENCES paciente(nss_paciente)
);
