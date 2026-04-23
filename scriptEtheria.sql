CREATE TABLE employees (
    employeeId SERIAL PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL
);

CREATE TABLE countries (
    countryId SERIAL PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    isoCode CHAR(2) NOT NULL UNIQUE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE suppliers (
    supplierId SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    countryId INT NOT NULL,
    contactEmail VARCHAR(80) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (countryId) REFERENCES countries(countryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE productCategories (
    productCategoryId SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE products (
    productId SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    productCategoryId INT NOT NULL,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (productCategoryId) REFERENCES productCategories(productCategoryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE productVariants (
    productVariantId SERIAL PRIMARY KEY,
    productId INT NOT NULL,
    description VARCHAR(200) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    size VARCHAR(50),
    unit VARCHAR(20) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (productId) REFERENCES products(productId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE statuses (
    statusId SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE imports (
    importId SERIAL PRIMARY KEY,
    supplierId INT NOT NULL,
    importDate DATE NOT NULL,
    totalCostUsd NUMERIC(10,2) NOT NULL,
    statusId INT NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (supplierId) REFERENCES suppliers(supplierId),
    FOREIGN KEY (statusId) REFERENCES statuses(statusId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE currencies (
    currencyId SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    isoCode CHAR(3) NOT NULL UNIQUE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE exchangeRates (
    exchangeRateId SERIAL PRIMARY KEY,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate NUMERIC(10,4) NOT NULL,
    validFrom DATE NOT NULL,
    validTo DATE,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (fromCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (toCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE importItems (
    importItemId SERIAL PRIMARY KEY,
    importId INT NOT NULL,
    productVariantId INT NOT NULL,
    quantity INT NOT NULL,
    currencyId INT NOT NULL,
    exchangeRateId INT NOT NULL,
    unitCostLocal NUMERIC(8,2) NOT NULL,
    unitCostUsd NUMERIC(8,2) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (importId) REFERENCES imports(importId),
    FOREIGN KEY (productVariantId) REFERENCES productVariants(productVariantId),
    FOREIGN KEY (currencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(exchangeRateId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE warehouses (
    warehouseId SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE warehouseLocations (
    locationId SERIAL PRIMARY KEY,
    warehouseId INT NOT NULL,
    zone VARCHAR(20) NOT NULL,
    aisle VARCHAR(10) NOT NULL,
    shelf VARCHAR(10) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (warehouseId) REFERENCES warehouses(warehouseId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE inventoryLots (
    lotId SERIAL PRIMARY KEY,
    importItemId INT NOT NULL,
    productVariantId INT NOT NULL,
    locationId INT NOT NULL,
    quantityAvailable INT NOT NULL DEFAULT 0,
    quantityReserved INT NOT NULL DEFAULT 0,
    receivedAt TIMESTAMP NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (importItemId) REFERENCES importItems(importItemId),
    FOREIGN KEY (productVariantId) REFERENCES productVariants(productVariantId),
    FOREIGN KEY (locationId) REFERENCES warehouseLocations(locationId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE inventory (
    inventoryId SERIAL PRIMARY KEY,
    warehouseId INT NOT NULL,
    productVariantId INT NOT NULL,
    quantityAvailable INT NOT NULL DEFAULT 0,
    lastUpdated TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (warehouseId) REFERENCES warehouses(warehouseId),
    FOREIGN KEY (productVariantId) REFERENCES productVariants(productVariantId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE movements (
    movementId SERIAL PRIMARY KEY,
    movementName VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE inventoryMovements (
    inventoryMovementId SERIAL PRIMARY KEY,
    lotId INT NOT NULL,
    productVariantId INT NOT NULL,
    warehouseId INT NOT NULL,
    locationId INT NOT NULL,
    movementId INT NOT NULL,
    quantity INT NOT NULL,
    referenceId INT,
    referenceType VARCHAR(30),
    movementDate TIMESTAMP NOT NULL DEFAULT NOW(),
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (lotId) REFERENCES inventoryLots(lotId),
    FOREIGN KEY (productVariantId) REFERENCES productVariants(productVariantId),
    FOREIGN KEY (warehouseId) REFERENCES warehouses(warehouseId),
    FOREIGN KEY (locationId) REFERENCES warehouseLocations(locationId),
    FOREIGN KEY (movementId) REFERENCES movements(movementId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE logTypes (
    logTypeId SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE procedures (
    procedureId SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE systemLogs (
    systemLogId SERIAL PRIMARY KEY,
    logTypeId INT NOT NULL,
    procedureId INT NOT NULL,
    message VARCHAR(100),
    isError BOOLEAN NOT NULL DEFAULT FALSE,
    executionTimeMs INT,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (logTypeId) REFERENCES logTypes(logTypeId),
    FOREIGN KEY (procedureId) REFERENCES procedures(procedureId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE userGroups (
    groupId SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE employeeGroups (
    employeeGroupId SERIAL PRIMARY KEY,
    employeeId INT NOT NULL,
    groupId INT NOT NULL,
    assignedAt TIMESTAMP NOT NULL DEFAULT NOW(),
    assignedBy INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId),
    FOREIGN KEY (groupId) REFERENCES userGroups(groupId),
    FOREIGN KEY (assignedBy) REFERENCES employees(employeeId)
);

CREATE TABLE importPayments (
    paymentId SERIAL PRIMARY KEY,
    importId INT NOT NULL,
    currencyId INT NOT NULL,
    exchangeRateId INT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    amountUsd NUMERIC(10,2) NOT NULL,
    paymentDate DATE NOT NULL,
    paymentMethod VARCHAR(50) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    employeeId INT NOT NULL,
    FOREIGN KEY (importId) REFERENCES imports(importId),
    FOREIGN KEY (currencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(exchangeRateId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

-- SUPPLIERS
CREATE INDEX idx_suppliers_country ON suppliers(countryId);
CREATE INDEX idx_suppliers_employee ON suppliers(employeeId);

-- PRODUCT CATEGORIES
CREATE INDEX idx_productCategories_employee ON productCategories(employeeId);

-- PRODUCTS
CREATE INDEX idx_products_category ON products(productCategoryId);
CREATE INDEX idx_products_employee ON products(employeeId);

-- PRODUCT VARIANTS
CREATE INDEX idx_variants_product ON productVariants(productId);
CREATE INDEX idx_variants_employee ON productVariants(employeeId);

-- IMPORTS
CREATE INDEX idx_imports_supplier ON imports(supplierId);
CREATE INDEX idx_imports_status ON imports(statusId);
CREATE INDEX idx_imports_employee ON imports(employeeId);

-- CURRENCIES
CREATE INDEX idx_currencies_employee ON currencies(employeeId);

-- EXCHANGE RATES
CREATE INDEX idx_exchange_from ON exchangeRates(fromCurrencyId);
CREATE INDEX idx_exchange_to ON exchangeRates(toCurrencyId);
CREATE INDEX idx_exchange_employee ON exchangeRates(employeeId);

-- IMPORT ITEMS
CREATE INDEX idx_importItems_import ON importItems(importId);
CREATE INDEX idx_importItems_variant ON importItems(productVariantId);
CREATE INDEX idx_importItems_currency ON importItems(currencyId);
CREATE INDEX idx_importItems_exchange ON importItems(exchangeRateId);
CREATE INDEX idx_importItems_employee ON importItems(employeeId);

-- WAREHOUSES
CREATE INDEX idx_warehouses_employee ON warehouses(employeeId);

-- WAREHOUSE LOCATIONS
CREATE INDEX idx_locations_warehouse ON warehouseLocations(warehouseId);
CREATE INDEX idx_locations_employee ON warehouseLocations(employeeId);

-- INVENTORY LOTS
CREATE INDEX idx_lots_importItem ON inventoryLots(importItemId);
CREATE INDEX idx_lots_variant ON inventoryLots(productVariantId);
CREATE INDEX idx_lots_location ON inventoryLots(locationId);
CREATE INDEX idx_lots_employee ON inventoryLots(employeeId);

-- INVENTORY
CREATE INDEX idx_inventory_warehouse ON inventory(warehouseId);
CREATE INDEX idx_inventory_variant ON inventory(productVariantId);
CREATE INDEX idx_inventory_employee ON inventory(employeeId);

-- INVENTORY MOVEMENTS
CREATE INDEX idx_movements_lot ON inventoryMovements(lotId);
CREATE INDEX idx_movements_variant ON inventoryMovements(productVariantId);
CREATE INDEX idx_movements_warehouse ON inventoryMovements(warehouseId);
CREATE INDEX idx_movements_location ON inventoryMovements(locationId);
CREATE INDEX idx_movements_type ON inventoryMovements(movementId);
CREATE INDEX idx_movements_employee ON inventoryMovements(employeeId);

-- SYSTEM LOGS
CREATE INDEX idx_logs_type ON systemLogs(logTypeId);
CREATE INDEX idx_logs_procedure ON systemLogs(procedureId);
CREATE INDEX idx_logs_employee ON systemLogs(employeeId);


-- EMPLOYEE GROUPS
CREATE INDEX idx_employeeGroups_employee ON employeeGroups(employeeId);
CREATE INDEX idx_employeeGroups_group ON employeeGroups(groupId);
CREATE INDEX idx_employeeGroups_assignedBy ON employeeGroups(assignedBy);

-- IMPORT PAYMENTS
CREATE INDEX idx_importPayments_import ON importPayments(importId);
CREATE INDEX idx_importPayments_currency ON importPayments(currencyId);
CREATE INDEX idx_importPayments_exchange ON importPayments(exchangeRateId);
CREATE INDEX idx_importPayments_employee ON importPayments(employeeId);