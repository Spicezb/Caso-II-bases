Base de Datos 1 - Caso 02
Sebastian Aguilar Villalobos, 2025072110
Xavier Cespedes Alvarado, 2025102887

Motor de base de datos: MySQL 8
Nombre de la base: DynamicBrandsRetail
Contexto: Dynamic Brands es una empresa que usa IA para hacer sitios de e-commerce dinámicos. Se usan parámetros como logo, país y enfoque de mercadeo, la plataforma crea tiendas virtuales que comercian productos sacados de Etheria Global. La idea es que la base permita gestionar datos como lo son la marca, sitios, pedidos, detalles generales de venta, requisitos regulatorios y de envío, costos y tipos de cambio. Esto anterior para que sea posible unificar la información con Etheria Global para distintos análisis. 

#Tablas:

##paises:
-paisId INT auto-increment PK
-nombrePais varchar(80) unique not NULL
-codigoISO varchar(5) unique not NULL
-monedaPais varchar(10) not NULL
-activo boolean not NULL

##sitiosWeb:
-sitioWebId INT auto-increment PK
-nombreSitio varchar(100) unique not NULL
-enlaceSitio varchar(250) unique not NULL
-paisId FK not NULL
-enfoqueMarketing varchar(20) not NULL
-eslogan varchar(30)
-activo boolean not NULL
-fechaCreacion DATETIME not NULL

##marcas:
-marcaId INT auto-increment PK
-sitioWebId FK not NULL
-nombreMarca varchar(100) not NULL
-logoURL varchar(200) 
-descripcionMarca varchar(250) 
-actitudMarca varchar(20)
-activo boolean not NULL

##tiposProductos: //tipos generales
-tipoProductoId INT auto-increment PK
-nombreTipoP varchar(30) unique not NULL
-descripcionProducto varchar(100) 

##productoMadre: //estos se extraen de Etheria antes de etiquetas con otras marcas
-productoMadreId INT auto-increment PK
-codigoEtheriaProducto varchar(20) unique not NULL
-nombrePMadre varchar(40) not NULL
-tipoProductoId FK not NULL
-uso varchar(20) not NULL
-unidadMedida varchar(20) not NULL
-activo boolean not NULL

##productosDeComercio: //productos para la venta que provienen de Etheria
-productoComercioId INT auto-increment PK
-marcaId FK not NULL
-productoMadreId FK not NULL
-nombrePComercio varchar(50) not NULL 
-descripcionPComercio varchar(200)
-stock INT not NULL
-activo boolean not NULL
-presentacionProducto varchar(30) not NULL 
-monedaTipo varchar(10) not NULL
-precioVentaLocal DECIMAL(12,2) not NULL
-caracteristicaPrincipal varchar(30) //relajante, antiestrés, diversion, etc  

##clientes:
-clienteId INT auto-increment PK
-nombreCliente varchar(50) not NULL
-apellidos varchar(100) not NULL
-correo varchar(120) unique not NULL
-password varchar(250) not NULL
-telefono varchar(30)
-paisId FK not NULL
-fechaRegistro DATETIME not NULL
-activo boolean not NULL 

##encargos: 
-encargoId INT auto-increment PK 
-sitioWebId FK not NULL
-clienteId FK not NULL
-paisId FK not NULL
-monedaTipo varchar(10) not NULL 
-fechaEncargo DATETIME not NULL 
-estadoEncargo varchar(20) not NULL //pendiente, realizado, etc
-subtotalLocal DECIMAL(12,2) not NULL
-costoEnvioLocal DECIMAL(12,2) not NULL
-costoPermisosLocal DECIMAL(12,2) not NULL
-totalLocal DECIMAL(12,2) not NULL
-activo boolean not NULL

##detalleEncargo: 
-detalleEncargoId INT auto-increment PK 
-encargoId FK not NULL
-productoComercioId FK not NULL
-cantidad INT not NULL
-precioUnidad DECIMAL(12,2) not NULL
-subtotalLineaLocal DECIMAL(12,2) not NULL

##couriers:
-courierId INT auto-increment PK
-nombreMensajeria varchar(40) not NULL
-telContacto varchar(40) 
-correoContacto varchar(100) 
-activo boolean not NULL

##envios:
-envioId INT auto-increment PK
-encargoId FK not NULL
-courierId FK not NULL
-codigoDeEnvio varchar(40) unique not NULL
-fechaSalida DATETIME
-fechaEntrega DATETIME
-estadoEnvio varchar(20) not NULL
-costoEnvioRealLocal DECIMAL(12,2) not NULL

##requisitosRegulatorios: //general
-requisitoRegulatorioId INT auto-increment PK
-paisId FK not NULL
-tipoProductoId FK not NULL
-nombreRequisitoReg varchar(30) not NULL
-descripcionRequisito varchar(100) 
-requisitoObligatorio boolean not NULL
-costoRequisitoLocal DECIMAL(12,2)
-activo boolean not NULL

##encargosRequisitos: //aplicado a x pedido
-encargoRequisitoId INT auto-increment PK
-encargoId FK not NULL
-requisitoRegulatorioId FK
-terminado boolean not NULL
-fechaRegistro DATETIME not NULL
-comentario varchar(200)

##tiposCambio:
-tipoCambioId INT auto-increment PK
-monedaOrigen varchar(10) not NULL
-monedaDestino varchar(10) not NULL
-resultadoCambio DECIMAL(18,6) not NULL
-fechaVigencia DATE not NULL

##logsProcesos:
-logProcesoId INT auto-increment PK
-nombreProceso varchar(30) not NULL
-tablaDeTrabajo varchar(40) not NULL
-descripcionProceso varchar(100) 
-accionRealizada varchar(15) not NULL
-fechaHora DATETIME not NULL
-estadoProceso VARCHAR(30) not NULL


