CREATE TABLE Piso (
    numero_piso BIGINT AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE Familiar (
    id_familiar BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    apellido_paterno VARCAR(255),
    apellido_materno VARCHAR(255),
    correo_electronico VARCHAR(255),
    contrasena VARCHAR(255),
    telefono VARCHAR(20),
    tipo VARCHAR(50)
);

CREATE TABLE Paciente (
    nss_paciente BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    apellido_paterno VARCHAR(255),
    apellido_materno VARCHAR(255),
    lpm VARCHAR(255),
    estatura DECIMAL(5,2),
    peso DECIMAL(5,2),
    fecha_entrada DATE,
    habilitar_visita BOOLEAN,
    estado VARCHAR(50),
    sexo VARCHAR(10),
    fecha_nacimiento DATE,
    gpo_y_rh VARCHAR(10),
    visitantes INT,
    alergias TEXT,
    numero_piso BIGINT,
    FOREIGN KEY (numero_piso) REFERENCES Piso(numero_piso)
);

CREATE TABLE Servicio (
    id_servicio BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    numero_piso BIGINT,
    FOREIGN KEY (numero_piso) REFERENCES Piso(numero_piso)
);

CREATE TABLE Sala (
    numero_sala BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    nombre VARCHAR(255),
    lleno BOOLEAN,
    id_servicio BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio)
);

CREATE TABLE Horario_Visita (
    id_horario_visita BIGINT AUTO_INCREMENT PRIMARY KEY,
    inicio TIME,
    fin TIME,
    visitantes INT,
    id_sala BIGINT,
    FOREIGN KEY (id_sala) REFERENCES Sala(numero_sala)
);

CREATE TABLE Procedimiento (
    id_procedimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion TEXT,
    cantidad_enfermeros INT,
    cantidad_medicos INT
);

CREATE TABLE Sala_Procedimiento (
    numero_sala BIGINT,
    id_procedimiento BIGINT,
    FOREIGN KEY (numero_sala) REFERENCES Sala(numero_sala),
    FOREIGN KEY (id_procedimiento) REFERENCES Procedimiento(id_procedimiento)
);

CREATE TABLE Cama (
    numero_cama BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    en_uso BOOLEAN,
    numero_sala BIGINT,
    FOREIGN KEY (numero_sala) REFERENCES Sala(numero_sala)
);

CREATE TABLE Agenda_Procedimiento (
    id_agenda_procedimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    hora TIME,
    id_procedimiento BIGINT,
    FOREIGN KEY (id_procedimiento) REFERENCES Procedimiento(id_procedimiento)
);

CREATE TABLE Hospital (
    clues BIGINT AUTO_INCREMENT PRIMARY KEY,
    colonia VARCHAR(255),
    estatus VARCHAR(50),
    cp VARCHAR(10),
    calle VARCHAR(255),
    numero_calle VARCHAR(10),
    estado VARCHAR(50),
    municipio VARCHAR(50),
    nombre VARCHAR(255)
);

CREATE TABLE Personal (
    id_personal BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    apellido_paterno VARCHAR(255),
    apellido_materno VARCHAR(255),
    tipo VARCHAR(50),
    correo_electronico VARCHAR(255),
    contrasena VARCHAR(255),
    telefono VARCHAR(20),
    estatus VARCHAR(50),
    clues BIGINT,
    FOREIGN KEY (clues) REFERENCES Hospital(clues)
);

