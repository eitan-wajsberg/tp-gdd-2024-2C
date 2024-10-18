USE GD2C2024;
-- CREATE SCHEMA NJRE;

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
    usuario_nombre NVARCHAR(50) NOT NULL UNIQUE, -- Consulta, les parece bien que sea unique?
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