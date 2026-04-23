CREATE TABLE employees (
    employeeId INT AUTO_INCREMENT PRIMARY KEY,
    fullName VARCHAR(150) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    passwordHash VARBINARY(255) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL
);

CREATE TABLE countries (
    countryId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    isoCode CHAR(2) NOT NULL UNIQUE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL
);

CREATE TABLE cities (
    cityId INT AUTO_INCREMENT PRIMARY KEY,
    countryId INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_city_country (countryId),
    FOREIGN KEY (countryId) REFERENCES countries(countryId)
);

CREATE TABLE addresses (
    addressId INT AUTO_INCREMENT PRIMARY KEY,
    cityId INT NOT NULL,
    exactAddress VARCHAR(250) NOT NULL,
    addressLine2 VARCHAR(250),
    postalCode VARCHAR(20),
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_address_city (cityId),
    INDEX idx_address_employee (employeeId),
    FOREIGN KEY (cityId) REFERENCES cities(cityId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE taxTypes (
    taxTypeId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    appliesTo VARCHAR(30) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_taxType_employee (employeeId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE taxRates (
    taxRateId INT AUTO_INCREMENT PRIMARY KEY,
    countryId INT NOT NULL,
    taxTypeId INT NOT NULL,
    rate DECIMAL(5,2) NOT NULL,
    checksum VARCHAR(64),
    validFrom DATE NOT NULL,
    validTo DATE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_tax_country (countryId),
    INDEX idx_tax_type (taxTypeId),
    INDEX idx_tax_employee (employeeId),
    FOREIGN KEY (countryId) REFERENCES countries(countryId),
    FOREIGN KEY (taxTypeId) REFERENCES taxTypes(taxTypeId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE currencies (
    currencyId INT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(5) NOT NULL,
    name VARCHAR(50) NOT NULL,
    countryId INT NOT NULL,
    isoCode CHAR(3) NOT NULL UNIQUE,
    createdAt TIMESTAMP NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    employeeId INT NOT NULL,
    INDEX idx_currency_country (countryId),
    FOREIGN KEY (countryId) REFERENCES countries(countryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE exchangeRates (
    exchangeRateId INT AUTO_INCREMENT PRIMARY KEY,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(10,4) NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    INDEX idx_ex_from (fromCurrencyId),
    INDEX idx_ex_to (toCurrencyId),
    FOREIGN KEY (fromCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (toCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE exchangeHistory (
    exchangeHistoryId INT AUTO_INCREMENT PRIMARY KEY,
    exchangeRateId INT NOT NULL,
    start DATETIME NOT NULL,
    end DATETIME,
    fromCurrencyId INT NOT NULL,
    toCurrencyId INT NOT NULL,
    rate DECIMAL(10,4) NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    INDEX idx_exh_rate (exchangeRateId),
    FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(exchangeRateId),
    FOREIGN KEY (fromCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (toCurrencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE marketingFocus (
    marketingFocusId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(250) NOT NULL,
    targetAudience VARCHAR(150),
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE brands (
    brandId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    logoUrl VARCHAR(250) NOT NULL,
    description VARCHAR(300) NOT NULL,
    marketingFocusId INT NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL,
    employeeId INT NOT NULL,
    FOREIGN KEY (marketingFocusId) REFERENCES marketingFocus(marketingFocusId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE websites (
    websiteId INT AUTO_INCREMENT PRIMARY KEY,
    brandId INT NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    url VARCHAR(250) NOT NULL UNIQUE,
    countryId INT NOT NULL,
    configJson JSON NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    employeeId INT NOT NULL,
    FOREIGN KEY (brandId) REFERENCES brands(brandId),
    FOREIGN KEY (countryId) REFERENCES countries(countryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE productCategories (
    productCategoryId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE baseProducts (
    baseProductId INT AUTO_INCREMENT PRIMARY KEY,
    productCategoryId INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(300),
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    FOREIGN KEY (productCategoryId) REFERENCES productCategories(productCategoryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE commercialProducts (
    commercialProductId INT AUTO_INCREMENT PRIMARY KEY,
    brandId INT NOT NULL,
    baseProductId INT NOT NULL,
    productVariantId INT NOT NULL,
    name VARCHAR(80) NOT NULL,
    label VARCHAR(250) NOT NULL,
    description VARCHAR(300),
    productAttributes JSON,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP,
    employeeId INT NOT NULL,
    FOREIGN KEY (brandId) REFERENCES brands(brandId),
    FOREIGN KEY (baseProductId) REFERENCES baseProducts(baseProductId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE productPrices (
    productPriceId INT AUTO_INCREMENT PRIMARY KEY,
    commercialProductId INT NOT NULL,
    websiteId INT NOT NULL,
    currencyId INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    validFrom DATE NOT NULL,
    validTo DATE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_price_product (commercialProductId),
    INDEX idx_price_website (websiteId),
    INDEX idx_price_currency (currencyId),
    FOREIGN KEY (commercialProductId) REFERENCES commercialProducts(commercialProductId),
    FOREIGN KEY (websiteId) REFERENCES websites(websiteId),
    FOREIGN KEY (currencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE customers (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    passwordHash VARBINARY(255) NOT NULL,
    phone VARCHAR(15),
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customerAddresses (
    customerAddressId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    addressId INT NOT NULL,
    isDefault BOOLEAN NOT NULL DEFAULT FALSE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ca_customer (customerId),
    INDEX idx_ca_address (addressId),
    FOREIGN KEY (customerId) REFERENCES customers(customerId),
    FOREIGN KEY (addressId) REFERENCES addresses(addressId)
);

CREATE TABLE orderStatuses (
    orderStatusId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    orderId INT AUTO_INCREMENT PRIMARY KEY,
    websiteId INT NOT NULL,
    customerId INT NOT NULL,
    addressId INT NOT NULL,
    currencyId INT NOT NULL,
    orderStatusId INT NOT NULL,
    exchangeRateId INT NOT NULL,
    orderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    taxAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    shippingCost DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_customer (customerId),
    INDEX idx_order_website (websiteId),
    INDEX idx_order_currency (currencyId),
    INDEX idx_order_status (orderStatusId),
    FOREIGN KEY (websiteId) REFERENCES websites(websiteId),
    FOREIGN KEY (customerId) REFERENCES customers(customerId),
    FOREIGN KEY (addressId) REFERENCES addresses(addressId),
    FOREIGN KEY (currencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (orderStatusId) REFERENCES orderStatuses(orderStatusId),
    FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(exchangeRateId)
);

CREATE TABLE orderTaxes (
    orderTaxId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    taxTypeId INT NOT NULL,
    taxRateId INT NOT NULL,
    taxableAmount DECIMAL(10,2) NOT NULL,
    taxAmount DECIMAL(10,2) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ot_order (orderId),
    FOREIGN KEY (orderId) REFERENCES orders(orderId),
    FOREIGN KEY (taxTypeId) REFERENCES taxTypes(taxTypeId),
    FOREIGN KEY (taxRateId) REFERENCES taxRates(taxRateId)
);

CREATE TABLE orderDetails (
    orderDetailId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    commercialProductId INT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    lineSubtotal DECIMAL(10,2) NOT NULL,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_od_order (orderId),
    INDEX idx_od_product (commercialProductId),
    FOREIGN KEY (orderId) REFERENCES orders(orderId),
    FOREIGN KEY (commercialProductId) REFERENCES commercialProducts(commercialProductId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE shippingStatuses (
    shippingStatusId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE couriers (
    courierId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(100) NOT NULL,
    countryId INT NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_courier_country (countryId),
    FOREIGN KEY (countryId) REFERENCES countries(countryId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE shipments (
    shipmentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    courierId INT NOT NULL,
    trackingCode VARCHAR(50) NOT NULL UNIQUE,
    shippingStatusId INT NOT NULL,
    shippedAt DATETIME,
    deliveredAt DATETIME,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_ship_order (orderId),
    INDEX idx_ship_courier (courierId),
    FOREIGN KEY (orderId) REFERENCES orders(orderId),
    FOREIGN KEY (courierId) REFERENCES couriers(courierId),
    FOREIGN KEY (shippingStatusId) REFERENCES shippingStatuses(shippingStatusId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE processTypes (
    processTypeId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE processLogs (
    processLogId INT AUTO_INCREMENT PRIMARY KEY,
    processTypeId INT NOT NULL,
    logLevel VARCHAR(10) NOT NULL,
    message TEXT NOT NULL,
    isError BOOLEAN NOT NULL DEFAULT FALSE,
    executionTimeMs INT,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_pl_process (processTypeId),
    INDEX idx_pl_employee (employeeId),
    FOREIGN KEY (processTypeId) REFERENCES processTypes(processTypeId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE paymentMethods (
    paymentMethodId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paymentStatuses (
    paymentStatusId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description VARCHAR(100) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE payments (
    paymentId INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    paymentMethodId INT NOT NULL,
    currencyId INT NOT NULL,
    exchangeRateId INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    amountUsd DECIMAL(10,2) NOT NULL,
    paymentDate DATETIME NOT NULL,
    paymentStatusId INT NOT NULL,
    transactionReference VARCHAR(100),
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    employeeId INT NOT NULL,
    INDEX idx_pay_order (orderId),
    INDEX idx_pay_method (paymentMethodId),
    INDEX idx_pay_currency (currencyId),
    INDEX idx_pay_status (paymentStatusId),
    FOREIGN KEY (orderId) REFERENCES orders(orderId),
    FOREIGN KEY (paymentMethodId) REFERENCES paymentMethods(paymentMethodId),
    FOREIGN KEY (currencyId) REFERENCES currencies(currencyId),
    FOREIGN KEY (exchangeRateId) REFERENCES exchangeRates(exchangeRateId),
    FOREIGN KEY (paymentStatusId) REFERENCES paymentStatuses(paymentStatusId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId)
);

CREATE TABLE userGroups (
    groupId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(150) NOT NULL,
    isActive BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employeeGroups (
    employeeGroupId INT AUTO_INCREMENT PRIMARY KEY,
    employeeId INT NOT NULL,
    groupId INT NOT NULL,
    assignedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignedBy INT NOT NULL,
    INDEX idx_eg_employee (employeeId),
    INDEX idx_eg_group (groupId),
    FOREIGN KEY (employeeId) REFERENCES employees(employeeId),
    FOREIGN KEY (groupId) REFERENCES userGroups(groupId),
    FOREIGN KEY (assignedBy) REFERENCES employees(employeeId)
);

-- CITIES
CREATE INDEX idx_cities_country ON cities(countryId);

-- ADDRESSES
CREATE INDEX idx_addresses_city ON addresses(cityId);
CREATE INDEX idx_addresses_employee ON addresses(employeeId);

-- TAX TYPES
CREATE INDEX idx_taxTypes_employee ON taxTypes(employeeId);

-- TAX RATES
CREATE INDEX idx_taxRates_country ON taxRates(countryId);
CREATE INDEX idx_taxRates_taxType ON taxRates(taxTypeId);
CREATE INDEX idx_taxRates_employee ON taxRates(employeeId);

-- CURRENCIES
CREATE INDEX idx_currencies_country ON currencies(countryId);
CREATE INDEX idx_currencies_employee ON currencies(employeeId);

-- EXCHANGE RATES
CREATE INDEX idx_exchangeRates_from ON exchangeRates(fromCurrencyId);
CREATE INDEX idx_exchangeRates_to ON exchangeRates(toCurrencyId);
CREATE INDEX idx_exchangeRates_employee ON exchangeRates(employeeId);

-- EXCHANGE HISTORY
CREATE INDEX idx_exchangeHistory_rate ON exchangeHistory(exchangeRateId);
CREATE INDEX idx_exchangeHistory_from ON exchangeHistory(fromCurrencyId);
CREATE INDEX idx_exchangeHistory_to ON exchangeHistory(toCurrencyId);
CREATE INDEX idx_exchangeHistory_employee ON exchangeHistory(employeeId);

-- MARKETING FOCUS
CREATE INDEX idx_marketingFocus_employee ON marketingFocus(employeeId);

-- BRANDS
CREATE INDEX idx_brands_marketingFocus ON brands(marketingFocusId);
CREATE INDEX idx_brands_employee ON brands(employeeId);

-- WEBSITES
CREATE INDEX idx_websites_brand ON websites(brandId);
CREATE INDEX idx_websites_country ON websites(countryId);
CREATE INDEX idx_websites_employee ON websites(employeeId);

-- PRODUCT CATEGORIES
CREATE INDEX idx_productCategories_employee ON productCategories(employeeId);

-- BASE PRODUCTS
CREATE INDEX idx_baseProducts_category ON baseProducts(productCategoryId);
CREATE INDEX idx_baseProducts_employee ON baseProducts(employeeId);

-- COMMERCIAL PRODUCTS
CREATE INDEX idx_commercialProducts_brand ON commercialProducts(brandId);
CREATE INDEX idx_commercialProducts_base ON commercialProducts(baseProductId);
CREATE INDEX idx_commercialProducts_employee ON commercialProducts(employeeId);

-- PRODUCT PRICES
CREATE INDEX idx_productPrices_product ON productPrices(commercialProductId);
CREATE INDEX idx_productPrices_website ON productPrices(websiteId);
CREATE INDEX idx_productPrices_currency ON productPrices(currencyId);
CREATE INDEX idx_productPrices_employee ON productPrices(employeeId);

-- CUSTOMER ADDRESSES
CREATE INDEX idx_customerAddresses_customer ON customerAddresses(customerId);
CREATE INDEX idx_customerAddresses_address ON customerAddresses(addressId);

-- ORDERS
CREATE INDEX idx_orders_website ON orders(websiteId);
CREATE INDEX idx_orders_customer ON orders(customerId);
CREATE INDEX idx_orders_address ON orders(addressId);
CREATE INDEX idx_orders_currency ON orders(currencyId);
CREATE INDEX idx_orders_status ON orders(orderStatusId);
CREATE INDEX idx_orders_exchangeRate ON orders(exchangeRateId);

-- ORDER TAXES
CREATE INDEX idx_orderTaxes_order ON orderTaxes(orderId);
CREATE INDEX idx_orderTaxes_type ON orderTaxes(taxTypeId);
CREATE INDEX idx_orderTaxes_rate ON orderTaxes(taxRateId);

-- ORDER DETAILS
CREATE INDEX idx_orderDetails_order ON orderDetails(orderId);
CREATE INDEX idx_orderDetails_product ON orderDetails(commercialProductId);
CREATE INDEX idx_orderDetails_employee ON orderDetails(employeeId);

-- COURIERS
CREATE INDEX idx_couriers_country ON couriers(countryId);
CREATE INDEX idx_couriers_employee ON couriers(employeeId);

-- SHIPMENTS
CREATE INDEX idx_shipments_order ON shipments(orderId);
CREATE INDEX idx_shipments_courier ON shipments(courierId);
CREATE INDEX idx_shipments_status ON shipments(shippingStatusId);
CREATE INDEX idx_shipments_employee ON shipments(employeeId);

-- PROCESS LOGS
CREATE INDEX idx_processLogs_process ON processLogs(processTypeId);
CREATE INDEX idx_processLogs_employee ON processLogs(employeeId);

-- PAYMENTS
CREATE INDEX idx_payments_order ON payments(orderId);
CREATE INDEX idx_payments_method ON payments(paymentMethodId);
CREATE INDEX idx_payments_currency ON payments(currencyId);
CREATE INDEX idx_payments_exchange ON payments(exchangeRateId);
CREATE INDEX idx_payments_status ON payments(paymentStatusId);
CREATE INDEX idx_payments_employee ON payments(employeeId);

-- EMPLOYEE GROUPS
CREATE INDEX idx_employeeGroups_employee ON employeeGroups(employeeId);
CREATE INDEX idx_employeeGroups_group ON employeeGroups(groupId);
CREATE INDEX idx_employeeGroups_assignedBy ON employeeGroups(assignedBy);