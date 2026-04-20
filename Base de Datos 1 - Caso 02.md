Base de Datos 1 - Caso 02
Sebastian Aguilar Villalobos, 2025072110
Xavier Cespedes Alvarado, 2025102887

Motor de base de datos: MySQL 8
Nombre de la base: DynamicBrandsRetail
Contexto: Dynamic Brands es una empresa que usa IA para hacer sitios de e-commerce dinámicos. Se usan parámetros como logo, país y enfoque de mercadeo, la plataforma crea tiendas virtuales que comercian productos sacados de Etheria Global. La idea es que la base permita gestionar datos como lo son la marca, sitios, pedidos, detalles generales de venta, requisitos regulatorios y de envío, costos y tipos de cambio. Esto anterior para que sea posible unificar la información con Etheria Global para distintos análisis. 

# Tables

## employees
- employeeId int auto-increment PK
- fullName varchar(150) NOT NULL
- email varchar(80) UNIQUE NOT NULL
- passwordHash varbinary(255) NOT NULL 
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL

## countries
- countryId int auto-increment PK
- name varchar(80) NOT NULL UNIQUE
- isoCode char(2) NOT NULL UNIQUE
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL

## cities
- cityId auto-increment PK
- countryId FK NOT NULL
- name varchar(50) NOT NULL
- createdAt timestamp NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## addresses
- addressId int auto-increment PK
- cityId int FK NOT NULL
- exactAddress varchar(250) NOT NULL
- addressLine2 varchar(250)              -- referencia adicional para saber mas a detalle donde es
- postalCode varchar(20)
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL
 
## taxTypes
-- Tabla nueva pra catálogo de tipos de impuesto: IVA, aranceles, fees de envío, etc.
- taxTypeId int auto-increment PK
- name varchar(50) NOT NULL UNIQUE       -- IVA, Arancel importación, etc
- description varchar(150) NOT NULL
- appliesTo varchar(30) NOT NULL         -- SALE, IMPORT, SHIPPING
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## taxRates
- taxRateId int auto-increment PK
- countryId int FK NOT NULL
- taxTypeId int FK NOT NULL              -- qué tipo de impuesto es
- rate DECIMAL(5,2) NOT NULL
- checksum varchar(64)                   
- validFrom date NOT NULL
- validTo date
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt timestamp
- employeeId int FK NOT NULL

## currencies
- currencyId int auto-increment PK
- symbol varchar(5) NOT NULL
- name varchar(50) NOT NULL
- countryId int FK NOT NULL
- isoCode char(3) NOT NULL UNIQUE   
- createdAt timestamp NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- employeeId int FK NOT NULL

## exchangeRates
-- Tanla que indica el valor actual/operativo
- exchangeRateId int auto-increment PK
- fromCurrencyId int FK NOT NULL
- toCurrencyId int FK NOT NULL
- rate DECIMAL(10,4) NOT NULL
- createdAt timestamp NOT NULL
- employeeId int FK NOT NULL

## exchangeHistory
-- Tabla que indica eñ histórico de cambios congelado para auditoría
- exchangeHistoryId auto-increment PK
- exchangeRateId int FK NOT NULL
- start DATETIME NOT NULL
- end DATETIME
- fromCurrencyId int FK NOT NULL
- toCurrencyId int FK NOT NULL
- rate DECIMAL(10,4) NOT NULL
- createdAt timestamp NOT NULL
- employeeId int FK NOT NULL

## marketingFocus
- marketingFocusId int auto-increment PK
- name varchar(100) NOT NULL UNIQUE
- description varchar(250) NOT NULL          
- targetAudience varchar(150)            
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## websites
- websiteId int auto-increment PK
- brandId int FK NOT NULL
- name varchar(100) NOT NULL UNIQUE
- url varchar(250) NOT NULL UNIQUE
- countryId int FK NOT NULL
- configJson JSON NOT NULL               -- paleta, fuentes, layouts, etc
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt timestamp
- employeeId int FK NOT NULL

## brands
- brandId int auto-increment PK
- name varchar(100) NOT NULL
- logoUrl varchar(250) NOT NULL
- description varchar(300) NOT NULL
- marketingFocusId int FK NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL
- employeeId int FK NOT NULL

## productCategories
- productCategoryId int auto-increment PK
- name varchar(100) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## baseProducts
- baseProductId int auto-increment PK
- productCategoryId int FK NOT NULL             
- name varchar(100) NOT NULL
- description varchar(300)                       
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## commercialProducts
- commercialProductId int auto-increment PK
- brandId int FK NOT NULL
- baseProductId int FK NOT NULL
- productVariantId int NOT NULL          -- FK lógico hacia EtheriaGlobal.productVariants
- name varchar(80) NOT NULL
- label varchar(250) NOT NULL            -- nombre en etiqueta física para ese mercado
- description varchar(300)               
- productAttributes JSON                 -- aroma, ingredientes, etc
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- updatedAt timestamp
- employeeId int FK NOT NULL

