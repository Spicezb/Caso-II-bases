Base de Datos 1 - Caso 02
Sebastian Aguilar Villalobos, 2025072110
Xavier Cespedes Alvarado, 2025102887

# Tables

## employees
- employeeId serial PK
- firstName varchar(100) NOT NULL
- lastName varchar(100) NOT NULL
- email varchar(150) UNIQUE NOT NULL
- passwordHash varchar(255) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 

## countries
- countryId serial PK
- name varchar(80) NOT NULL UNIQUE
- isoCode char(2) NOT NULL UNIQUE
- isActive boolean NOT NULL DEFAULT TRUE 
- createdAt timestamp NOT NULL DEFAULT NOW()

## suppliers
- supplierId serial PK
- name varchar(150) NOT NULL
- countryId int FK NOT NULL
- contactEmail varchar(80) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 
- employeeId int FK NOT NULL

## productCategories
- productCategoryId serial PK
- name varchar(100) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- createdAt timestamp NOT NULL 
- employeeId int FK NOT NULL

## products
- productId serial PK
- name varchar(150) NOT NULL
- productCategoryId int FK NOT NULL
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 
- employeeId int FK NOT NULL

-- Respuesta al profe de: "sigo con duda de que es esto"
-- De acuerdo a nosotros, la logica de la tabla productVariants es que pueden existir distintas variantes de un producto. Ejemplo:
-- Tenemos un producto como "Aceite de lavanda" puede importarse en varias presentaciones: 30ml, 60ml, 100ml. Lo que entra al inventario, se mueve en bodega y se etiqueta con marca blanca en Dynamic Brands es siempre la variante, no el producto generico.

## productVariants
- productVariantId serial PK
- productId int FK NOT NULL
- description varchar(200) NOT NULL
- sku varchar(50) NOT NULL UNIQUE --codigo unico de la variante, sku=Stock Keeping Unit
- size varchar(50)  --30ml, 60ml, 100ml
- unit varchar(20) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL  
- employeeId int FK NOT NULL

## statuses
- statusId serial PK
- name varchar(20) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## imports
- importId serial PK
- supplierId int FK NOT NULL
- importDate date NOT NULL
- totalCostUsd NUMERIC(10,2) NOT NULL
- statusId int FK NOT NULL
- createdAt timestamp NOT NULL 
- employeeId int FK NOT NULL

## currencies
-- Tabla nueva para catálogo de monedas
- currencyId serial PK
- name varchar(50) NOT NULL              
- symbol varchar(5) NOT NULL             
- isoCode char(3) NOT NULL UNIQUE        
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## exchangeRates
-- Tasas de cambio usadas al momento de registrar una importación.
- exchangeRateId serial PK
- fromCurrencyId int FK NOT NULL         -- moneda del proveedor autorrefenciado
- toCurrencyId int FK NOT NULL           -- siempre USD en Etheria autorefenciado
- rate NUMERIC(10,4) NOT NULL
- validFrom date NOT NULL
- validTo date                           -- NULL significaría que sigue vigente
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## importItems
- importItemId serial PK
- importId int FK NOT NULL
- productVariantId int FK NOT NULL
- quantity int NOT NULL
- currencyId int FK NOT NULL             -- moneda original del proveedor, 
- exchangeRateId int FK NOT NULL         -- tasa usada al momento de la importación
- unitCostLocal NUMERIC(8,2) NOT NULL    -- costo en moneda del proveedor
- unitCostUsd NUMERIC(8,2) NOT NULL      -- resultado de la conversión a USD
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## warehouses
- warehouseId serial PK
- name varchar(100) NOT NULL
- createdAt timestamp NOT NULL
- employeeId int FK NOT NULL 

## warehouseLocations
-- Tabla nueva para la ubicación física dentro de la bodega: zona, pasillo y estante. Nos ayuda a saber exactamente dónde está guardado cada lote
- locationId serial PK
- warehouseId int FK NOT NULL
- zone varchar(20) NOT NULL              -- a, b, c, etc
- aisle varchar(10) NOT NULL             -- pasillo dentro de la zona
- shelf varchar(10) NOT NULL             -- estante dentro del pasillo
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## inventoryLots
-- Tabla nueva pra saber cada vez que llega una importación, el producto se registra como un lote en una ubicación específica de la bodega.
- lotId serial PK
- importItemId int FK NOT NULL           -- de qué línea de importación viene este lote
- productVariantId int FK NOT NULL
- locationId int FK NOT NULL             -- dónde está físicamente en la bodega
- quantityAvailable int NOT NULL DEFAULT 0
- quantityReserved int NOT NULL DEFAULT 0
- receivedAt timestamp NOT NULL
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## inventory
- inventoryId serial PK
- warehouseId int FK NOT NULL
- productVariantId int FK NOT NULL
- quantityAvailable int NOT NULL DEFAULT 0
- lastUpdated timestamp NOT NULL DEFAULT NOW() 
- employeeId int FK NOT NULL

## movements
- movementId serial PK
- movementName varchar(20) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## inventoryMovements
- inventoryMovementId serial PK
- lotId int FK NOT NULL                  -- lote específico del que se mueve el producto
- productVariantId int FK NOT NULL
- warehouseId int FK NOT NULL
- locationId int FK NOT NULL             -- ubicación física de origen o destino
- movementId int FK NOT NULL
- quantity int NOT NULL
- referenceId int                        -- ID de la orden o importación que originó esto
- referenceType varchar(30)              -- ORDER, IMPORT, ADJUSTMENT
- movementDate timestamp NOT NULL DEFAULT NOW()
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

## logTypes
- logTypeId serial PK
- name varchar(20) NOT NULL UNIQUE       -- INFO, WARNING, ERROR, etc
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## procedures
- procedureId serial PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## systemLogs
- systemLogId serial PK
- logTypeId int FK NOT NULL
- procedureId int FK NOT NULL
- message varchar(100)                          
- isError boolean NOT NULL DEFAULT FALSE   -- para filtarar rápido entre logs normales y errores
- executionTimeMs int                      -- duración del SP en milisegundos
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL

-- Para corregir esto "nos faltan pagos, permisos de usuario y grupos." se añaden las siguientes tablas: 

## userGroups
-- Grupos de permisos para empleados (Administrador, Bodeguero)
- groupId serial PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT NOW()

## employeeGroups
-- Relación muchos a muchos entre empleados y grupos de permisos.
- employeeGroupId serial PK
- employeeId int FK NOT NULL
- groupId int FK NOT NULL
- assignedAt timestamp NOT NULL DEFAULT NOW()
- assignedBy int FK NOT NULL             -- empleado que hizo la asignación

## importPayments
-- Pagos realizados a proveedores por cada importación.
-- Se guarda en moneda original y su equivalente en USD.
- paymentId serial PK
- importId int FK NOT NULL
- currencyId int FK NOT NULL
- exchangeRateId int FK NOT NULL
- amount NUMERIC(10,2) NOT NULL          -- monto en moneda original
- amountUsd NUMERIC(10,2) NOT NULL       -- monto convertido a USD
- paymentDate date NOT NULL
- paymentMethod varchar(50) NOT NULL     -- Transferencia, etc
- createdAt timestamp NOT NULL DEFAULT NOW()
- employeeId int FK NOT NULL
