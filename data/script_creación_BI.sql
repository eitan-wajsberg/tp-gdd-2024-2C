-------------------------------------------------------------------------------------------------
-- USO DE ESQUEMA
-------------------------------------------------------------------------------------------------

USE GD2C2024;
GO


-------------------------------------------------------------------------------------------------
-- PROCEDURES AUXILIARES
-------------------------------------------------------------------------------------------------

IF OBJECT_ID('NJRE.BI_borrar_fks') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_borrar_fks
GO 
CREATE PROCEDURE NJRE.BI_borrar_fks AS
BEGIN
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR 
    SELECT 'ALTER TABLE ' 
        + object_schema_name(k.parent_object_id) 
        + '.[' + Object_name(k.parent_object_id) 
        + '] DROP CONSTRAINT ' + k.NAME query 
    FROM sys.foreign_keys k
    WHERE Object_name(k.parent_object_id) LIKE 'BI_%'

    OPEN query_cursor 
    FETCH NEXT FROM query_cursor INTO @query 
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
        EXEC sp_executesql @query 
        FETCH NEXT FROM query_cursor INTO @query 
    END

    CLOSE query_cursor 
    DEALLOCATE query_cursor 
END
GO 

IF OBJECT_ID('NJRE.BI_borrar_tablas') IS NOT NULL 
  DROP PROCEDURE NJRE.BI_borrar_tablas
GO 
CREATE PROCEDURE NJRE.BI_borrar_tablas AS
BEGIN
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
        SELECT 'DROP TABLE NJRE.' + name
        FROM  sys.tables 
        WHERE schema_id = (
			SELECT schema_id 
			FROM sys.schemas
			WHERE name = 'NJRE'
		) AND name LIKE 'BI_%'
    
    OPEN query_cursor 
    FETCH NEXT FROM query_cursor INTO @query 
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
        EXEC sp_executesql @query 
        FETCH NEXT FROM query_cursor INTO @query 
    END 

    CLOSE query_cursor 
    DEALLOCATE query_cursor
END
GO 

IF OBJECT_ID('NJRE.BI_borrar_procedimientos') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_borrar_procedimientos
GO 
CREATE PROCEDURE NJRE.BI_borrar_procedimientos AS
BEGIN
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
        SELECT 'DROP PROCEDURE NJRE.' + name
        FROM  sys.procedures 
        WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'NJRE') AND name LIKE 'bi_migrar_%'
    
    OPEN query_cursor 
    FETCH NEXT FROM query_cursor INTO @query 
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
        EXEC sp_executesql @query 
        FETCH NEXT FROM query_cursor INTO @query 
    END 

    CLOSE query_cursor 
    DEALLOCATE query_cursor 
END
GO 

-------------------------------------------------------------------------------------------------
-- ELIMINACION DE TABLAS, FKS Y PROCEDURES
-------------------------------------------------------------------------------------------------

EXEC NJRE.BI_borrar_fks;
EXEC NJRE.BI_borrar_tablas;
EXEC NJRE.BI_borrar_procedimientos;

GO

-------------------------------------------------------------------------------------------------
-- CREACION DE TABLAS
-------------------------------------------------------------------------------------------------

-- Hechos

