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

-------------------------------------------------------------------------------------------------
-- ELIMINACION DE TABLAS, FKS Y PROCEDURES
-------------------------------------------------------------------------------------------------

EXEC NJRE.BI_borrar_fks;
EXEC NJRE.BI_borrar_tablas;

GO

-------------------------------------------------------------------------------------------------
-- CREACION DE TABLAS
-------------------------------------------------------------------------------------------------

-- Hechos

CREATE TABLE NJRE.BI_hecho_venta (
    hechoVenta_tiempo_id INT NOT NULL,
    hechoVenta_rangoHorario_id INT NOT NULL,
    hechoVenta_ubicacionAlmacen_id INT NOT NULL,
    hechoVenta_valorPromedio DECIMAL(10, 2) NOT NULL,
    hechoVenta_cantidadVentas INT NOT NULL
);

CREATE TABLE NJRE.BI_hecho_rubro (
    hechoRubro_ubicacionCliente_id INT NOT NULL,
    hechoRubro_rangoEtarioCliente_id INT NOT NULL,
    hechoRubro_tiempo_id INT NOT NULL,
    hechoRubro_nombre NVARCHAR(50) NOT NULL,
    hechoRubro_cantidadVentas INT NOT NULL
);

CREATE TABLE NJRE.BI_hecho_publicacion (
    hechoPublicacion_tiempo_id INT NOT NULL,
    hechoPublicacion_subrubro_id INT NOT NULL,
    hechoPublicacion_marca_id INT NOT NULL,
    hechoPublicacion_diasPromedioVigente DECIMAL(10, 2) NOT NULL,
    hechoPublicacion_cantidadStockPromedio DECIMAL(10, 2) NOT NULL
);

CREATE TABLE NJRE.BI_hecho_pago (
    hechoPago_tipoMedioPago_id INT NOT NULL,
    hechoPago_tiempo_id INT NOT NULL,
    hechoPago_ubicacionCliente_id INT NOT NULL,
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
    hechoEnvio_tipoEnvio_id INT NOT NULL,
    concepto_porcentajeCumplimiento DECIMAL(18, 2)
);

CREATE TABLE NJRE.BI_hecho_localidad (
    hechoLocalidad_ubicacionCliente_id INT NOT NULL,
    hechoLocalidad_costoEnvio DECIMAL(18, 2) NOT NULL
);


-- Dimensiones

CREATE TABLE NJRE.BI_rango_horario (
    rangoHorario_id INT IDENTITY(1, 1),
    rangoHorario_nombre NVARCHAR(9) NOT NULL
);

CREATE TABLE NJRE.BI_rango_etario_cliente (
    rangoEtarioCliente_id INT IDENTITY(1, 1),
    rangoEtarioCliente_nombre NVARCHAR(16) NOT NULL
);

CREATE TABLE NJRE.BI_subrubro (
    subrubro_id INT IDENTITY(1, 1),
    subrubro_rubro NVARCHAR(50) NOT NULL,
    subrubro_subrubro NVARCHAR(50) NOT NULL
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
    tiempo_mes INT NOT NULL
);

CREATE TABLE NJRE.BI_ubicacion (
    ubicacion_id INT IDENTITY(1,1),
    ubicacion_localidad NVARCHAR(50) NOT NULL,
    ubicacion_provincia NVARCHAR(50) NOT NULL
);


-------------------------------------------------------------------------------------------------
-- CREACION DE PRIMARY KEYS
-------------------------------------------------------------------------------------------------

-- Hechos

ALTER TABLE NJRE.BI_hecho_venta
ADD CONSTRAINT PK_BI_HechoVenta PRIMARY KEY (hechoVenta_tiempo_id, hechoVenta_rangoHorario_id, hechoVenta_ubicacionAlmacen_id);

