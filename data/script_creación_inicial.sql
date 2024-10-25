-------------------------------------------------------------------------------------------------
-- CREACION DE ESQUEMA
-------------------------------------------------------------------------------------------------

USE GD2C2024;
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'NJRE')
BEGIN 
	EXEC ('CREATE SCHEMA NJRE')
END
GO


-------------------------------------------------------------------------------------------------
-- CREACION DE TABLAS
-------------------------------------------------------------------------------------------------

CREATE TABLE NJRE.publicacion (
    publicacion_id DECIMAL(18, 0),  
    publicacion_producto_id INT NOT NULL,
    publicacion_vendedor_id INT NOT NULL,
    publicacion_almacen_id INT NOT NULL,
    publicacion_descripcion NVARCHAR(50),
    publicacion_fecha_inicio DATE NOT NULL,
    publicacion_fecha_fin DATE NOT NULL,
    publicacion_stock DECIMAL(18, 0) NOT NULL,
    publicacion_precio DECIMAL(18, 2) NOT NULL,
    publicacion_costo DECIMAL(18, 2) NOT NULL,
    publicacion_porc_venta DECIMAL(18, 2) NOT NULL,
    publicacion_fecha_modificacion DATE
);

CREATE TABLE NJRE.producto (
    producto_id  INT IDENTITY(1, 1),
    producto_marca_id INT NOT NULL,  
    producto_mod_id DECIMAL(18, 0) NOT NULL, 
    producto_subrubro_id INT NOT NULL,  
    producto_codigo NVARCHAR(50), 
    producto_descripcion NVARCHAR(50) NOT NULL,  
    producto_precio DECIMAL(18, 2) NOT NULL,  
    producto_fecha_alta DATE NOT NULL, 
    producto_fecha_modificacion DATE 
);

