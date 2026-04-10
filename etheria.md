# Tables

## employees
- employeeId serial PK
- firstName varchar(20) NOT NULL
- lastName varchar(20) NOT NULL
- email varchar(150) UNIQUE
- passwordHash varchar(255) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 

## countries
- countryId serial PK
- name varchar(80) NOT NULL UNIQUE
- isoCode char(2) NOT NULL UNIQUE
- isActive boolean NOT NULL DEFAULT TRUE 

## suppliers
- supplierId serial PK
- name varchar(150) NOT NULL
- countryId int FK NOT NULL
- contactEmail varchar(80) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 
- employeeId FK NOT NULL

## productCategories
- productCategoryId serial PK
- name varchar(100) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- createdAt timestamp NOT NULL 
- employeeId FK NOT NULL

## products
- productId serial PK
- name varchar(150) NOT NULL
- categoryId int FK NOT NULL
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL 
- employeeId FK NOT NULL

## productVariants
- productVariantId serial PK
- productId int FK NOT NULL
- description varchar(200) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE
- createdAt timestamp NOT NULL DEFAULT 
- employeeId FK NOT NULL

## Statuses
- statusId serial PK
- name varchar(20) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## imports
- importId serial PK
- supplierId int FK NOT NULL
- importDate date NOT NULL
- totalCostUsd NUMERIC(10,2) NOT NULL
- statusId FK NOT NULL
- createdAt timestamp NOT NULL 
- employeeId FK NOT NULL

## importItems
- importItemId serial PK
- importId int FK NOT NULL
- productVariantId int FK NOT NULL
- quantity int NOT NULL
- unitCostUsd NUMERIC(8,2) NOT NULL
- employeeId FK NOT NULL

## warehouses
- warehouseId serial PK
- name varchar(100) NOT NULL
- createdAt timestamp NOT NULL
- employeeId FK NOT NULL 

## inventory
- inventoryId serial PK
- warehouseId int FK NOT NULL
- productVariantId int FK NOT NULL
- quantityAvailable int NOT NULL DEFAULT 0
- lastUpdated timestamp NOT NULL 
- employeeId FK NOT NULL

## movements
- movementId serial PK
- movementName varchar(20) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## inventoryMovements
- inventoryMovementId serial PK
- productVariantId int FK NOT NULL
- warehouseId int FK NOT NULL
- movementId FK NOT NULL
- quantity int NOT NULL
- movementDate timestamp NOT NULL 
- employeeId int FK NOT NULL

## logTypes
- logTypeId serial PK
- name varchar(20) NOT NULL UNIQUE
- description varchar(100) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## procedures
- procedureId INT auto-increment PK
- name varchar(50) NOT NULL UNIQUE
- description varchar(150) NOT NULL
- isActive boolean NOT NULL DEFAULT TRUE

## systemLogs
- systemLogId serial PK
- logTypeId FK NOT NULL
- procedureId FK NOT NULL
- message varchar(200)
- createdAt timestamp NOT NULL 
- employeeId FK NOT NULL