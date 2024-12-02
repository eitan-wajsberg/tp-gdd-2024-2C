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
    hechoVenta_provinciaAlmacen_id NCHAR(2) NOT NULL,
    hechoVenta_localidadCliente_id INT NOT NULL,
    hechoVenta_rubro_id INT NOT NULL,
    hechoVenta_rangoEtarioCliente_id INT NOT NULL,
    hechoVenta_cantidadVentas DECIMAL(18, 0) NOT NULL,
    hechoVenta_totalVentas DECIMAL(18, 2) NOT NULL
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
    hechoPago_localidadCliente_id INT NOT NULL,
    hechoPago_cuota_id INT NOT NULL,
    hechoPago_importeTotalCuotas DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_factura (
    hechoFactura_tiempo_id INT NOT NULL,
    hechoFactura_concepto_id INT NOT NULL,
    hechoFactura_provinciaVendedor_id NCHAR(2) NOT NULL,
    hechoFactura_porcentajeFacturacion DECIMAL(18, 2) NOT NULL,
    hechoFactura_montoFacturado DECIMAL(18, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_envio (
    hechoEnvio_tiempo_id INT NOT NULL,
    hechoEnvio_provinciaAlmacen_id NCHAR(2) NOT NULL,
    hechoEnvio_localidadCliente_id INT NOT NULL,
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

CREATE TABLE NJRE.BI_localidad (
    localidad_id INT IDENTITY(1,1),
    localidad_nombre NVARCHAR(50) NOT NULL
);

CREATE TABLE NJRE.BI_provincia (
    provincia_id NCHAR(2) NOT NULL,
    provincia_nombre NVARCHAR(50) NOT NULL
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
ADD CONSTRAINT PK_BI_HechoVenta PRIMARY KEY (hechoVenta_tiempo_id, hechoVenta_provinciaAlmacen_id, hechoVenta_localidadCliente_id, hechoVenta_rubro_id, hechoVenta_rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT PK_BI_HechoPublicacion PRIMARY KEY (hechoPublicacion_tiempo_id, hechoPublicacion_subrubro_id, hechoPublicacion_marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT PK_BI_HechoPago PRIMARY KEY (hechoPago_tipoMedioPago_id, hechoPago_tiempo_id, hechoPago_localidadCliente_id, hechoPago_cuota_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT PK_BI_HechoFactura PRIMARY KEY (hechoFactura_tiempo_id, hechoFactura_concepto_id, hechoFactura_provinciaVendedor_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT PK_BI_HechoEnvio PRIMARY KEY (hechoEnvio_tiempo_id, hechoEnvio_provinciaAlmacen_id, hechoEnvio_localidadCliente_id, hechoEnvio_tipoEnvio_id);

-- Dimensiones

ALTER TABLE NJRE.BI_tiempo
ADD CONSTRAINT PK_BI_Tiempo PRIMARY KEY (tiempo_id);

ALTER TABLE NJRE.BI_localidad
ADD CONSTRAINT PK_BI_Localidad PRIMARY KEY (localidad_id);

ALTER TABLE NJRE.BI_provincia
ADD CONSTRAINT PK_BI_Provincia PRIMARY KEY (provincia_id);

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
    CONSTRAINT FK_BI_HechoVenta_ProvinciaAlmacen FOREIGN KEY (hechoVenta_provinciaAlmacen_id) REFERENCES NJRE.BI_provincia(provincia_id),
    CONSTRAINT FK_BI_HechoVenta_LocalidadCliente FOREIGN KEY (hechoVenta_localidadCliente_id) REFERENCES NJRE.BI_localidad(localidad_id),
    CONSTRAINT FK_BI_HechoVenta_Rubro FOREIGN KEY (hechoVenta_rubro_id) REFERENCES NJRE.BI_rubro(rubro_id),
    CONSTRAINT FK_BI_HechoVenta_RangoEtarioCliente FOREIGN KEY (hechoVenta_rangoEtarioCliente_id) REFERENCES NJRE.BI_rango_etario_cliente(rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT FK_BI_HechoPublicacion_Tiempo FOREIGN KEY (hechoPublicacion_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPublicacion_Subrubro FOREIGN KEY (hechoPublicacion_subrubro_id) REFERENCES NJRE.BI_subrubro(subrubro_id),
    CONSTRAINT FK_BI_HechoPublicacion_Marca FOREIGN KEY (hechoPublicacion_marca_id) REFERENCES NJRE.BI_marca(marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT FK_BI_HechoPago_TipoMedioPago FOREIGN KEY (hechoPago_tipoMedioPago_id) REFERENCES NJRE.BI_tipo_medio_pago(tipoMedioPago_id),
    CONSTRAINT FK_BI_HechoPago_Tiempo FOREIGN KEY (hechoPago_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPago_LocalidadCliente FOREIGN KEY (hechoPago_localidadCliente_id) REFERENCES NJRE.BI_localidad(localidad_id),
    CONSTRAINT FK_BI_HechoPago_Cuota FOREIGN KEY (hechoPago_cuota_id) REFERENCES NJRE.BI_cuota(cuota_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT FK_BI_HechoFactura_Tiempo FOREIGN KEY (hechoFactura_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoFactura_Concepto FOREIGN KEY (hechoFactura_concepto_id) REFERENCES NJRE.BI_concepto(concepto_id),
    CONSTRAINT FK_BI_HechoFactura_ProvinciaVendedor FOREIGN KEY (hechoFactura_provinciaVendedor_id) REFERENCES NJRE.BI_provincia(provincia_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT FK_BI_HechoEnvio_Tiempo FOREIGN KEY (hechoEnvio_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoEnvio_ProvinciaAlmacen FOREIGN KEY (hechoEnvio_provinciaAlmacen_id) REFERENCES NJRE.BI_provincia(provincia_id),
    CONSTRAINT FK_BI_HechoEnvio_LocalidadCliente FOREIGN KEY (hechoEnvio_localidadCliente_id) REFERENCES NJRE.BI_localidad(localidad_id),
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

IF OBJECT_ID('NJRE.BI_obtener_rangoEtario_id') IS NOT NULL 
    DROP FUNCTION NJRE.BI_obtener_rangoEtario_id;
GO
CREATE FUNCTION NJRE.BI_obtener_rangoEtario_id(@fecha DATE) 
RETURNS INT 
AS 
BEGIN
    DECLARE @idRangoEtario INT;
    DECLARE @edad INT;

    -- Calcular la edad basada en el año actual
    SET @edad = DATEDIFF(YEAR, @fecha, GETDATE()) - 
		CASE 
			WHEN MONTH(@fecha) > MONTH(GETDATE()) OR (MONTH(@fecha) = MONTH(GETDATE()) AND DAY(@fecha) > DAY(GETDATE())) 
			THEN 1 
			ELSE 0 
    END;

    SET @idRangoEtario = CASE 
        WHEN @edad < 25 THEN 1 
        WHEN @edad BETWEEN 25 AND 35 THEN 2  
        WHEN @edad BETWEEN 36 AND 50 THEN 3
        WHEN @edad > 50 THEN 4 
        ELSE NULL
    END;

    RETURN @idRangoEtario;
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

IF OBJECT_ID('NJRE.BI_migrar_localidad') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_localidad
GO 
CREATE PROCEDURE NJRE.BI_migrar_localidad AS
BEGIN
    INSERT INTO NJRE.BI_localidad (localidad_nombre)
	SELECT localidad_nombre
	FROM NJRE.localidad
END
GO

IF OBJECT_ID('NJRE.BI_migrar_provincia') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_provincia
GO 
CREATE PROCEDURE NJRE.BI_migrar_provincia AS
BEGIN
    INSERT INTO NJRE.BI_provincia (provincia_id, provincia_nombre)
	SELECT provincia_id, provincia_nombre
	FROM NJRE.provincia
END
GO

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
GO

IF OBJECT_ID('NJRE.BI_migrar_concepto') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_concepto
GO 
CREATE PROCEDURE NJRE.BI_migrar_concepto AS
BEGIN
    INSERT INTO NJRE.BI_concepto (concepto_nombre)
    SELECT DISTINCT concepto_nombre
    FROM NJRE.concepto 
END 
GO

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
	(hechoVenta_tiempo_id, hechoVenta_provinciaAlmacen_id, hechoVenta_localidadCliente_id, hechoVenta_rubro_id, hechoVenta_rangoEtarioCliente_id, hechoVenta_cantidadVentas, hechoVenta_totalVentas)
	SELECT 
		tiempo_id,
		domAlmacen.domicilio_provincia,
		domCliente.domicilio_localidad,
		s.subrubro_rubro_id,
		NJRE.BI_obtener_rangoEtario_id(c.cliente_fecha_nacimiento),
		COUNT(DISTINCT venta_id),
		SUM(dv.detalleVenta_cantidad)
	FROM NJRE.venta v
        INNER JOIN NJRE.detalle_venta dv ON v.venta_id = dv.detalleVenta_venta_id
        INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
        INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
        INNER JOIN NJRE.envio e ON e.envio_venta_id = v.venta_id
		INNER JOIN NJRE.producto pr ON pr.producto_id = p.publicacion_producto_id
		INNER JOIN NJRE.subrubro s ON s.subrubro_id = pr.producto_subrubro_id
		INNER JOIN NJRE.cliente c ON c.cliente_id = v.venta_cliente_id
		INNER JOIN NJRE.BI_tiempo ON tiempo_anio = DATEPART(year, venta_fecha) and tiempo_mes = DATEPART(month, venta_fecha)
        INNER JOIN NJRE.domicilio domAlmacen ON domAlmacen.domicilio_id = a.almacen_domicilio_id
		INNER JOIN NJRE.domicilio domCliente ON domCliente.domicilio_id = e.envio_domicilio_id
	GROUP BY tiempo_id, domAlmacen.domicilio_provincia, domCliente.domicilio_localidad, s.subrubro_rubro_id, NJRE.BI_obtener_rangoEtario_id(c.cliente_fecha_nacimiento);  
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
        NJRE.BI_obtener_tiempo_id(e.envio_fecha_programada),
        ubiAlmacen.ubicacion_id, 
		ubiCliente.ubicacion_id,
        e.envio_tipoEnvio_id,
        COUNT(DISTINCT e.envio_id),
        SUM(CASE WHEN e.envio_estado = 'Entregado' THEN e.envio_costo ELSE 0 END),
        SUM(CASE WHEN e.envio_estado <> 'Entregado' THEN e.envio_costo ELSE 0 END),
        SUM(e.envio_costo) AS totalCostoEnvio
    FROM NJRE.envio e
		INNER JOIN NJRE.detalle_venta dv ON dv.detalleVenta_venta_id = e.envio_venta_id
		INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
		INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
		INNER JOIN NJRE.domicilio domAlmacen ON domAlmacen.domicilio_id = a.almacen_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiAlmacen ON ubiAlmacen.ubicacion_localidad_id = domAlmacen.domicilio_localidad AND ubiAlmacen.ubicacion_provincia_id = domAlmacen.domicilio_provincia
		INNER JOIN NJRE.domicilio domCliente ON domCliente.domicilio_id = e.envio_domicilio_id
		INNER JOIN NJRE.BI_ubicacion ubiCliente ON ubiCliente.ubicacion_localidad_id = domCliente.domicilio_localidad AND ubiCliente.ubicacion_provincia_id = domCliente.domicilio_provincia
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
EXEC NJRE.BI_migrar_localidad;
EXEC NJRE.BI_migrar_provincia;
EXEC NJRE.BI_migrar_rangoEtarioCliente;
EXEC NJRE.BI_migrar_subrubro;
EXEC NJRE.BI_migrar_marca;
EXEC NJRE.BI_migrar_tipoEnvio;
EXEC NJRE.BI_migrar_tipoMedioPago;
EXEC NJRE.BI_migrar_concepto;

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

-- Vista 1
-- Vista 2

-- Vista 3
IF OBJECT_ID('NJRE.BI_ventaPromedioMensual') IS NOT NULL 
    DROP VIEW NJRE.BI_ventaPromedioMensual
GO 
CREATE VIEW NJRE.BI_ventaPromedioMensual AS
SELECT tiempo_anio, tiempo_mes, provincia_nombre, sum(hechoVenta_totalVentas) / sum(hechoVenta_cantidadVentas) 'promedio ventas'
FROM NJRE.BI_hecho_venta
	INNER JOIN NJRE.BI_tiempo on tiempo_id = hechoVenta_tiempo_id
	INNER JOIN NJRE.provincia on provincia_id = hechoVenta_provinciaAlmacen_id
GROUP BY hechoVenta_tiempo_id, tiempo_anio, tiempo_mes, provincia_id, provincia_nombre
GO

-- Vista 4
IF OBJECT_ID('NJRE.BI_rendimientoDeRubros') IS NOT NULL 
    DROP VIEW NJRE.BI_rendimientoDeRubros
GO 
CREATE VIEW NJRE.BI_rendimientoDeRubros AS
SELECT tiempo_anio, tiempo_cuatrimestre, localidad_nombre, rangoEtarioCliente_nombre, rubro_id, rubro_nombre
FROM NJRE.BI_hecho_venta
	INNER JOIN NJRE.BI_tiempo on tiempo_id = hechoVenta_tiempo_id
	INNER JOIN NJRE.BI_rubro on rubro_id = hechoVenta_rubro_id
	INNER JOIN NJRE.BI_localidad on localidad_id = hechoVenta_localidadCliente_id
	INNER JOIN NJRE.BI_rango_etario_cliente on rangoEtarioCliente_id= hechoVenta_rangoEtarioCliente_id
WHERE rubro_id in (
	SELECT TOP 5 hechoVenta_rubro_id 
	FROM NJRE.BI_hecho_venta 
	WHERE hechoVenta_tiempo_id = tiempo_id
		and hechoVenta_localidadCliente_id = localidad_id
		and hechoVenta_rangoEtarioCliente_id = rangoEtarioCliente_id
	GROUP BY hechoVenta_rubro_id
	ORDER BY sum(hechoVenta_totalVentas) desc
	)
GROUP BY tiempo_anio, tiempo_cuatrimestre, localidad_id, localidad_nombre, hechoVenta_rangoEtarioCliente_id, rangoEtarioCliente_nombre, rubro_id, rubro_nombre
GO

-- Vista 6

-- Vista 7 
-- REVISAR: Todos tienen porcentaje de cumplimiento 0 ya que ningun envio fue entregado, todos estan programados desde 2025 en adelante
-- REVISAR: Cuando avisaron que no se puede usar distinct, era aca en las vistas o en la migracion de los hechos?
IF OBJECT_ID('NJRE.BI_porcentajeCumplimientoEnvios') IS NOT NULL 
    DROP VIEW NJRE.BI_porcentajeCumplimientoEnvios
GO 
CREATE VIEW NJRE.BI_porcentajeCumplimientoEnvios AS
SELECT DISTINCT ubicacion_provincia_nombre, tiempo_anio, tiempo_mes, 
	CASE 
		WHEN hechoEnvio_totalEnviosCumplidos = 0 THEN 0
		ELSE hechoEnvio_cantidadEnvios * 1.0 / hechoEnvio_totalEnviosCumplidos 
    END porcentajeCumplimiento
FROM NJRE.BI_hecho_envio he
	INNER JOIN NJRE.BI_ubicacion u ON u.ubicacion_id = he.hechoEnvio_ubicacionAlmacen_id
	INNER JOIN NJRE.BI_tiempo t ON t.tiempo_id = he.hechoEnvio_tiempo_id;
GO

-- Vista 8
IF OBJECT_ID('NJRE.BI_localidadesConMayorCostoEnvio') IS NOT NULL 
    DROP VIEW NJRE.BI_localidadesConMayorCostoEnvio
GO 
CREATE VIEW NJRE.BI_localidadesConMayorCostoEnvio AS
SELECT TOP 5 ubicacion_localidad_nombre, he.hechoEnvio_totalCostoEnvio
FROM NJRE.BI_hecho_envio he INNER JOIN NJRE.BI_ubicacion u ON u.ubicacion_id = he.hechoEnvio_ubicacionCliente_id
ORDER BY he.hechoEnvio_totalCostoEnvio DESC;

-- Vista 9
-- Vista 10