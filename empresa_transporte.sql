phpmyadmin

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS empresa_transporte
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;
USE empresa_transporte;

-- Eliminación para evitar conflictos
DROP VIEW IF EXISTS vw_camioneros_salario;
DROP VIEW IF EXISTS vw_camiones_chevrolet;
DROP VIEW IF EXISTS vw_paquetes_chillan;
DROP VIEW IF EXISTS vw_paquetes_por_camion;
DROP VIEW IF EXISTS vw_paquetes_rodolfo_moya;

DROP TABLE IF EXISTS PAQUETE;
DROP TABLE IF EXISTS CAMIONERO;
DROP TABLE IF EXISTS CIUDAD;
DROP TABLE IF EXISTS PROVINCIA;
DROP TABLE IF EXISTS CAMION;

-- CREACIÓN DE TABLAS
CREATE TABLE PROVINCIA (
    Id_Provincia INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Capital VARCHAR(100),
    Region VARCHAR(100),
    Num_Habitantes INT
);

CREATE TABLE CIUDAD (
    Id_Ciudad INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    Superficie DECIMAL(10, 2),
    Id_Provincia INT,
    CONSTRAINT fk_ciudad_provincia FOREIGN KEY (Id_Provincia) REFERENCES PROVINCIA(Id_Provincia)
);

CREATE TABLE CAMION (
    Id_Camion INT PRIMARY KEY,
    Patente VARCHAR(20) UNIQUE NOT NULL,
    Modelo VARCHAR(50),
    Marca VARCHAR(50),
    Potencia VARCHAR(50),
    Capacidad DECIMAL(10, 2)
);

CREATE TABLE CAMIONERO (
    Id_Camionero INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Paterno VARCHAR(50) NOT NULL,
    Materno VARCHAR(50),
    Fecha_Nacimiento DATE,
    Telefono VARCHAR(20),
    Direccion VARCHAR(150),
    Salario DECIMAL(10, 2),
    Id_Camion INT,
    CONSTRAINT fk_camionero_camion FOREIGN KEY (Id_Camion) REFERENCES CAMION(Id_Camion)
);

CREATE TABLE PAQUETE (
    Id_Paquete INT PRIMARY KEY,
    Codigo_Paquete VARCHAR(50) UNIQUE NOT NULL,
    Descripcion TEXT,
    Fecha_Despacho DATE,
    Destinatario VARCHAR(100),
    Direccion_Destinatario VARCHAR(150),
    Id_Ciudad INT,
    Id_Camion INT,
    CONSTRAINT fk_paquete_ciudad FOREIGN KEY (Id_Ciudad) REFERENCES CIUDAD(Id_Ciudad),
    CONSTRAINT fk_paquete_camion FOREIGN KEY (Id_Camion) REFERENCES CAMION(Id_Camion)
);

-- INSERCIÓN DE DATOS
INSERT INTO PROVINCIA VALUES (1, 'Diguillín', 'Bulnes', 'Ñuble', 100000);
INSERT INTO CIUDAD VALUES (1, 'Chillán', -36.60600000, -72.10300000, 500.50, 1);
INSERT INTO CAMION VALUES (1, 'ABCD-12', 'FH16', 'Volvo', '500HP', 20.00);
INSERT INTO CAMION VALUES (2, 'CH-9988', 'Silverado', 'Chevrolet', '300HP', 5.00);
INSERT INTO CAMION VALUES (3, 'CH-1122', 'S10', 'Chevrolet', '250HP', 4.00);
INSERT INTO CAMIONERO VALUES (1, 'Rodolfo', 'Moya', 'Reyes', '1985-05-15', '912345678', 'Av. Libertad 123', 950000, 2);
INSERT INTO CAMIONERO VALUES (2, 'Juan', 'Pérez', 'Soto', '1990-10-20', '987654321', 'Calle Sur 456', 700000, 1);
INSERT INTO PAQUETE VALUES (1, 'PK-001', 'Documentos urgentes', '2026-05-20', 'Empresa SPA', 'Los Héroes 44', 1, 2);
INSERT INTO PAQUETE VALUES (2, 'PK-002', 'Caja de repuestos', '2026-05-20', 'Taller Mecánico', 'Brasil 789', 1, 2);


-- a. Antecedentes de contacto de camioneros con salario > 850.000
CREATE VIEW vw_camioneros_salario AS
SELECT Nombre, Paterno, Materno, Telefono, Direccion, Salario FROM CAMIONERO WHERE Salario > 850000;

-- b. Camiones marca Chevrolet ordenados por patente
CREATE VIEW vw_camiones_chevrolet AS
SELECT Id_Camion, Patente, Modelo, Marca, Potencia, Capacidad FROM CAMION WHERE Marca = 'Chevrolet' ORDER BY Patente ASC;

-- c. Paquetes recibidos en Chillán el 20-05-2026, ordenados por fecha descendente
CREATE VIEW vw_paquetes_chillan AS
SELECT p.* FROM PAQUETE p JOIN CIUDAD c ON p.Id_Ciudad = c.Id_Ciudad WHERE c.Nombre = 'Chillán' AND p.Fecha_Despacho = '2026-05-20' ORDER BY p.Fecha_Despacho DESC;

-- d. Cantidad de paquetes entregados por cada camión, orden descendente
CREATE VIEW vw_paquetes_por_camion AS
SELECT c.Patente, c.Marca, COUNT(p.Id_Paquete) AS Cantidad_Paquetes FROM CAMION c LEFT JOIN PAQUETE p ON c.Id_Camion = p.Id_Camion GROUP BY c.Patente, c.Marca ORDER BY Cantidad_Paquetes DESC;

-- e. Cantidad de paquetes entregados por el camionero Rodolfo Moya Reyes
CREATE VIEW vw_paquetes_rodolfo_moya AS
SELECT CONCAT(ca.Nombre, ' ', ca.Paterno, ' ', ca.Materno) AS Camionero, COUNT(p.Id_Paquete) AS Cantidad_Paquetes
FROM CAMIONERO ca JOIN CAMION c ON ca.Id_Camion = c.Id_Camion JOIN PAQUETE p ON c.Id_Camion = p.Id_Camion
WHERE ca.Nombre = 'Rodolfo' AND ca.Paterno = 'Moya' AND ca.Materno = 'Reyes' GROUP BY ca.Id_Camionero, ca.Nombre, ca.Paterno, ca.Materno;




SELECT
    CONCAT(ca.Nombre, ' ', ca.Paterno, ' ', ca.Materno) AS Camionero,
    cam.Patente,
    cam.Marca,
    COUNT(p.Id_Paquete) AS Cantidad_Paquetes
FROM CAMIONERO ca
JOIN CAMION cam ON ca.Id_Camion = cam.Id_Camion
LEFT JOIN PAQUETE p ON cam.Id_Camion = p.Id_Camion
GROUP BY ca.Id_Camionero, ca.Nombre, ca.Paterno, ca.Materno, cam.Patente, cam.Marca
ORDER BY Cantidad_Paquetes DESC;

SELECT
    pr.Nombre AS Provincia,
    c.Nombre AS Ciudad,
    COUNT(p.Id_Paquete) AS Cantidad_Paquetes
FROM PROVINCIA pr
JOIN CIUDAD c ON pr.Id_Provincia = c.Id_Provincia
LEFT JOIN PAQUETE p ON c.Id_Ciudad = p.Id_Ciudad
GROUP BY pr.Id_Provincia, pr.Nombre, c.Id_Ciudad, c.Nombre
ORDER BY Cantidad_Paquetes DESC;