CREATE TABLE NJRE.BI_hecho_venta (
    hechoVenta_tiempo_id INT NOT NULL,
    hechoVenta_ubicacionAlmacen_id INT NOT NULL,
    hechoVenta_ubicacionCliente_id INT NOT NULL,
    hechoVenta_rubro_id INT NOT NULL,
    hechoVenta_rangoEtarioCliente_id INT NOT NULL,
    hechoVenta_cantidadVentas DECIMAL(18, 0) NOT NULL,
    hechoRubro_totalVentas DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_publicacion (
    hechoPublicacion_tiempo_id INT NOT NULL,
    hechoPublicacion_subrubro_id INT NOT NULL,
    hechoPublicacion_marca_id INT NOT NULL,
    hechoPublicacion_totalDiasPublicaciones DECIMAL(18, 0) NOT NULL,
    hechoPublicacion_cantidadStockTotal DECIMAL(18, 0) NOT NULL,
	hechoPublicacion_cantidadPublicaciones DECIMAL(18, 0) NOT NULL,
);

CREATE TABLE NJRE.BI_hecho_pago (
    hechoPago_tipoMedioPago_id INT NOT NULL,
    hechoPago_tiempo_id INT NOT NULL,
    hechoPago_ubicacionCliente_id INT NOT NULL,
    hechoPago_cuota_id INT NOT NULL,
    hechoPago_importeTotalCuotas DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_factura (
    hechoFactura_tiempo_id INT NOT NULL,
    hechoFactura_concepto_id INT NOT NULL,
    hechoFactura_ubicacionVendedor_id INT NOT NULL,
    hechoFactura_porcentajeFacturacion DECIMAL(18, 2) NOT NULL,
    hechoFactura_montoFacturado DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_envio (
    hechoEnvio_tiempo_id INT NOT NULL,
    hechoEnvio_ubicacionAlmacen_id INT NOT NULL,
    hechoEnvio_ubicacionCliente_id INT NOT NULL,
    hechoEnvio_tipoEnvio_id INT NOT NULL,
    hechoEnvio_cantidadEnvios DECIMAL(18, 0) NOT NULL,
    hechoEnvio_totalEnviosCumplidos DECIMAL(18, 0) NOT NULL,
    hechoEnvio_totalEnviosNoCumplidos DECIMAL(18, 0) NOT NULL,
    hechoEnvio_totalCostoEnvio DECIMAL(18, 2) NOT NULL
);


-- Dimensiones

CREATE TABLE NJRE.BI_rango_etario_cliente (
    rangoEtarioCliente_id INT IDENTITY(1, 1),
    rangoEtarioCliente_nombre NVARCHAR(16) NOT NULL,
	CONSTRAINT CHK_RangoEtarioClienteNombre CHECK (rangoEtarioCliente_nombre IN ('JUVENTUD', 'ADULTEZ_TEMPRANA', 'ADULTEZ_MEDIA', 'ADULTEZ_AVANZADA'))
);

CREATE TABLE NJRE.BI_rubro (
    rubro_id INT IDENTITY(1, 1),
    rubro_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_subrubro (
    subrubro_id INT IDENTITY(1, 1),
    subrubro_descripcion NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_marca (
    marca_id INT IDENTITY(1, 1),
    marca_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_tipo_medio_pago (
    tipoMedioPago_id INT IDENTITY(1, 1),
    tipoMedioPago_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_concepto (
    concepto_id INT IDENTITY(1, 1),
    concepto_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_tipo_envio (
    tipoEnvio_id INT IDENTITY(1, 1),
    tipoEnvio_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_tiempo (
    tiempo_id INT IDENTITY(1,1), 
    tiempo_anio INT NOT NULL,
    tiempo_cuatrimestre INT NOT NULL,
    tiempo_mes INT NOT NULL,
	CONSTRAINT CHK_TiempoCuatrimestre CHECK (tiempo_cuatrimestre between 1 and 4),
	CONSTRAINT CHK_TiempoMes CHECK (tiempo_mes between 1 and 12)
);

CREATE TABLE NJRE.BI_ubicacion (
    ubicacion_id INT IDENTITY(1,1),
    ubicacion_localidad_id INT NOT NULL,
    ubicacion_localidad_nombre NVARCHAR(50) NOT NULL,
    ubicacion_provincia_id CHAR(2) NOT NULL,
    ubicacion_provincia_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_cuota (
    cuota_id INT IDENTITY(1,1),
    cuota_cantidad DECIMAL(18,0) NOT NULL
);

-------------------------------------------------------------------------------------------------
-- CREACION DE PRIMARY KEYS
-------------------------------------------------------------------------------------------------

-- Hechos

ALTER TABLE NJRE.BI_hecho_venta
ADD CONSTRAINT PK_BI_HechoVenta PRIMARY KEY (hechoVenta_tiempo_id, hechoVenta_ubicacionAlmacen_id, hechoVenta_ubicacionCliente_id, hechoVenta_rubro_id, hechoVenta_rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT PK_BI_HechoPublicacion PRIMARY KEY (hechoPublicacion_tiempo_id, hechoPublicacion_subrubro_id, hechoPublicacion_marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT PK_BI_HechoPago PRIMARY KEY (hechoPago_tipoMedioPago_id, hechoPago_tiempo_id, hechoPago_ubicacionCliente_id, hechoPago_cuota_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT PK_BI_HechoFactura PRIMARY KEY (hechoFactura_tiempo_id, hechoFactura_concepto_id, hechoFactura_ubicacionVendedor_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT PK_BI_HechoEnvio PRIMARY KEY (hechoEnvio_tiempo_id, hechoEnvio_ubicacionAlmacen_id, hechoEnvio_ubicacionCliente_id, hechoEnvio_tipoEnvio_id);

-- Dimensiones

ALTER TABLE NJRE.BI_tiempo
ADD CONSTRAINT PK_BI_Tiempo PRIMARY KEY (tiempo_id);

ALTER TABLE NJRE.BI_ubicacion
ADD CONSTRAINT PK_BI_Ubicacion PRIMARY KEY (ubicacion_id);

ALTER TABLE NJRE.BI_rango_etario_cliente
ADD CONSTRAINT PK_BI_RangoEtarioCliente PRIMARY KEY (rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_subrubro
ADD CONSTRAINT PK_BI_Subrubro PRIMARY KEY (subrubro_id);

ALTER TABLE NJRE.BI_rubro
ADD CONSTRAINT PK_BI_Rubro PRIMARY KEY (rubro_id);

ALTER TABLE NJRE.BI_marca
ADD CONSTRAINT PK_BI_Marca PRIMARY KEY (marca_id);

ALTER TABLE NJRE.BI_tipo_medio_pago
ADD CONSTRAINT PK_BI_TipoMedioPago PRIMARY KEY (tipoMedioPago_id);

ALTER TABLE NJRE.BI_concepto
ADD CONSTRAINT PK_BI_Concepto PRIMARY KEY (concepto_id);

ALTER TABLE NJRE.BI_tipo_envio
ADD CONSTRAINT PK_BI_TipoEnvio PRIMARY KEY (tipoEnvio_id);

ALTER TABLE NJRE.BI_cuota
ADD CONSTRAINT PK_BI_Cuota PRIMARY KEY (cuota_id);


-------------------------------------------------------------------------------------------------
-- CREACION DE FOREING KEYS
-------------------------------------------------------------------------------------------------

ALTER TABLE NJRE.BI_hecho_venta
ADD CONSTRAINT FK_BI_HechoVenta_Tiempo FOREIGN KEY (hechoVenta_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoVenta_UbicacionAlmacen FOREIGN KEY (hechoVenta_ubicacionAlmacen_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoVenta_UbicacionCliente FOREIGN KEY (hechoVenta_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoVenta_Rubro FOREIGN KEY (hechoVenta_rubro_id) REFERENCES NJRE.BI_rubro(rubro_id),
    CONSTRAINT FK_BI_HechoVenta_RangoEtarioCliente FOREIGN KEY (hechoVenta_rangoEtarioCliente_id) REFERENCES NJRE.BI_rango_etario_cliente(rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT FK_BI_HechoPublicacion_Tiempo FOREIGN KEY (hechoPublicacion_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPublicacion_Subrubro FOREIGN KEY (hechoPublicacion_subrubro_id) REFERENCES NJRE.BI_subrubro(subrubro_id),
    CONSTRAINT FK_BI_HechoPublicacion_Marca FOREIGN KEY (hechoPublicacion_marca_id) REFERENCES NJRE.BI_marca(marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT FK_BI_HechoPago_TipoMedioPago FOREIGN KEY (hechoPago_tipoMedioPago_id) REFERENCES NJRE.BI_tipo_medio_pago(tipoMedioPago_id),
    CONSTRAINT FK_BI_HechoPago_Tiempo FOREIGN KEY (hechoPago_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPago_Ubicacion FOREIGN KEY (hechoPago_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoPago_Cuota FOREIGN KEY (hechoPago_cuota_id) REFERENCES NJRE.BI_cuota(cuota_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT FK_BI_HechoFactura_Tiempo FOREIGN KEY (hechoFactura_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoFactura_Concepto FOREIGN KEY (hechoFactura_concepto_id) REFERENCES NJRE.BI_concepto(concepto_id),
    CONSTRAINT FK_BI_HechoFactura_UbicacionVendedor FOREIGN KEY (hechoFactura_ubicacionVendedor_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT FK_BI_HechoEnvio_Tiempo FOREIGN KEY (hechoEnvio_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoEnvio_UbicacionAlmacen FOREIGN KEY (hechoEnvio_ubicacionAlmacen_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoEnvio_UbicacionCliente FOREIGN KEY (hechoEnvio_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoEnvio_TipoEnvio FOREIGN KEY (hechoEnvio_tipoEnvio_id) REFERENCES NJRE.BI_tipo_envio(tipoEnvio_id);


-------------------------------------------------------------------------------------------------
-- FUNCIONES AUXILIARES DE LA MIGRACION
-------------------------------------------------------------------------------------------------

IF OBJECT_ID('NJRE.BI_obtener_tiempo_id') IS NOT NULL 
    DROP FUNCTION NJRE.BI_obtener_tiempo_id
GO
CREATE FUNCTION NJRE.BI_obtener_tiempo_id(@fecha_modelo DATE) 
RETURNS INT 
AS 
    BEGIN 
        DECLARE @id_fecha AS INT 
        SELECT @id_fecha = tiempo_id
        FROM NJRE.BI_tiempo	
        WHERE tiempo_anio = YEAR(@fecha_modelo) AND tiempo_mes = MONTH(@fecha_modelo)

        RETURN @id_fecha 
    END
GO

IF OBJECT_ID('NJRE.BI_obtener_ubicacion_id') IS NOT NULL 
    DROP FUNCTION NJRE.BI_obtener_ubicacion_id;
GO
CREATE FUNCTION NJRE.BI_obtener_ubicacion_id(@idDomicilio INT) 
RETURNS INT 
AS 
    BEGIN
        DECLARE @idUbicacion INT = 0;

        SELECT @idUbicacion = ubicacion_id
        FROM NJRE.domicilio d
			INNER JOIN NJRE.localidad l ON d.domicilio_localidad = l.localidad_id
			INNER JOIN NJRE.BI_ubicacion u ON l.localidad_nombre = u.ubicacion_localidad_nombre
            INNER JOIN NJRE.provincia ON provincia_id = domicilio_provincia AND provincia_nombre = ubicacion_provincia_nombre
        WHERE d.domicilio_id = @idDomicilio;

        RETURN @idUbicacion;
    END
GO


IF OBJECT_ID('NJRE.BI_obtener_tiempo_cuatrimestre') IS NOT NULL 
    DROP FUNCTION NJRE.BI_obtener_tiempo_cuatrimestre;
GO
CREATE FUNCTION NJRE.BI_obtener_tiempo_cuatrimestre(@fecha DATE) 
RETURNS INT 
AS 
BEGIN
    DECLARE @cuatrimestre INT;

    -- Lógica para determinar el cuatrimestre según el mes de la fecha
    SET @cuatrimestre = CASE 
        WHEN MONTH(@fecha) BETWEEN 1 AND 4 THEN 1 
        WHEN MONTH(@fecha) BETWEEN 5 AND 8 THEN 2  
        WHEN MONTH(@fecha) BETWEEN 9 AND 12 THEN 3 
        ELSE NULL -- Si la fecha no es válida (aunque no debería ocurrir)
    END;

    RETURN @cuatrimestre;
END;
GO

-------------------------------------------------------------------------------------------------
-- PROCEDURES PARA LA MIGRACION DE DATOS
-------------------------------------------------------------------------------------------------

-- Dimensiones

IF OBJECT_ID('NJRE.BI_migrar_tiempo') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_tiempo
GO 
CREATE PROCEDURE NJRE.BI_migrar_tiempo AS
BEGIN
    -- OBSERVACION: quizas se puede sacar directamente de la tabla maestra, en lugar de hacer UNIONs
    INSERT INTO NJRE.BI_tiempo (tiempo_anio, tiempo_mes, tiempo_cuatrimestre) 
	SELECT DISTINCT YEAR(p.publicacion_fecha_inicio), MONTH(p.publicacion_fecha_inicio), NJRE.BI_obtener_tiempo_cuatrimestre(publicacion_fecha_inicio)
	FROM NJRE.publicacion p
	UNION
	SELECT DISTINCT YEAR(v.venta_fecha), MONTH(v.venta_fecha), NJRE.BI_obtener_tiempo_cuatrimestre(v.venta_fecha)
	FROM NJRE.venta v
    UNION
	SELECT DISTINCT YEAR( e.envio_fecha_programada), MONTH(e.envio_fecha_programada), NJRE.BI_obtener_tiempo_cuatrimestre(e.envio_fecha_programada)
	FROM NJRE.envio e
END
GO 

IF OBJECT_ID('NJRE.BI_migrar_ubicacion') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_ubicacion
GO 
CREATE PROCEDURE NJRE.BI_migrar_ubicacion AS
BEGIN
    INSERT INTO NJRE.BI_ubicacion (ubicacion_provincia_id, ubicacion_provincia_nombre, ubicacion_localidad_id, ubicacion_localidad_nombre)
	SELECT DISTINCT provincia_id, provincia_nombre, domicilio_localidad, localidad_nombre
	FROM NJRE.domicilio 
    INNER JOIN NJRE.provincia ON provincia_id = domicilio_provincia
    INNER JOIN NJRE.localidad ON localidad_id = domicilio_localidad
END

IF OBJECT_ID('NJRE.BI_migrar_rubro') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_rubro
GO 
CREATE PROCEDURE NJRE.BI_migrar_rubro AS
BEGIN
    INSERT INTO NJRE.BI_rubro (rubro_nombre)
	SELECT rubro_descripcion
	FROM NJRE.rubro
END
GO

IF OBJECT_ID('NJRE.BI_migrar_subrubro') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_subrubro
GO 
CREATE PROCEDURE NJRE.BI_migrar_subrubro AS
BEGIN
    INSERT INTO NJRE.BI_subrubro (subrubro_descripcion)
    SELECT subrubro_descripcion
    FROM NJRE.subrubro
END
GO

IF OBJECT_ID('NJRE.BI_migrar_marca') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_marca
GO 
CREATE PROCEDURE NJRE.BI_migrar_marca AS
BEGIN
    INSERT INTO NJRE.BI_marca (marca_nombre)
    SELECT marca_descripcion
    FROM NJRE.marca
END
GO

IF OBJECT_ID('NJRE.BI_migrar_rangoEtarioCliente') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_rangoEtarioCliente
GO 
CREATE PROCEDURE NJRE.BI_migrar_rangoEtarioCliente AS
BEGIN
    INSERT INTO NJRE.BI_rango_etario_cliente (rangoEtarioCliente_nombre)
    VALUES ('JUVENTUD'), ('ADULTEZ_TEMPRANA'), ('ADULTEZ_MEDIA'), ('ADULTEZ_AVANZADA');
END
GO

IF OBJECT_ID('NJRE.BI_migrar_tipoEnvio') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_tipoEnvio
GO 
CREATE PROCEDURE NJRE.BI_migrar_tipoEnvio AS
BEGIN
    INSERT INTO NJRE.BI_tipo_envio (tipoEnvio_nombre)
    SELECT DISTINCT tipoEnvio_medio
    FROM NJRE.tipo_envio
END
GO

IF OBJECT_ID('NJRE.BI_migrar_tipoMedioPago') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_tipoMedioPago
GO 
CREATE PROCEDURE NJRE.BI_migrar_tipoMedioPago AS
BEGIN
    INSERT INTO NJRE.BI_tipo_medio_pago (tipoMedioPago_nombre)
    SELECT DISTINCT tipoMedioPago_nombre
    FROM NJRE.tipo_medio_pago 
END

IF OBJECT_ID('NJRE.BI_migrar_concepto') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_concepto
GO 
CREATE PROCEDURE NJRE.BI_migrar_concepto AS
BEGIN
    INSERT INTO NJRE.BI_concepto (concepto_nombre)
    SELECT DISTINCT concepto_nombre
    FROM NJRE.concepto 
END 


-- Hechos

/* SELECT
--		NJRE.BI_obtener_tiempo_id(v.venta_fecha),
--		NJRE.BI_obtener_rangoHorario_id(v.venta_fecha),
--		NJRE.BI_Obtener_ubicacion_id(a.almacen_domicilio_id),
--		SUM(dv.detalleVenta_cantidad),
--		SUM(dv.detalleVenta_precio)
--	FROM NJRE.venta v
--	INNER JOIN NJRE.detalle_venta dv ON v.venta_id = dv.detalleVenta_venta_id
--    INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
--	INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
--    GROUP BY
--		NJRE.BI_obtener_tiempo_id(v.venta_fecha),
--		NJRE.BI_obtener_rangoHorario_id(v.venta_fecha),
--		NJRE.BI_obtener_ubicacion_id(a.almacen_domicilio_id) 
*/

/*
-- de Nehuen: "incompleto"
IF OBJECT_ID('NJRE.BI_migrar_hechoPublicacion') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_hechoPublicacion
GO 
CREATE PROCEDURE NJRE.BI_migrar_hechoPublicacion AS
BEGIN
    INSERT INTO NJRE.BI_hechoPublicacion
    (hechoPublicacion_tiempo_id, hechoPublicacion_subrubro_id, hechoPublicacion_marca_id,
     hechoPublicacion_totalDiasPublicaciones, hechoPublicacion_cantidadStockTotal,
     hechoPublicacion_cantidadPublicaciones)
    SELECT 
        t.tiempo_id,
        sr.subrubro_id,
        m.marca_id,
        SUM(DATEDIFF(day, p.publicacion_fecha_inicio, p.publicacion_fecha_fin)),
        SUM(p.publicacion_stock),
        COUNT(p.publicacion_id)
    FROM NJRE.publicacion p

    GROUP BY t.tiempo_id, u.ubicacion_id, m.marca_id,;
END
GO
*/

IF OBJECT_ID('NJRE.BI_migrar_hechoVenta') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_hechoVenta
GO 
CREATE PROCEDURE NJRE.BI_migrar_hechoVenta AS
BEGIN
	INSERT INTO NJRE.BI_hecho_venta
	(hechoVenta_tiempo_id, hechoVenta_ubicacionAlmacen_id, hechoVenta_ubicacionCliente_id, hechoVenta_rubro_id, hechoVenta_rangoEtarioCliente_id, hechoVenta_cantidadVentas, hechoRubro_totalVentas)
	SELECT 
		tiempo_id,
		ubiAlmacen.ubicacion_id,
		ubiCliente.ubicacion_id,
		s.subrubro_rubro_id,
		NJRE.BI_obtener_rangoEtario(c.cliente_fecha_nacimiento),
		count(DISTINCT venta_id),
		SUM(dv.detalleVenta_cantidad)
	FROM NJRE.venta v
        INNER JOIN NJRE.detalle_venta dv ON v.venta_id = dv.detalleVenta_venta_id
        INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
        INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
        INNER JOIN NJRE.envio e ON e.envio_venta_id = v.venta_id
		INNER JOIN NJRE.producto pr ON pr.producto_id = p.publicacion_producto_id
		INNER JOIN NJRE.subrubro s ON s.subrubro_id = pr.producto_subrubro_id
		INNER JOIN NJRE.cliente c ON c.cliente_id = v.venta_cliente_id
		INNER JOIN NJRE.BI_tiempo ON tiempo_anio = datepart(year, venta_fecha) and tiempo_mes = datepart(month, venta_fecha)
        INNER JOIN NJRE.domicilio domAlmacen ON domAlmacen.domicilio_id = a.almacen_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiAlmacen ON ubiAlmacen.ubicacion_localidad_id = domAlmacen.domicilio_localidad and ubiAlmacen.ubicacion_provincia_id = domAlmacen.domicilio_provincia
		INNER JOIN NJRE.domicilio domCliente ON domCliente.domicilio_id = e.envio_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiCliente ON ubiCliente.ubicacion_localidad_id = domCliente.domicilio_localidad and ubiCliente.ubicacion_provincia_id = domCliente.domicilio_provincia
	GROUP BY tiempo_id, ubiAlmacen.ubicacion_id, ubiCliente.ubicacion_id, s.subrubro_rubro_id, NJRE.BI_obtener_rangoEtario(c.cliente_fecha_nacimiento);  
END
GO

IF OBJECT_ID('NJRE.BI_migrar_hechoEnvio') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_hechoEnvio
GO 
CREATE PROCEDURE NJRE.BI_migrar_hechoEnvio AS
BEGIN
    INSERT INTO NJRE.BI_hecho_envio 
    (hechoEnvio_tiempo_id, hechoEnvio_ubicacionAlmacen_id, hechoEnvio_ubicacionCliente_id, hechoEnvio_tipoEnvio_id, hechoEnvio_cantidadEnvios, hechoEnvio_totalEnviosCumplidos, hechoEnvio_totalEnviosNoCumplidos, hechoEnvio_totalCostoEnvio)
    SELECT 
        NJRE.BI_obtener_tiempo_id(e.envio_fecha_programada) AS tiempo_id,
        ubiAlmacen.ubicacion_id, 
		ubiCliente.ubicacion_id,
        e.envio_tipoEnvio_id,
        COUNT(DISTINCT e.envio_id),
        SUM(CASE WHEN e.envio_estado = 'Entregado' THEN e.envio_costo ELSE 0 END) AS totalEnviosCumplidos,
        SUM(CASE WHEN e.envio_estado <> 'Entregado' THEN e.envio_costo ELSE 0 END) AS totalEnviosNoCumplidos,
        SUM(e.envio_costo) AS totalCostoEnvio
    FROM NJRE.envio e
		INNER JOIN NJRE.detalle_venta dv ON dv.detalleVenta_venta_id = e.envio_venta_id
		INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
		INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
		INNER JOIN NJRE.domicilio domAlmacen ON domAlmacen.domicilio_id = a.almacen_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiAlmacen ON ubiAlmacen.ubicacion_localidad_id = domAlmacen.domicilio_localidad and ubiAlmacen.ubicacion_provincia_id = domAlmacen.domicilio_provincia
		INNER JOIN NJRE.domicilio domCliente ON domCliente.domicilio_id = e.envio_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiCliente ON ubiCliente.ubicacion_localidad_id = domCliente.domicilio_localidad and ubiCliente.ubicacion_provincia_id = domCliente.domicilio_provincia
    GROUP BY 
        NJRE.BI_obtener_tiempo_id(e.envio_fecha_programada), 
        ubiAlmacen.ubicacion_id, ubiCliente.ubicacion_id,
        e.envio_tipoEnvio_id
END
GO


-------------------------------------------------------------------------------------------------
-- EJECUCION DE LA MIGRACION DE DATOS
-------------------------------------------------------------------------------------------------

-- Dimensiones

EXEC NJRE.BI_migrar_rubro;
EXEC NJRE.BI_migrar_tiempo;
EXEC NJRE.BI_migrar_ubicacion;
EXEC NJRE.BI_migrar_rangoEtarioCliente;
EXEC NJRE.BI_migrar_subrubro;
EXEC NJRE.BI_migrar_marca;
EXEC NJRE.BI_migrar_tipoEnvio;
EXEC NJRE.BI_migrar_tipoMedioPago;
-- EXEC NJRE.BI_migrar_concepto;

-- Hechos

EXEC NJRE.BI_migrar_hechoVenta;
EXEC NJRE.BI_migrar_hechoEnvio;
-- EXEC NJRE.BI_migrar_hechoPublicacion;
-- EXEC NJRE.BI_migrar_hechoPago;
-- EXEC NJRE.BI_migrar_hechoFactura;

GO


-------------------------------------------------------------------------------------------------
-- VISTAS
-------------------------------------------------------------------------------------------------