## productPrices
- productPriceId int auto-increment PK
- commercialProductId int FK NOT NULL
- websiteId int FK NOT NULL              -- precio específico por sitio web
- currencyId int FK NOT NULL
- price DECIMAL(10,2) NOT NULL
- validFrom date NOT NULL                -- inicio de vigencia del precio
- validTo date                           -- NULL = precio activo actualmente
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## customers
- customerId int auto-increment PK
- firstName varchar(50) NOT NULL
- lastName varchar(100) NOT NULL
- email varchar(80) UNIQUE NOT NULL
- passwordHash varbinary(255) NOT NULL
- phone varchar(15)
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt datetime NOT NULL DEFAULT CURRENT_TIMESTAMP

## customerAddresses
-- Tabla nueva para que un cliente puede tener N direcciones
- customerAddressId int auto-increment PK
- customerId int FK NOT NULL
- addressId int FK NOT NULL
- isDefault boolean NOT NULL DEFAULT FALSE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

## orderStatuses
- orderStatusId int auto-increment PK
- name varchar(30) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## orders
- orderId int auto-increment PK
- websiteId int FK NOT NULL
- customerId int FK NOT NULL
- addressId int FK NOT NULL
- currencyId int FK NOT NULL
- orderStatusId int FK NOT NULL
- exchangeRateId int FK NOT NULL         -- reemplaza el campo que quedaba suelto de exchangeRateUsed
- orderDate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- subtotal DECIMAL(10,2) NOT NULL
- taxAmount DECIMAL(10,2) NOT NULL DEFAULT 0
- shippingCost DECIMAL(10,2) NOT NULL DEFAULT 0
- total DECIMAL(10,2) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt datetime NOT NULL DEFAULT CURRENT_TIMESTAMP

## orderTaxes
-- Tabla nueva pra la lista detallada de los impuestos aplicados a cada orden
- orderTaxId int auto-increment PK
- orderId int FK NOT NULL
- taxTypeId int FK NOT NULL
- taxRateId int FK NOT NULL
- taxableAmount DECIMAL(10,2) NOT NULL
- taxAmount DECIMAL(10,2) NOT NULL
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

## orderDetails
- orderDetailId int auto-increment PK
- orderId int FK NOT NULL
- commercialProductId int FK NOT NULL
- quantity int NOT NULL
- unitPrice DECIMAL(10,2) NOT NULL
- lineSubtotal DECIMAL(10,2) NOT NULL  -- quantity * unitPrice al momento de la compra
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## shippingStatuses
- shippingStatusId int auto-increment PK
- name varchar(30) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## couriers
- courierId int auto-increment PK
- name varchar(50) NOT NULL
- phone varchar(50)
- email varchar(100) NOT NULL
- countryId int FK NOT NULL 
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## shipments
- shipmentId int auto-increment PK
- orderId int FK NOT NULL
- courierId int FK NOT NULL
- trackingCode varchar(50) UNIQUE NOT NULL
- shippingStatusId int FK NOT NULL
- shippedAt DATETIME
- deliveredAt DATETIME
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## processTypes
- processTypeId INT auto-increment PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## processLogs
- processLogId int auto-increment PK
- processTypeId int FK NOT NULL
- logFunction varchar(10) NOT NULL          -- INFO, WARNING, ERROR, etc
- message TEXT NOT NULL
- isError boolean NOT NULL DEFAULT FALSE
- executionTimeMs int
- createdAt datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

-- Para responder a "faltan transacciones  y pagos, y los movimientos de inventario no se si estan aqui o en la otra db, apenas la voy a ver. " se agregaron las siguientes tablas:

## paymentMethods
- paymentMethodId int auto-increment PK
- name varchar(50) NOT NULL UNIQUE       -- Tarjeta crédito, PayPal, Transferencia, etc
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

## payments
-- Transacciones de pago del cliente final por una orden.
- paymentId int auto-increment PK
- orderId int FK NOT NULL
- paymentMethodId int FK NOT NULL
- currencyId int FK NOT NULL
- exchangeRateId int FK NOT NULL
- amount DECIMAL(10,2) NOT NULL          -- monto en moneda local del cliente
- amountUsd DECIMAL(10,2) NOT NULL       -- monto convertido a USD para análisis unificado
- paymentDate datetime NOT NULL
- status varchar(30) NOT NULL            
- transactionReference varchar(100)      -- código externo del procesador de pagos
- createdAt datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
- employeeId int FK NOT NULL

## userGroups
- groupId int auto-increment PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP

## employeeGroups
- employeeGroupId int auto-increment PK
- employeeId int FK NOT NULL
- groupId int FK NOT NULL
- assignedAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
- assignedBy int FK NOT NULL             -- empleado que hizo la asignación