CREATE TABLE Medico (
    id_medico BIGINT AUTO_INCREMENT PRIMARY KEY,
    especialidad VARCHAR(255),
    jerarquia VARCHAR(50),
    horario VARCHAR(255),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Camillero (
    id_camillero BIGINT AUTO_INCREMENT PRIMARY KEY,
    jerarquia VARCHAR(50),
    horario VARCHAR(255),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Enfermero (
    id_enfermero BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    jerarquia VARCHAR(50),
    id_servicio BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (id_servicio) REFERENCES Servicio(id_servicio),
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Trabajo_Social (
    id_trabajo_social BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Paciente_Familiar (
    nss_paciente BIGINT,
    id_familiar BIGINT,
    fecha DATE,
    relacion VARCHAR(255),
    id_trabajo_social BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente),
    FOREIGN KEY (id_familiar) REFERENCES Familiar(id_familiar),
    FOREIGN KEY (id_trabajo_social) REFERENCES Trabajo_Social(id_trabajo_social)
);

CREATE TABLE RH (
    id_rh BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Administrador (
    id_administrador BIGINT AUTO_INCREMENT PRIMARY KEY,
    horario VARCHAR(255),
    clues BIGINT,
    id_personal BIGINT,
    FOREIGN KEY (clues) REFERENCES Hospital(clues),
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Medicamento (
    id_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    marca VARCHAR(255),
    tipo VARCHAR(50),
    cantidad_presentacion INT,
    concentracion VARCHAR(50),
    cantidad_stock INT,
    caducidad DATE,
    id_administrador BIGINT,
    FOREIGN KEY (id_administrador) REFERENCES Administrador(id_administrador)
);

CREATE TABLE Personal_No_Asignado (
    id_personal_no_asignado BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    apellido_paterno VARCHAR(255),
    apellido_materno VARCHAR(255),
    correo_electronico VARCHAR(255),
    tipo VARCHAR(50),
    telefono VARCHAR(20)
);

CREATE TABLE Solicitud_A_Hospital (
    id_solicitud_a_hospital BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    peticion TEXT,
    clues BIGINT,
    id_personal_no_asignado BIGINT,
    FOREIGN KEY (clues) REFERENCES Hospital(clues),
    FOREIGN KEY (id_personal_no_asignado) REFERENCES Personal_No_Asignado(id_personal_no_asignado)
);

CREATE TABLE Movimiento (
    id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    hora TIME,
    tipo VARCHAR(50),
    descripcion TEXT,
    id_personal BIGINT,
    FOREIGN KEY (id_personal) REFERENCES Personal(id_personal)
);

CREATE TABLE Padecimiento (
    id_padecimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255),
    gravedad VARCHAR(50),
    periodo_reposo VARCHAR(255)
);

CREATE TABLE Periodo_Padecimiento (
    id_periodo_padecimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    periodo_reposo VARCHAR(255),
    edad INT,
    gravedad VARCHAR(50),
    f_inicio DATE,
    f_fin DATE
);

CREATE TABLE Traslado (
    id_traslado BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    hora TIME,
    nss_paciente BIGINT,
    numero_cama BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente),
    FOREIGN KEY (numero_cama) REFERENCES Cama(numero_cama)
);

CREATE TABLE Indicaciones_Medicas (
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
    fecha DATE,
    medidas TEXT,
    pendientes TEXT,
    cuidados TEXT,
    nss_paciente BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente)
);

CREATE TABLE Nota_De_Evolucion (
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
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente)
);

CREATE TABLE Hoja_De_Enfermeria (
    id_hoja_de_enfermeria BIGINT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
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
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente)
);

CREATE TABLE Triage (
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
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente)
);

CREATE TABLE Historial (
    id_historial BIGINT AUTO_INCREMENT PRIMARY KEY,
    nss_paciente BIGINT,
    id_traslado BIGINT,
    id_procedimiento BIGINT,
    id_indicaciones_medicas BIGINT,
    id_nota_de_evolucion BIGINT,
    id_hoja_de_enfermeria BIGINT,
    id_triage BIGINT,
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente),
    FOREIGN KEY (id_traslado) REFERENCES Traslado(id_traslado),
    FOREIGN KEY (id_procedimiento) REFERENCES Procedimiento(id_procedimiento),
    FOREIGN KEY (id_indicaciones_medicas) REFERENCES Indicaciones_Medicas(id_indicaciones_medicas),
    FOREIGN KEY (id_nota_de_evolucion) REFERENCES Nota_De_Evolucion(id_nota_de_evolucion),
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES Hoja_De_Enfermeria(id_hoja_de_enfermeria),
    FOREIGN KEY (id_triage) REFERENCES Triage(id_triage)
);

CREATE TABLE Uso_Medicamento (
    id_uso_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT,
    id_medicamento BIGINT,
    id_hoja_de_enfermeria BIGINT,
    FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id_medicamento),
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES Hoja_De_Enfermeria(id_hoja_de_enfermeria)
);

CREATE TABLE Solicitud_Medicamento (
    id_solicitud_medicamento BIGINT AUTO_INCREMENT PRIMARY KEY,
    concentracion VARCHAR(50),
    cantidad_presentacion INT,
    nombre VARCHAR(255),
    marca VARCHAR(255),
    tipo VARCHAR(50),
    id_hoja_de_enfermeria BIGINT,
    FOREIGN KEY (id_hoja_de_enfermeria) REFERENCES Hoja_De_Enfermeria(id_hoja_de_enfermeria)
);

CREATE TABLE Medicina_Pers (
    id_medicina_pers BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud_medicamento BIGINT,
    concentracion VARCHAR(50),
    caducidad DATE,
    cantidad_stock INT,
    tipo VARCHAR(50),
    marca VARCHAR(255),
    nombre VARCHAR(255),
    cantidad_presentacion INT,
    nss_paciente BIGINT,
    FOREIGN KEY (id_solicitud_medicamento) REFERENCES Solicitud_Medicamento(id_solicitud_medicamento),
    FOREIGN KEY (nss_paciente) REFERENCES Paciente(nss_paciente)
);