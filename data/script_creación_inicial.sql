USE GD2C2024;
-- CREATE SCHEMA NJRE;
GO

-------------------------------------------------------------------------------------------------
-- CREACIÓN DE TABLAS
-------------------------------------------------------------------------------------------------
CREATE TABLE NJRE.almacen (
    almacen_id INT PRIMARY KEY, -- No la hago autoincremental, ya que posee un codigo en la tabla maestra
    almacen_docimilio_id INT NOT NULL FOREIGN KEY REFERENCES NJRE.domicilio(domicilio_id),
    almacen_nombre NVARCHAR(50) NULL,
    almacen_costo_dia DECIMAL(18, 2) NOT NULL 
);

CREATE TABLE NJRE.historial_costo_almacen (
    historialCostoAlmacen_id INT PRIMARY KEY IDENTITY(1,1),
    historialCostoAlmacen_almacen_id INT NOT NULL FOREIGN KEY REFERENCES NJRE.almacen(almacen_id),
    historialCostoAlmacen_fecha DATE NULL,
    historialCostoAlmacen_costo_dia DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.venta (
    venta_id DECIMAL(18, 0) PRIMARY KEY, -- No la hago autoincremental, ya que posee un codigo en la tabla maestra
    venta_cliente_id INT NOT NULL FOREIGN KEY REFERENCES NJRE.cliente(cliente_id),
    venta_fecha DATETIME NOT NULL,
    venta_total DECIMAL(10, 2) NOT NULL
);

CREATE TABLE NJRE.detalle_venta (
    detalleVenta_id INT PRIMARY KEY IDENTITY(1,1),
    detalleVenta_venta_id DECIMAL(18, 0) NOT NULL FOREIGN KEY REFERENCES NJRE.venta(venta_id),
    detalleVenta_publicacion_id INT NOT NULL FOREIGN KEY REFERENCES NJRE.publicacion(publicacion_id),
    detalleVenta_precio DECIMAL(18, 2) NOT NULL,
    detalleVenta_cantidad DECIMAL(18, 0) NOT NULL,
    detalleVenta_subtotal DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.cliente (
    cliente_id INT PRIMARY KEY IDENTITY(1,1),
    cliente_usuario_id INT NOT NULL FOREIGN KEY REFERENCES NJRE.usuario(usuario_id),
    cliente_nombre NVARCHAR(50) NOT NULL,
    cliente_apellido NVARCHAR(50) NOT NULL,
    cliente_fecha_nacimiento DATE NOT NULL,
    cliente_dni DECIMAL(18, 0) NOT NULL
);

CREATE TABLE NJRE.usuario (
    usuario_id INT PRIMARY KEY IDENTITY(1,1),
    usuario_nombre NVARCHAR(50) NOT NULL UNIQUE, -- Consulta, les parece bien que sea unique? Ro: creo que sí pero habría que ver cómo lo armamos por si hay clientes con el mismo nombre, por ejemplo (ya q no existe nombre de usuario en la tabla maestra)
    usuario_pass NVARCHAR(50) NOT NULL,
    usuario_fecha_creacion DATE NOT NULL,
    usuario_mail NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.usuario_domicilio (
    usuarioDomicilio_usuario_id INT NOT NULL,
    usuarioDomicilio_domicilio_id INT NOT NULL,
    PRIMARY KEY (usuarioDomicilio_usuario_id, usuarioDomicilio_domicilio_id),
    FOREIGN KEY (usuarioDomicilio_usuario_id) REFERENCES NJRE.usuario(usuario_id),
    FOREIGN KEY (usuarioDomicilio_domicilio_id) REFERENCES NJRE.domicilio(domicilio_id)
);

CREATE TABLE NJRE.pago(
	pago_id INT IDENTITY,
	pago_medioPago_id INT NOT NULL,
	pago_venta_id INT NOT NULL,
	pago_fecha DATE NOT NULL,
	pago_importe DECIMAL(18,2) NOT NULL
)

CREATE TABLE NJRE.detalle_pago(
	detallePago_id INT IDENTITY,
    detallePago_pago_id INT NOT NULL,
    detallePago_tarjeta_nro  NVARCHAR(50),
    detallePago_tarjeta_fecha_vencimiento DATE,
    detallePago_cant_cuotas DECIMAL(18, 0),
    detallePago_cvu NCHAR(22),
    detallePago_importe_parcial DECIMAL(18, 2) NOT NULL
)

CREATE TABLE NJRE.medio_pago(
	medioPago_id INT IDENTITY,
	medioPago_tipoMedioPago_id INT NOT NULL,
	medioPago_nombre NVARCHAR(50) NOT NULL
)

CREATE TABLE NJRE.tipo_medio_pago(
	tipoMedioPago_id INT IDENTITY,
	tipoMedioPago_nombre NVARCHAR(50) NOT NULL
)

CREATE TABLE NJRE.domicilio(
	domicilio_id INT IDENTITY,
	domicilio_localidad INT NOT NULL,
	domicilio_provincia NCHAR(2) NOT NULL,
	domicilio_calle NVARCHAR(50) NOT NULL,
	domicilio_nro_calle DECIMAL(18, 0) NOT NULL,
	domicilio_piso DECIMAL(18, 0),
	domicilio_depto NVARCHAR(50),
	domicilio_cp NVARCHAR(50)
)

CREATE TABLE NJRE.localidad(
	localidad_id INT IDENTITY,
	localidad_nombre NVARCHAR(50) NOT NULL
)

CREATE TABLE NJRE.provincia(
	provincia_id NCHAR(2) NOT NULL,
	provincia_nombre NVARCHAR(50) NOT NULL
)


-------------------------------------------------------------------------------------------------
-- CREACIÓN DE PRIMARY KEYS
-------------------------------------------------------------------------------------------------
ALTER TABLE NJRE.pago
ADD CONSTRAINT PK_Pago PRIMARY KEY (pago_id)

ALTER TABLE NJRE.detalle_pago
ADD CONSTRAINT PK_DetallePago PRIMARY KEY (detallePago_id)

ALTER TABLE NJRE.medio_pago
ADD CONSTRAINT PK_MedioPago PRIMARY KEY (medioPago_id)

ALTER TABLE NJRE.tipo_medio_pago
ADD CONSTRAINT PK_TipoMedioPago PRIMARY KEY (tipoMedioPago_id)

ALTER TABLE NJRE.domicilio
ADD CONSTRAINT PK_Domicilio PRIMARY KEY (domicilio_id)

ALTER TABLE NJRE.localidad
ADD CONSTRAINT PK_Localidad PRIMARY KEY (localidad_id)

ALTER TABLE NJRE.provincia
ADD CONSTRAINT PK_Provincia PRIMARY KEY (provincia_id)


-------------------------------------------------------------------------------------------------
-- CREACIÓN DE FOREIGN KEYS
-------------------------------------------------------------------------------------------------
ALTER TABLE NJRE.pago
ADD 
	CONSTRAINT FK_Pago_MedioPago FOREIGN KEY (pago_medioPago_id) REFERENCES NJRE.medio_pago (medioPago_id),
	CONSTRAINT FK_Pago_Venta FOREIGN KEY (pago_venta_id) REFERENCES NJRE.venta (venta_id)
	
ALTER TABLE NJRE.detalle_pago
ADD 
	CONSTRAINT FK_DetallePago_Pago FOREIGN KEY (detallePago_pago_id) REFERENCES NJRE.pago (pago_id)
	
ALTER TABLE NJRE.medio_pago
ADD 
	CONSTRAINT FK_MedioPago_TipoMedioPago FOREIGN KEY (medioPago_tipoMedioPago_id) REFERENCES NJRE.tipo_medio_pago (tipoMedioPago_id)

ALTER TABLE NJRE.domicilio
ADD 
	CONSTRAINT FK_Domicilio_Localidad FOREIGN KEY (domicilio_localidad) REFERENCES NJRE.localidad (localidad_id),
	CONSTRAINT FK_Domicilio_Provincia FOREIGN KEY (domicilio_provincia) REFERENCES NJRE.provincia (provincia_id)