CREATE TABLE NJRE.marca (
    marca_id INT IDENTITY(1, 1),
    marca_descripcion NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.modelo (
    modelo_id DECIMAL(18, 0), -- Posee un codigo en la tabla maestra
    modelo_descripcion NVARCHAR(50) NOT NULL,
);

CREATE TABLE NJRE.subrubro (
    subrubro_id INT IDENTITY(1,1),
    subrubro_rubro_id INT NOT NULL,
    subrubro_descripcion NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.rubro (
    rubro_id INT IDENTITY(1,1),
    rubro_descripcion NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.vendedor (
    vendedor_id INT IDENTITY(1,1),
    vendedor_usuario_id INT NOT NULL,
    vendedor_razon_social NVARCHAR(50) NOT NULL,
    vendedor_cuit NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.almacen (
    almacen_id DECIMAL(18, 0), -- Posee un código en la tabla maestra
    almacen_docimilio_id INT NOT NULL,
    almacen_nombre NVARCHAR(50) NULL,
    almacen_costo_dia DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.historial_costo_almacen (
    historialCostoAlmacen_id INT IDENTITY(1,1), 
    historialCostoAlmacen_almacen_id INT NOT NULL,
    historialCostoAlmacen_fecha DATE NULL,
    historialCostoAlmacen_costo_dia DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.venta (
    venta_id DECIMAL(18, 0), 
    venta_cliente_id INT NOT NULL, 
    venta_fecha DATETIME NOT NULL,
    venta_total DECIMAL(10, 2) NOT NULL
);

CREATE TABLE NJRE.detalle_venta (
    detalleVenta_id INT IDENTITY(1,1), 
    detalleVenta_venta_id DECIMAL(18, 0) NOT NULL, 
    detalleVenta_publicacion_id INT NOT NULL, 
    detalleVenta_precio DECIMAL(18, 2) NOT NULL,
    detalleVenta_cantidad DECIMAL(18, 0) NOT NULL,
    detalleVenta_subtotal DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.cliente (
    cliente_id INT IDENTITY(1,1), 
    cliente_usuario_id INT NOT NULL, 
    cliente_nombre NVARCHAR(50) NOT NULL,
    cliente_apellido NVARCHAR(50) NOT NULL,
    cliente_fecha_nacimiento DATE NOT NULL,
    cliente_dni DECIMAL(18, 0) NOT NULL
);

CREATE TABLE NJRE.usuario (
    usuario_id INT IDENTITY(1,1),
    usuario_nombre NVARCHAR(50) NOT NULL,
    usuario_pass NVARCHAR(50) NOT NULL,
    usuario_fecha_creacion DATE NOT NULL,
    usuario_mail NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.usuario_domicilio (
    usuarioDomicilio_usuario_id INT NOT NULL,
    usuarioDomicilio_domicilio_id INT NOT NULL,
);

CREATE TABLE NJRE.pago (
	pago_id INT IDENTITY(1, 1),
	pago_medioPago_id INT NOT NULL,
	pago_venta_id INT NOT NULL,
	pago_fecha DATE NOT NULL,
	pago_importe DECIMAL(18,2) NOT NULL
);

CREATE TABLE NJRE.detalle_pago (
	detallePago_id INT IDENTITY(1, 1),
    detallePago_pago_id INT NOT NULL,
    detallePago_tarjeta_nro  NVARCHAR(50),
    detallePago_tarjeta_fecha_vencimiento DATE,
    detallePago_cant_cuotas DECIMAL(18, 0),
    detallePago_cvu NCHAR(22),
    detallePago_importe_parcial DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.medio_pago (
	medioPago_id INT IDENTITY(1, 1),
	medioPago_tipoMedioPago_id INT NOT NULL,
	medioPago_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.tipo_medio_pago (
	tipoMedioPago_id INT IDENTITY(1, 1),
	tipoMedioPago_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.domicilio (
	domicilio_id INT IDENTITY(1, 1),
	domicilio_localidad INT NOT NULL,
	domicilio_provincia NCHAR(2) NOT NULL,
	domicilio_calle NVARCHAR(50) NOT NULL,
	domicilio_nro_calle DECIMAL(18, 0) NOT NULL,
	domicilio_piso DECIMAL(18, 0),
	domicilio_depto NVARCHAR(50),
	domicilio_cp NVARCHAR(50)
);

CREATE TABLE NJRE.localidad (
	localidad_id INT IDENTITY(1, 1),
	localidad_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.provincia (
	provincia_id NCHAR(2) NOT NULL,
	provincia_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.envio (
	envio_id INT IDENTITY(1, 1) NOT NULL ,
	envio_venta_id DECIMAL(18,0) NOT NULL,
	envio_domicilio_id INT NOT NULL,
	envio_tipoEnvio_id INT NOT NULL,
	envio_fecha_programada DATE NOT NULL,
	envio_hora_inicio DECIMAL(18,0),
	envio_hora_fin DECIMAL(18,0),
	envio_costo DECIMAL(18,2) NOT NULL,
	envio_fecha_entrega DATETIME,
	envio_estado NVARCHAR(20) NOT NULL, 
	CONSTRAINT CHK_EnvioEstado CHECK (envio_estado IN ('En preparación', 'En camino', 'Entregado'))
);

CREATE TABLE NJRE.tipo_envio (
	tipoEnvio_id INT IDENTITY(1, 1) NOT NULL,
	tipoEnvio_medio NVARCHAR(50) NOT NULL,
);

CREATE TABLE NJRE.historial_estado_envio (
	historialEstadoEnvio_id INT IDENTITY(1, 1) NOT NULL,
	historialEstadoEnvio_envio_id INT NOT NULL,
	historialEstadoEnvio_fecha DATE NOT NULL,
	historialEstadoEnvio_estado NVARCHAR(20) NOT NULL,
	CONSTRAINT CHK_HistorialEstadoEnvioEstado CHECK (historialEstadoEnvio_estado IN ('En preparación', 'En camino', 'Entregado'))
);

CREATE TABLE NJRE.factura (
	factura_id DECIMAL(18,0) NOT NULL, -- Posee un número en la tabla maestra
	factura_usuario INT NOT NULL,
	factura_fecha DATE NOT NULL,
	factura_total DECIMAL(18,2) NOT NULL,
);

CREATE TABLE NJRE.factura_detalle (
	facturaDetalle_id INT IDENTITY(1, 1) NOT NULL,
	facturaDetalle_factura_id DECIMAL(18,0) NOT NULL,
	facturaDetalle_publicacion INT NOT NULL,
	facturaDetalle_concepto_id INT NOT NULL,
	facturaDetalle_precio_unitario DECIMAL(18,2) NOT NULL,
	facturaDetalle_cantidad DECIMAL(18,0) NOT NULL,
	facturaDetalle_subtotal DECIMAL(18,2) NOT NULL,
);

CREATE TABLE NJRE.concepto (
	concepto_id INT IDENTITY(1, 1) NOT NULL,
	concepto_nombre NVARCHAR(50) NOT NULL,
);


-------------------------------------------------------------------------------------------------
-- CREACION DE PRIMARY KEYS
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

ALTER TABLE NJRE.envio 
ADD CONSTRAINT PK_Envio PRIMARY KEY (envio_id);

ALTER TABLE NJRE.tipo_envio 
ADD CONSTRAINT PK_TipoEnvio PRIMARY KEY (tipoEnvio_id);

ALTER TABLE NJRE.historial_estado_envio 
ADD CONSTRAINT PK_HistorialEstadoEnvio PRIMARY KEY (historialEstadoEnvio_id);

ALTER TABLE NJRE.factura 
ADD CONSTRAINT PK_Factura PRIMARY KEY (factura_id);

ALTER TABLE NJRE.factura_detalle 
ADD CONSTRAINT PK_FacturaDetalle PRIMARY KEY (facturaDetalle_id);

ALTER TABLE NJRE.concepto 
ADD CONSTRAINT PK_Concepto PRIMARY KEY (concepto_id);

ALTER TABLE NJRE.usuario_domicilio 
ADD CONSTRAINT PK_UsuarioDomicilio PRIMARY KEY (usuarioDomicilio_usuario_id, usuarioDomicilio_domicilio_id);

ALTER TABLE NJRE.publicacion
ADD CONSTRAINT PK_Publicacion PRIMARY KEY (publicacion_id)

ALTER TABLE NJRE.producto
ADD CONSTRAINT PK_Publicacion PRIMARY KEY (producto_id)

ALTER TABLE NJRE.marca
ADD CONSTRAINT PK_Marca PRIMARY KEY (marca_id)

ALTER TABLE NJRE.modelo
ADD CONSTRAINT PK_Modelo PRIMARY KEY (modelo_id)

ALTER TABLE NJRE.subrubro
ADD CONSTRAINT PK_Subrubro PRIMARY KEY (subrubro_id)

ALTER TABLE NJRE.rubro
ADD CONSTRAINT PK_Rubro PRIMARY KEY (rubro_id)

ALTER TABLE NJRE.vendedor
ADD CONSTRAINT PK_Vendedor PRIMARY KEY (vendedor_id)

ALTER TABLE NJRE.almacen
ADD CONSTRAINT PK_Almacen PRIMARY KEY (almacen_id);

ALTER TABLE NJRE.historial_costo_almacen
ADD CONSTRAINT PK_HistorialCostoAlmacen PRIMARY KEY (historialCostoAlmacen_id);   

ALTER TABLE NJRE.venta
ADD CONSTRAINT PK_Venta PRIMARY KEY (venta_id);

ALTER TABLE NJRE.detalle_venta
ADD CONSTRAINT PK_DetalleVenta PRIMARY KEY (detalleVenta_id);

ALTER TABLE NJRE.cliente
ADD CONSTRAINT PK_Cliente PRIMARY KEY (cliente_id);

ALTER TABLE NJRE.usuario
ADD CONSTRAINT PK_Usuario PRIMARY KEY (usuario_id);


-------------------------------------------------------------------------------------------------
-- CREACION DE FOREIGN KEYS
-------------------------------------------------------------------------------------------------

ALTER TABLE NJRE.pago
ADD 
	CONSTRAINT FK_Pago_MedioPago FOREIGN KEY (pago_medioPago_id) REFERENCES NJRE.medio_pago (medioPago_id),
	CONSTRAINT FK_Pago_Venta FOREIGN KEY (pago_venta_id) REFERENCES NJRE.venta (venta_id)
	
ALTER TABLE NJRE.detalle_pago
ADD CONSTRAINT FK_DetallePago_Pago FOREIGN KEY (detallePago_pago_id) REFERENCES NJRE.pago (pago_id)
	
ALTER TABLE NJRE.medio_pago
ADD CONSTRAINT FK_MedioPago_TipoMedioPago FOREIGN KEY (medioPago_tipoMedioPago_id) REFERENCES NJRE.tipo_medio_pago (tipoMedioPago_id)

ALTER TABLE NJRE.domicilio
ADD 
	CONSTRAINT FK_Domicilio_Localidad FOREIGN KEY (domicilio_localidad) REFERENCES NJRE.localidad (localidad_id),
	CONSTRAINT FK_Domicilio_Provincia FOREIGN KEY (domicilio_provincia) REFERENCES NJRE.provincia (provincia_id)

ALTER TABLE NJRE.envio 
ADD 
    CONSTRAINT FK_Envio_TipoEnvio FOREIGN KEY (envio_tipoEnvio_id) REFERENCES NJRE.tipo_envio,
    CONSTRAINT FK_Envio_Domicilio FOREIGN KEY (envio_domicilio_id) REFERENCES NJRE.domicilio,
    CONSTRAINT FK_Envio_Venta FOREIGN KEY (envio_venta_id) REFERENCES NJRE.venta


ALTER TABLE NJRE.historial_estado_envio 
ADD CONSTRAINT FK_Historial_Envio FOREIGN KEY (historialEstadoEnvio_envio_id) REFERENCES NJRE.envio;

ALTER TABLE NJRE.factura 
ADD CONSTRAINT FK_Factura_FacturaDetalle FOREIGN KEY (factura_usuario) REFERENCES NJRE.factura_detalle;

ALTER TABLE NJRE.factura_detalle 
ADD 
    CONSTRAINT FK_FacturaDetalle_Concepto FOREIGN KEY (facturaDetalle_concepto_id) REFERENCES NJRE.concepto;
    CONSTRAINT FK_FacturaDetalle_Factura FOREIGN KEY (facturaDetalle_factura_id) REFERENCES NJRE.factura;
    CONSTRAINT FK_FacturaDetalle_Publicacion FOREIGN KEY (facturaDetalle_publicacion) REFERENCES NJRE.publicacion;

ALTER TABLE NJRE.usuario_domicilio 
ADD CONSTRAINT FK_UsuarioDomicilio_Usuario FOREIGN KEY (usuarioDomicilio_usuario_id) REFERENCES NJRE.usuario(usuario_id);

ALTER TABLE NJRE.usuario_domicilio 
ADD CONSTRAINT FK_UsuarioDomicilio_Domicilio FOREIGN KEY (usuarioDomicilio_domicilio_id) REFERENCES NJRE.domicilio(domicilio_id);

ALTER TABLE NJRE.publicacion
ADD 
	CONSTRAINT FK_Publicacion_producto FOREIGN KEY (publicacion_producto_id) REFERENCES NJRE.tipo_medio_pago (producto_id),
    CONSTRAINT FK_Publicacion_vendedor FOREIGN KEY (publicacion_vendedor_id) REFERENCES NJRE.tipo_medio_pago (vendedor_id),
    CONSTRAINT FK_Publicacion_almacen_id FOREIGN KEY (publicacion_almacen_id) REFERENCES NJRE.tipo_medio_pago (almacen_id);

ALTER TABLE NJRE.producto
ADD 
    CONSTRAINT FK_Producto_marca FOREIGN KEY (producto_marca_id) REFERENCES NJRE.tipo_medio_pago (marca_id),
    CONSTRAINT FK_Producto_mod FOREIGN KEY (producto_mod_id) REFERENCES NJRE.tipo_medio_pago (modelo_id),
    CONSTRAINT FK_Producto_subrubro FOREIGN KEY (publicacion_producto_id) REFERENCES NJRE.tipo_medio_pago (subrubro_id)

ALTER TABLE NJRE.subrubro 
ADD CONSTRAINT FK_subrubro_rubro FOREIGN KEY (subrubro_rubro_id) REFERENCES NJRE.tipo_medio_pago (rubro_id)

ALTER TABLE NJRE.vendedor 
ADD  CONSTRAINT FK_Vendedor_Usuario FOREIGN KEY (vendedor_usuario_id) REFERENCES NJRE.usuario(usuario_id)

ALTER TABLE NJRE.almacen 
ADD CONSTRAINT FK_Almacen_Domicilio FOREIGN KEY (almacen_docimilio_id) REFERENCES NJRE.domicilio(domicilio_id)

ALTER TABLE NJRE.historial_costo_almacen 
ADD CONSTRAINT FK_HistorialCostoAlmacen_Almacen FOREIGN KEY (historialCostoAlmacen_almacen_id) REFERENCES NJRE.almacen(almacen_id)

ALTER TABLE NJRE.venta
ADD CONSTRAINT FK_Venta_Cliente FOREIGN KEY (venta_cliente_id) REFERENCES NJRE.cliente(cliente_id)

ALTER TABLE NJRE.detalle_venta
ADD     
    CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (detalleVenta_venta_id) REFERENCES NJRE.venta(venta_id),
    CONSTRAINT FK_DetalleVenta_Publicacion FOREIGN KEY (detalleVenta_publicacion_id) REFERENCES NJRE.publicacion(publicacion_id)

ALTER TABLE NJRE.cliente
ADD CONSTRAINT FK_Cliente_Usuario FOREIGN KEY (cliente_usuario_id) REFERENCES NJRE.usuario(usuario_id)

GO


-------------------------------------------------------------------------------------------------
-- FUNCIONES PARA LA MIGRACION DE DATOS
-------------------------------------------------------------------------------------------------

/*
CREATE FUNCTION NJRE.obtener_id_tipoMedioPago(@nombre NVARCHAR(50)) AS
BEGIN
    RETURN (SELECT TOP 1 tipoMedioPago_id FROM NJRE.tipo_medio_pago WHERE tipoMedioPago_nombre = @nombre)
END
*/


-------------------------------------------------------------------------------------------------
-- PROCEDURES PARA LA MIGRACION DE DATOS
-------------------------------------------------------------------------------------------------

CREATE PROCEDURE NJRE.migrar_tipoMedioPago AS
BEGIN
    INSERT INTO NJRE.tipo_medio_pago (tipoMedioPago_nombre) 
    SELECT DISTINCT pago_tipo_medio_pago 
    FROM gd_esquema.Maestra 
    WHERE pago_tipo_medio_pago IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_medioPago AS
BEGIN
    INSERT INTO NJRE.medio_pago (medioPago_tipoMedioPago_id, medioPago_nombre) 
    SELECT DISTINCT tipoMedioPago_id, pago_medio_pago 
    FROM gd_esquema.Maestra 
        JOIN NJRE.tipo_medio_pago ON tipoMedioPago_nombre = pago_tipo_medio_pago
    WHERE pago_medio_pago IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_provincia AS
BEGIN
INSERT INTO NJRE.provincia (provincia_id, provincia_nombre) VALUES
    ('BA', 'Buenos Aires'),
    ('CA', 'Catamarca'),
    ('CH', 'Chaco'),
    ('CU', 'Chubut'),
    ('CO', 'Córdoba'),
    ('CR', 'Corrientes'),
    ('ER', 'Entre Ríos'),
    ('FO', 'Formosa'),
    ('JU', 'Jujuy'),
    ('LP', 'La Pampa'),
    ('LR', 'La Rioja'),
    ('ME', 'Mendoza'),
    ('MI', 'Misiones'),
    ('NE', 'Neuquén'),
    ('RN', 'Río Negro'),
    ('SA', 'Salta'),
    ('SJ', 'San Juan'),
    ('SL', 'San Luis'),
    ('SC', 'Santa Cruz'),
    ('SF', 'Santa Fe'),
    ('SE', 'Santiago del Estero'),
    ('TF', 'Tierra del Fuego'),
    ('TU', 'Tucumán');
END
GO

CREATE PROCEDURE NJRE.migrar_localidad AS
BEGIN
    CREATE TABLE #tmp_localidad (nombre NVARCHAR(50))

    INSERT INTO #tmp_localidad
    SELECT DISTINCT cli_usuario_domicilio_provincia
    FROM gd_esquema.Maestra 
    WHERE cli_usuario_domicilio_provincia IS NOT NULL

    UNION
    
    SELECT DISTINCT ven_usuario_domicilio_provincia
    FROM gd_esquema.Maestra 
    WHERE ven_usuario_domicilio_provincia IS NOT NULL

    UNION

    SELECT DISTINCT almacen_localidad
    FROM gd_esquema.Maestra 
    WHERE almacen_localidad IS NOT NULL

    INSERT INTO NJRE.localidad (localidad_nombre) 
    SELECT DISTINCT nombre FROM #localidad

    DROP TABLE #tmp_localidad
END
GO

CREATE PROCEDURE NJRE.migrar_domicilio AS
BEGIN
    INSERT INTO NJRE.domicilio (domicilio_calle, domicilio_cp, domicilio_nro_calle, domicilio_piso, domicilio_depto, domicilio_provincia, domicilio_localidad)
        SELECT DISTINCT cli_usuario_domicilio_calle, cli_usuario_domicilio_cp, cli_usuario_domicilio_nro_calle, cli_usuario_domicilio_piso, cli_usuario_domicilio_depto, provincia_id, localidad_id
        FROM gd_esquema.Maestra 
            INNER JOIN NJRE.provincia ON cli_usuario_domicilio_provincia = provincia_nombre
            INNER JOIN NJRE.localidad ON cli_usuario_domicilio_localidad = localidad_nombre
        WHERE cli_usuario_domicilio_calle IS NOT NULL -- esta bien esto?
        UNION
        SELECT DISTINCT ven_usuario_domicilio_calle, ven_usuario_domicilio_cp, ven_usuario_domicilio_nro_calle, ven_usuario_domicilio_piso, ven_usuario_domicilio_depto, provincia_id, localidad_id
        FROM gd_esquema.Maestra 
            INNER JOIN NJRE.provincia ON cli_usuario_domicilio_provincia = provincia_nombre
            INNER JOIN NJRE.localidad ON cli_usuario_domicilio_localidad = localidad_nombre
        WHERE ven_usuario_domicilio_calle IS NOT NULL -- esta bien esto?

        -- poblar la tabla usuario_domicilio
END
GO

CREATE PROCEDURE NJRE.migrar_rubro AS
BEGIN
    INSERT INTO NJRE.rubro (rubro_descripcion)
    SELECT DISTINCT producto_rubro_descripcion
    FROM gd_esquema.Maestra 
    WHERE rubro_descripcion IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_subrubro AS
BEGIN
    INSERT INTO NJRE.subrubro (subrubro_rubro_id, subrubro_descripcion)
        SELECT DISTINCT n.rubro_id, producto_sub_rubro
        FROM gd_esquema.Maestra m
        JOIN NJRE.rubro n on n.producto_rubro_descripcion = m.producto_rubro_descripcion
        WHERE producto_sub_rubro IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_marca AS
BEGIN
    INSERT INTO NJRE.marca(marca_descripcion)
    SELECT DISTINCT producto_marca
    FROM gd_esquema.Maestra 
    WHERE producto_marca IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_modelo AS
BEGIN
    INSERT INTO NJRE.modelo (modelo_id, modelo_descripcion)
    SELECT DISTINCT producto_mod_codigo, producto_mod_descripcion
    FROM gd_esquema.Maestra 
    WHERE producto_mod_codigo IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_almacen AS
BEGIN
    INSERT INTO NJRE.almacen (almacen_id, almacen_docimilio_id, almacen_nombre, almacen_costo_dia)
    SELECT DISTINCT almacen_codigo, domicilio_id, almacen_calle + ' ' + CAST(almacen_nro_calle AS NVARCHAR), almacen_costo_dia_al
    FROM gd_esquema.Maestra 
        INNER JOIN NJRE.localidad ON localidad_nombre = almacen_localidad
        INNER JOIN NJRE.provincia ON provincia_nombre = almacen_provincia
        INNER JOIN NJRE.domicilio ON domicilio_calle = almacen_calle AND domicilio_nro_calle = almacen_nro_calle AND domicilio_localidad = localidad_id AND domicilio_provincia = provincia_id
    WHERE almacen_codigo IS NOT NULL

	INSERT INTO NJRE.historial_costo_almacen(historialCostoAlmacen_almacen_id, historialCostoAlmacen_fecha, historialCostoAlmacen_costo_dia)
	SELECT almacen_id, GETDATE(), almacen_costo_dia
	FROM NJRE.almacen	
END
GO

CREATE PROCEDURE NJRE.migrar_tipoEnvio AS
BEGIN
    INSERT INTO NJRE.tipo_envio (tipoEnvio_medio)
    SELECT DISTINCT envio_tipo
    FROM gd_esquema.Maestra 
    WHERE envio_tipo IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_concepto AS
BEGIN
    INSERT INTO NJRE.tipo_envio (concepto_nombre)
    SELECT DISTINCT factura_det_tipo
    FROM gd_esquema.Maestra 
    WHERE factura_det_tipo IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_usuario AS
BEGIN
   INSERT INTO NJRE.usuario (usuario_nombre, usuario_pass, usuario_fecha_creacion, usuario_mail)
   SELECT DISTINCT cli_usuario_nombre, cli_usuario_pass, cli_usuario_fecha_creacion, cliente_mail
   FROM gd_esquema.Maestra 
   WHERE cli_usuario_nombre IS NOT NULL 
   UNION
   SELECT DISTINCT ven_usuario_nombre, ven_usuario_pass, ven_usuario_fecha_creacion, vendedor_mail
   FROM gd_esquema.Maestra 
   WHERE ven_usuario_nombre IS NOT NULL 
END
GO

CREATE PROCEDURE NJRE.migrar_producto AS
BEGIN
    INSERT INTO NJRE.producto (producto_marca_id, producto_mod_id, producto_subrubro_id, producto_codigo, producto_precio, producto_fecha_alta)
    SELECT marca_id, producto_mod_codigo, subrubro_id, producto_codigo, producto_precio, MIN(publicacion_fecha)
    FROM gd_esquema.Maestra 
    INNER JOIN NJRE.marca on marca_nombre = producto_marca
    INNER JOIN NJRE.subrubro on subrubro_descripcion = producto_sub_rubro and subrubro_rubro_id = producto_mod_codigo
    WHERE producto_codigo IS NOT NULL
    group by producto_marca, producto_mod_codigo, producto_sub_rubro, producto_codigo, producto_precio
END
GO

CREATE PROCEDURE NJRE.migrar_envio AS
BEGIN
    INSERT INTO NJRE.envio (envio_venta_id, envio_domicilio_id, envio_tipoEnvio_id, envio_fecha_programada, envio_hora_inicio, envio_hora_fin, envio_costo, envio_fecha_entrega, envio_estado)
    SELECT DISTINCT  venta_codigo, domicilio_id, envio_tipo, envio_fecha_prgramada, envio_hora_inicio, envio_hora_fin, envio_costo, envio_fecha_entrega, 'MARGE' -- arreglar
    FROM gd_esquema.Maestra m
        INNER JOIN NJRE.localidad ON localidad_nombre = cli_usudomicilio_localidad
        INNER JOIN NJRE.provincia ON provincia_nombre = almacen_provincia
        INNER JOIN NJRE.domicilio ON domicilio_calle = almacen_calle AND domicilio_nro_calle = almacen_nro_calle AND domicilio_localidad = localidad_id AND domicilio_provincia = provincia_id
    WHERE producto_codigo IS NOT NULL
END
GO

CREATE PROCEDURE NJRE.migrar_publicacion AS
BEGIN
    INSERT INTO NJRE.publicacion (publicacion_id, publicacion_producto_id, publicacion_vendedor_id, publicacion_almacen_id, 
        publicacion_descripcion, publicacion_fecha_inicio, publicacion_fecha_fin, publicacion_stock, publicacion_precio,
        publicacion_costo, publicacion_porc_venta)
    SELECT DISTINCT publicacion_codigo, producto_id, vendedor_id, almacen_id, 
		PUBLICACION_DESCRIPCION, PUBLICACION_FECHA, PUBLICACION_FECHA_V, PUBLICACION_STOCK, PUBLICACION_PRECIO,
		PUBLICACION_COSTO, PUBLICACION_PORC_VENTA
    FROM gd_esquema.Maestra m
        INNER JOIN NJRE.subrubro ON subrubro_descripcion = producto_sub_rubro and subrubro_rubro_id = producto_mod_codigo
        INNER JOIN NJRE.marca ON marca_nombre = producto_marca
        INNER JOIN NJRE.producto ON producto_marca_id = marca_id and producto_subrubro_id = subrubro_id
        INNER JOIN NJRE.vendedor n ON n.vendedor_razon_social = m.vendedor_razon_social
        INNER JOIN NJRE.almacen ON almacen_id = almacen_codigo
    WHERE publicacion_codigo is not null
		and PRODUCTO_CODIGO is not null
END
GO

CREATE PROCEDURE NJRE.migrar_envio AS
BEGIN
	-- TODO: acá agregar la migración de envío o7
	
	INSERT INTO NJRE.historial_estado_envio(historialEstadoEnvio_envio_id, historialEstadoEnvio_fecha, historialEstadoEnvio_estado)
	SELECT envio_id, envio_fecha_programada, 'En preparación' -- todos los envíos tienen fecha para el 2025 recién, por eso directamente se le pone este estado
	FROM NJRE.envio
END
GO