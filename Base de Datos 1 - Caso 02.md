Base de Datos 1 - Caso 02
Sebastian Aguilar Villalobos, 2025072110
Xavier Cespedes Alvarado, 2025102887

Motor de base de datos: MySQL 8
Nombre de la base: DynamicBrandsRetail
Contexto: Dynamic Brands es una empresa que usa IA para hacer sitios de e-commerce dinámicos. Se usan parámetros como logo, país y enfoque de mercadeo, la plataforma crea tiendas virtuales que comercian productos sacados de Etheria Global. La idea es que la base permita gestionar datos como lo son la marca, sitios, pedidos, detalles generales de venta, requisitos regulatorios y de envío, costos y tipos de cambio. Esto anterior para que sea posible unificar la información con Etheria Global para distintos análisis. 

# Tables

## employees
- employeeId auto-increment PK
- fullName varchar(150) NOT NULL
- email varchar(80) UNIQUE NOT NULL
- passwordHash varchar(255) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL

## countries
- countryId auto-increment PK
- name varchar(80) NOT NULL UNIQUE
- isoCode char(2) NOT NULL UNIQUE
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL

## cities
- cityId auto-increment PK
- countryId FK NOT NULL
- name varchar(50) NOT NULL
- createdAt timestamp NOT NULL

## addresses
- addressId PK
- cityId FK NOT NULL
- exactAddress varchar(250) NOT NULL
- postalCode varchar(20)
- createdAt timestamp NOT NULL

## taxRates
- taxRateId INT auto-increment PK
- countryId INT FK NOT NULL
- rate DECIMAL(5,2) NOT NULL
- validFrom DATE NOT NULL
- validTo DATE
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT 

## currencies
- currencyId auto-increment PK
- symbol varchar(1) NOT NULL
- name varchar(50) NOT NULL
- countryId FK NOT NULL
- createdAt timestamp NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- employeeId FK NOT NULL

## exchangeRates
- exchangeRateId auto-increment PK
- fromCurrencyId FK NOT NULL
- toCurrencyId FK NOT NULL
- rate DECIMAL(10,4) NOT NULL
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## exchangeHistory
- exchangeHistoryId auto-increment PK
- exchangeRateId FK NOT NULL
- start DATETIME NOT NULL
- end DATETIME
- fromCurrencyId FK NOT NULL
- toCurrencyId FK NOT NULL
- rate DECIMAL(10,4) NOT NULL
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## marketingFocus
- marketingFocusId auto-increment PK
- name varchar(50) UNIQUE
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## websites
- websiteId auto-increment PK
- brandId FK NOT NULL
- name varchar(100) NOT NULL UNIQUE
- url varchar(250) NOT NULL UNIQUE
- countryId FK NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## brands
- brandId auto-increment PK
- websiteId FK 
- name varchar(100) NOT NULL
- logoUrl varchar(250) NOT NULL
- description varchar(300) NOT NULL
- marketingFocusId FK NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## baseProducts      
- baseProductId PK
- productVariantId FK NOT NULL
- name varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## commercialProducts
- commercialProductId auto-increment PK
- brandId FK NOT NULL
- baseProductId FK NOT NULL
- name varchar(80) NOT NULL
- label varchar(250) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## productPrices
- productPriceId auto-increment PK
- commercialProductId FK NOT NULL
- currencyId FK NOT NULL
- price DECIMAL(7,2) NOT NULL
- employeeId FK NOT NULL
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL

## customers
- customerId auto-increment PK
- firstName varchar(50) NOT NULL
- lastName varchar(100) NOT NULL
- email varchar(80) UNIQUE NOT NULL
- passwordHash varchar(255) NOT NULL
- phone varchar(15)
- addressId FK NOT NULL
- createdAt DATETIME NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## orderStatuses
- orderStatusId auto-increment PK
- name varchar(30) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## orders
- orderId auto-increment PK
- websiteId FK NOT NULL
- customerId FK NOT NULL
- addressId FK NOT NULL
- currencyId FK NOT NULL
- orderStatusId FK NOT NULL
- orderDate timestamp NOT NULL DEFAULT 
- subtotal DECIMAL(7,2) NOT NULL
- taxAmount DECIMAL(7,2) NOT NULL DEFAULT 0 
- shippingCost DECIMAL(7,2) NOT NULL DEFAULT 0
- total DECIMAL(7,2) NOT NULL
- exchangeRateUsed DECIMAL(10,6)
- createdAt DATETIME NOT NULL DEFAULT
- isActive boolean NOT NULL DEFAULT TRUE

## orderDetails
- orderDetailId auto-increment PK
- orderId FK NOT NULL
- commercialProductId FK NOT NULL
- quantity NOT NULL
- unitPrice DECIMAL(7,2) NOT NULL

## shippingStatuses
- shippingStatusId auto-increment PK
- name varchar(30) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## couriers
- courierId auto-increment PK
- name varchar(50) NOT NULL
- phone varchar(50)
- email varchar(100) NOT NULL
- countryId FK NOT NULL 
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt DATETIME NOT NULL DEFAULT
- employeeId FK NOT NULL

## shipments
- shipmentId auto-increment PK
- orderId FK NOT NULL
- courierId FK NOT NULL
- trackingCode varchar(50) UNIQUE NOT NULL
- shippingStatusId FK NOT NULL
- shippedAt DATETIME
- deliveredAt DATETIME
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt DATETIME NOT NULL DEFAULT
- employeeId FK NOT NULL

## processLogTypes
- processLogTypeId auto-increment PK
- name varchar(30) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## processTypes
- processTypeId INT auto-increment PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## processLogs
- processLogId INT auto-increment PK
- processLogTypeId FK NOT NULL
- processTypeId FK NOT NULL
- description varchar(100) NOT NULL
- createdAt DATETIME NOT NULL
- employeeId FK NOT NULL