ALTER TABLE NJRE.BI_hecho_rubro
ADD CONSTRAINT PK_BI_HechoRubro PRIMARY KEY (hechoRubro_ubicacionCliente_id, hechoRubro_rangoEtarioCliente_id, hechoRubro_tiempo_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT PK_BI_HechoPublicacion PRIMARY KEY (hechoPublicacion_tiempo_id, hechoPublicacion_subrubro_id, hechoPublicacion_marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT PK_BI_HechoPago PRIMARY KEY (hechoPago_tipoMedioPago_id, hechoPago_tiempo_id, hechoPago_ubicacionCliente_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT PK_BI_HechoFactura PRIMARY KEY (hechoFactura_tiempo_id, hechoFactura_concepto_id, hechoFactura_ubicacionVendedor_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT PK_BI_HechoEnvio PRIMARY KEY (hechoEnvio_tiempo_id, hechoEnvio_ubicacionAlmacen_id);

ALTER TABLE NJRE.BI_hecho_localidad
ADD CONSTRAINT PK_BI_HechoLocalidad PRIMARY KEY (hechoLocalidad_ubicacionCliente_id);

-- Dimensiones

ALTER TABLE NJRE.BI_tiempo
ADD CONSTRAINT PK_BI_Tiempo PRIMARY KEY (tiempo_id);

ALTER TABLE NJRE.BI_rango_horario
ADD CONSTRAINT PK_BI_RangoHorario PRIMARY KEY (rangoHorario_id);

ALTER TABLE NJRE.BI_ubicacion
ADD CONSTRAINT PK_BI_Ubicacion PRIMARY KEY (ubicacion_id);

ALTER TABLE NJRE.BI_rango_etario_cliente
ADD CONSTRAINT PK_BI_RangoEtarioCliente PRIMARY KEY (rangoEtarioCliente_id);

ALTER TABLE NJRE.BI_subrubro
ADD CONSTRAINT PK_BI_Subrubro PRIMARY KEY (subrubro_id);

ALTER TABLE NJRE.BI_marca
ADD CONSTRAINT PK_BI_Marca PRIMARY KEY (marca_id);

ALTER TABLE NJRE.BI_tipo_medio_pago
ADD CONSTRAINT PK_BI_TipoMedioPago PRIMARY KEY (tipoMedioPago_id);

ALTER TABLE NJRE.BI_concepto
ADD CONSTRAINT PK_BI_Concepto PRIMARY KEY (concepto_id);

ALTER TABLE NJRE.BI_tipo_envio
ADD CONSTRAINT PK_BI_TipoEnvio PRIMARY KEY (tipoEnvio_id);


-------------------------------------------------------------------------------------------------
-- CREACION DE FOREING KEYS
-------------------------------------------------------------------------------------------------

ALTER TABLE NJRE.BI_hecho_venta
ADD CONSTRAINT FK_BI_HechoVenta_Tiempo FOREIGN KEY (hechoVenta_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoVenta_RangoHorario FOREIGN KEY (hechoVenta_rangoHorario_id) REFERENCES NJRE.BI_rango_horario(rangoHorario_id),
    CONSTRAINT FK_BI_HechoVenta_Ubicacion FOREIGN KEY (hechoVenta_ubicacionAlmacen_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id);

ALTER TABLE NJRE.BI_hecho_rubro
ADD CONSTRAINT FK_BI_HechoRubro_Ubicacion FOREIGN KEY (hechoRubro_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoRubro_RangoEtarioCliente FOREIGN KEY (hechoRubro_rangoEtarioCliente_id) REFERENCES NJRE.BI_rango_etario_cliente(rangoEtarioCliente_id),
    CONSTRAINT FK_BI_HechoRubro_Tiempo FOREIGN KEY (hechoRubro_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id);

ALTER TABLE NJRE.BI_hecho_publicacion
ADD CONSTRAINT FK_BI_HechoPublicacion_Tiempo FOREIGN KEY (hechoPublicacion_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPublicacion_Subrubro FOREIGN KEY (hechoPublicacion_subrubro_id) REFERENCES NJRE.BI_subrubro(subrubro_id),
    CONSTRAINT FK_BI_HechoPublicacion_Marca FOREIGN KEY (hechoPublicacion_marca_id) REFERENCES NJRE.BI_marca(marca_id);

ALTER TABLE NJRE.BI_hecho_pago
ADD CONSTRAINT FK_BI_HechoPago_TipoMedioPago FOREIGN KEY (hechoPago_tipoMedioPago_id) REFERENCES NJRE.BI_tipo_medio_pago(tipoMedioPago_id),
    CONSTRAINT FK_BI_HechoPago_Tiempo FOREIGN KEY (hechoPago_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoPago_Ubicacion FOREIGN KEY (hechoPago_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id);

ALTER TABLE NJRE.BI_hecho_factura
ADD CONSTRAINT FK_BI_HechoFactura_Tiempo FOREIGN KEY (hechoFactura_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoFactura_Concepto FOREIGN KEY (hechoFactura_concepto_id) REFERENCES NJRE.BI_concepto(concepto_id),
    CONSTRAINT FK_BI_HechoFactura_UbicacionVendedor FOREIGN KEY (hechoFactura_ubicacionVendedor_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id);

ALTER TABLE NJRE.BI_hecho_envio
ADD CONSTRAINT FK_BI_HechoEnvio_Tiempo FOREIGN KEY (hechoEnvio_tiempo_id) REFERENCES NJRE.BI_tiempo(tiempo_id),
    CONSTRAINT FK_BI_HechoEnvio_UbicacionAlmacen FOREIGN KEY (hechoEnvio_ubicacionAlmacen_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id),
    CONSTRAINT FK_BI_HechoEnvio_TipoEnvio FOREIGN KEY (hechoEnvio_tipoEnvio_id) REFERENCES NJRE.BI_tipo_envio(tipoEnvio_id);

ALTER TABLE NJRE.BI_hecho_localidad
ADD CONSTRAINT FK_BI_HechoLocalidad_UbicacionCliente FOREIGN KEY (hechoLocalidad_ubicacionCliente_id) REFERENCES NJRE.BI_ubicacion(ubicacion_id);


-------------------------------------------------------------------------------------------------
-- FUNCIONES AUXILIARES DE LA MIGRACION
-------------------------------------------------------------------------------------------------

IF OBJECT_ID('NJRE.BI_obtener_rangoHorario_id') IS NOT NULL 
  DROP FUNCTION NJRE.BI_obtener_rangoHorario_id;
GO 
CREATE FUNCTION NJRE.BI_obtener_rangoHorario_id(@fecha DATETIME) 
RETURNS INT 
AS 
BEGIN
    DECLARE @hora INT = DATEPART(HOUR, @fecha);
    DECLARE @rangoHorario_id INT;

    IF @hora BETWEEN 0 AND 5
    BEGIN
        SELECT @rangoHorario_id = rangoHorario_id
        FROM NJRE.BI_rango_horario 
        WHERE rangoHorario_nombre = 'MADRUGADA';
    END

    IF @hora BETWEEN 6 AND 11
    BEGIN
        SELECT @rangoHorario_id = rangoHorario_id
        FROM NJRE.BI_rango_horario 
        WHERE rangoHorario_nombre = 'MAÑANA';
    END

    IF @hora BETWEEN 12 AND 17
    BEGIN
        SELECT @rangoHorario_id = rangoHorario_id
        FROM NJRE.BI_rango_horario 
        WHERE rangoHorario_nombre = 'TARDE';
    END

    IF @hora BETWEEN 18 AND 23
    BEGIN
        SELECT @rangoHorario_id = rangoHorario_id
        FROM NJRE.BI_rango_horario 
        WHERE rangoHorario_nombre = 'NOCHE';
    END

    RETURN @rangoHorario_id;
END;
GO


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
            INNER JOIN NJRE.BI_ubicacion u ON d.domicilio_localidad = u.ubicacion_localidad
            INNER JOIN NJRE.provincia 
                ON provincia_id = domicilio_provincia
                AND provincia_nombre = ubicacion_provincia
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


IF OBJECT_ID('NJRE.BI_migrar_tiempo') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_tiempo
GO 
CREATE PROCEDURE NJRE.BI_migrar_tiempo AS
BEGIN
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
    INSERT INTO NJRE.BI_ubicacion (ubicacion_provincia, ubicacion_localidad)
	SELECT DISTINCT provincia_nombre, domicilio_localidad
	FROM NJRE.domicilio 
    INNER JOIN NJRE.provincia ON provincia_id = domicilio_provincia
END
GO

IF OBJECT_ID('NJRE.BI_migrar_rangoHorario') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_rangoHorario
GO 
CREATE PROCEDURE NJRE.BI_migrar_rangoHorario AS
BEGIN
    INSERT INTO NJRE.BI_rango_horario (rangoHorario_nombre)
    VALUES ('MADRUGADA'), ('MAÑANA') ,('TARDE'), ('NOCHE');
END
GO

IF OBJECT_ID('NJRE.BI_migrar_hechoVenta') IS NOT NULL 
    DROP PROCEDURE NJRE.BI_migrar_hechoVenta
GO 
CREATE PROCEDURE NJRE.BI_migrar_hechoVenta AS
BEGIN
	INSERT INTO NJRE.BI_hecho_venta
	(hechoVenta_tiempo_id, hechoVenta_rangoHorario_id, hechoVenta_ubicacionAlmacen_id, hechoVenta_valorPromedio, hechoVenta_cantidadVentas)
	SELECT 
		t.tiempo_id,
		r.rangoHorario_id,
		u.ubicacion_id,
		SUM(dv.detalleVenta_cantidad),
		SUM(dv.detalleVenta_precio)
	FROM NJRE.venta v
	INNER JOIN NJRE.detalle_venta dv ON v.venta_id = dv.detalleVenta_venta_id
	INNER JOIN NJRE.publicacion p ON p.publicacion_id = dv.detalleVenta_publicacion_id
	INNER JOIN NJRE.almacen a ON a.almacen_id = p.publicacion_almacen_id
	CROSS APPLY (
		SELECT NJRE.BI_obtener_tiempo_id(v.venta_fecha) AS tiempo_id
	) t
	CROSS APPLY (
		SELECT NJRE.BI_obtener_rangoHorario_id(v.venta_fecha) AS rangoHorario_id
	) r
	CROSS APPLY (
		SELECT NJRE.BI_obtener_ubicacion_id(a.almacen_domicilio_id) AS ubicacion_id
	) u
	WHERE r.rangoHorario_id IS NOT NULL
	GROUP BY t.tiempo_id, r.rangoHorario_id, u.ubicacion_id;
END
GO 

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

-------------------------------------------------------------------------------------------------
-- EJECUCION DE LA MIGRACION DE DATOS
-------------------------------------------------------------------------------------------------

EXEC NJRE.BI_migrar_tiempo;
EXEC NJRE.BI_migrar_ubicacion;
EXEC NJRE.BI_migrar_rangoHorario;
EXEC NJRE.BI_migrar_hechoVenta;
GO

-------------------------------------------------------------------------------------------------
-- VISTAS
-------------------------------------------------------------------------------------------------

