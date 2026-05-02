USE DynamicBrandsRetail;

--esto lo ponemos para evitar errores por repeticion
DROP PROCEDURE IF EXISTS spRegisterDynamic;
DROP PROCEDURE IF EXISTS spInsertEmployee;
DROP PROCEDURE IF EXISTS spInsertCountry;
DROP PROCEDURE IF EXISTS spInsertProcessType;
DROP PROCEDURE IF EXISTS spInsertCity;
DROP PROCEDURE IF EXISTS spInsertAddress;
DROP PROCEDURE IF EXISTS spInsertCurrency;
DROP PROCEDURE IF EXISTS spInsertExchangeRate;
DROP PROCEDURE IF EXISTS spInsertMarketingFocus;
DROP PROCEDURE IF EXISTS spInsertBrand;
DROP PROCEDURE IF EXISTS spInsertWebsite;
DROP PROCEDURE IF EXISTS spInsertProductCategory;
DROP PROCEDURE IF EXISTS spInsertBaseProduct;
DROP PROCEDURE IF EXISTS spInsertOrderStatus;
DROP PROCEDURE IF EXISTS spInsertPaymentMethod;
DROP PROCEDURE IF EXISTS spInsertPaymentStatus;
DROP PROCEDURE IF EXISTS spInsertShippingStatus;
DROP PROCEDURE IF EXISTS spInsertCourier;
DROP PROCEDURE IF EXISTS spInsertTaxType;
DROP PROCEDURE IF EXISTS spInsertTaxRate;
DROP PROCEDURE IF EXISTS spInsertCustomer;
DROP PROCEDURE IF EXISTS spInsertCustomerAddress;
DROP PROCEDURE IF EXISTS spInsertCommercialProductsJson;
DROP PROCEDURE IF EXISTS spRegisterOrderJson;
DROP PROCEDURE IF EXISTS spRegisterPayment;
DROP PROCEDURE IF EXISTS spRegisterShipment;
DROP PROCEDURE IF EXISTS spSeedDynamicBrands;

-- Implemente un SP independiente que registre cada paso ejecutado en las tablas de destino, 
-- este SP es llamado por los otros SP de inserción de datos.
DROP PROCEDURE IF EXISTS spRegisterDynamic;
DELIMITER $$
CREATE PROCEDURE spRegisterDynamic(
	processTypeName VARCHAR(50),
	logLevelData VARCHAR(10),
	messageData TEXT,
	isErrorData BOOLEAN,
	executionTimeData INT,
	employeeInChargeID INT
)
BEGIN
	DECLARE processTypeIDSaved INT;

	SELECT processTypeId
	INTO processTypeIDSaved
	FROM processTypes
	WHERE name = processTypeName
	LIMIT 1;

	INSERT INTO processLogs(
		processTypeId,
		logLevel,
		message,
		isError,
		executionTimeMs,
		employeeId
	)
	VALUES(
		processTypeIDSaved,
		logLevelData,
		messageData,
		isErrorData,
		executionTimeData,
		employeeInChargeID
	);
END$$
DELIMITER ;

-- sp que son sencillos
-- insertar empleados
DROP PROCEDURE IF EXISTS spInsertEmployee;
DELIMITER $$
CREATE PROCEDURE spInsertEmployee(
	fullNameData VARCHAR(150), emailData VARCHAR(80), passwordData VARBINARY(255))
BEGIN
	INSERT INTO employees(fullName, email, passwordHash, isActive, createdAt)
	VALUES(fullNameData, emailData, passwordData, TRUE, NOW());
END$$

DELIMITER ;

-- insertar paises 
DELIMITER $$
CREATE PROCEDURE spInsertCountry(
	countryName VARCHAR(80), isoCodeData CHAR(2), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCountry','ERROR','Error insertando país',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;
	CALL spRegisterDynamic('spInsertCountry','INFO','Inicio registro país',FALSE,0,employeeInChargeID);

	INSERT INTO countries(name, isoCode, isActive, createdAt
	)
	VALUES(countryName, isoCodeData, TRUE, NOW()
	);

	CALL spRegisterDynamic('spInsertCountry','INFO','País registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar tipo de proceso
DELIMITER $$
CREATE PROCEDURE spInsertProcessType(
	nameData VARCHAR(50), descData VARCHAR(150)
)
BEGIN
	INSERT INTO processTypes(name, description, isActive)
	VALUES(nameData, descData, TRUE);
END$$
DELIMITER ;

-- insertar ciudad
DELIMITER $$
CREATE PROCEDURE spInsertCity(
	countryID INT, cityName VARCHAR(50), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCity','ERROR','Error insertando ciudad',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCity','INFO','Inicio registro ciudad',FALSE,0,employeeInChargeID);

	INSERT INTO cities(countryId, name, createdAt, isActive)
	VALUES(countryID, cityName, NOW(), TRUE);

	CALL spRegisterDynamic('spInsertCity','INFO','Ciudad registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar dirección
DELIMITER $$
CREATE PROCEDURE spInsertAddress(
	cityID INT, exactAddressData VARCHAR(250), addressLine2Data VARCHAR(250),
	postalCodeData VARCHAR(20), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertAddress','ERROR','Error insertando dirección',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertAddress','INFO','Inicio registro dirección',FALSE,0,employeeInChargeID);

	INSERT INTO addresses(cityId, exactAddress, addressLine2, postalCode, isActive, createdAt, employeeId)
	VALUES(cityID, exactAddressData, addressLine2Data, postalCodeData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertAddress','INFO','Dirección registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar moneda
DELIMITER $$
CREATE PROCEDURE spInsertCurrency(
	symbolData VARCHAR(5), nameData VARCHAR(50), countryID INT,
	isoCodeData CHAR(3), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCurrency','ERROR','Error insertando moneda',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCurrency','INFO','Inicio registro moneda',FALSE,0,employeeInChargeID);

	INSERT INTO currencies(symbol, name, countryId, isoCode, createdAt, isActive, employeeId)
	VALUES(symbolData, nameData, countryID, isoCodeData, NOW(), TRUE, employeeInChargeID);

	CALL spRegisterDynamic('spInsertCurrency','INFO','Moneda registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;


-- insertar tipo de cambio
DELIMITER $$
CREATE PROCEDURE spInsertExchangeRate(
	fromCurrencyID INT, toCurrencyID INT,
	rateData DECIMAL(10,4), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertExchangeRate','ERROR','Error insertando tipo de cambio',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertExchangeRate','INFO','Inicio registro tipo de cambio',FALSE,0,employeeInChargeID);

	INSERT INTO exchangeRates(fromCurrencyId, toCurrencyId, rate, createdAt, employeeId)
	VALUES(fromCurrencyID, toCurrencyID, rateData, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertExchangeRate','INFO','Tipo de cambio registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar enfoque de marketing
DELIMITER $$
CREATE PROCEDURE spInsertMarketingFocus(
	nameData VARCHAR(100), descData VARCHAR(250),
	targetAudienceData VARCHAR(150), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertMarketingFocus','ERROR','Error insertando enfoque de marketing',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertMarketingFocus','INFO','Inicio registro enfoque de marketing',FALSE,0,employeeInChargeID);

	INSERT INTO marketingFocus(name, description, targetAudience, isActive, createdAt, employeeId)
	VALUES(nameData, descData, targetAudienceData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertMarketingFocus','INFO','Enfoque de marketing registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar marca
DELIMITER $$
CREATE PROCEDURE spInsertBrand(
	nameData VARCHAR(100), logoUrlData VARCHAR(250),
	descData VARCHAR(300), marketingFocusID INT, employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertBrand','ERROR','Error insertando marca',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertBrand','INFO','Inicio registro marca',FALSE,0,employeeInChargeID);

	INSERT INTO brands(name, logoUrl, description, marketingFocusId, isActive, createdAt, employeeId)
	VALUES(nameData, logoUrlData, descData, marketingFocusID, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertBrand','INFO','Marca registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar sitio web dinámico
DELIMITER $$
CREATE PROCEDURE spInsertWebsite(
	brandID INT, nameData VARCHAR(100), urlData VARCHAR(250),
	countryID INT, configJsonData JSON, employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertWebsite','ERROR','Error insertando sitio web',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertWebsite','INFO','Inicio registro sitio web',FALSE,0,employeeInChargeID);

	INSERT INTO websites(brandId, name, url, countryId, configJson, isActive, createdAt, employeeId)
	VALUES(brandID, nameData, urlData, countryID, configJsonData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertWebsite','INFO','Sitio web registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar categoría de producto
DELIMITER $$
CREATE PROCEDURE spInsertProductCategory(
	nameData VARCHAR(100), descData VARCHAR(150), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertProductCategory','ERROR','Error insertando categoría',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertProductCategory','INFO','Inicio registro categoría',FALSE,0,employeeInChargeID);

	INSERT INTO productCategories(name, description, isActive, createdAt, employeeId)
	VALUES(nameData, descData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertProductCategory','INFO','Categoría registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar producto base
DELIMITER $$
CREATE PROCEDURE spInsertBaseProduct(
	productCategoryID INT, nameData VARCHAR(100),
	descData VARCHAR(300), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertBaseProduct','ERROR','Error insertando producto base',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertBaseProduct','INFO','Inicio registro producto base',FALSE,0,employeeInChargeID);

	INSERT INTO baseProducts(productCategoryId, name, description, isActive, createdAt, employeeId)
	VALUES(productCategoryID, nameData, descData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertBaseProduct','INFO','Producto base registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar estado de orden
DELIMITER $$
CREATE PROCEDURE spInsertOrderStatus(
	nameData VARCHAR(30), descData VARCHAR(100), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertOrderStatus','ERROR','Error insertando estado de orden',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertOrderStatus','INFO','Inicio registro estado de orden',FALSE,0,employeeInChargeID);

	INSERT INTO orderStatuses(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterDynamic('spInsertOrderStatus','INFO','Estado de orden registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar método de pago
DELIMITER $$
CREATE PROCEDURE spInsertPaymentMethod(
	nameData VARCHAR(50), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertPaymentMethod','ERROR','Error insertando método de pago',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertPaymentMethod','INFO','Inicio registro método de pago',FALSE,0,employeeInChargeID);

	INSERT INTO paymentMethods(name, isActive, createdAt)
	VALUES(nameData, TRUE, NOW());

	CALL spRegisterDynamic('spInsertPaymentMethod','INFO','Método de pago registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar estado de pago
DELIMITER $$
CREATE PROCEDURE spInsertPaymentStatus(
	nameData VARCHAR(30), descData VARCHAR(100), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertPaymentStatus','ERROR','Error insertando estado de pago',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertPaymentStatus','INFO','Inicio registro estado de pago',FALSE,0,employeeInChargeID);

	INSERT INTO paymentStatuses(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterDynamic('spInsertPaymentStatus','INFO','Estado de pago registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar estado de envío
DELIMITER $$
CREATE PROCEDURE spInsertShippingStatus(
	nameData VARCHAR(30), descData VARCHAR(100), employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertShippingStatus','ERROR','Error insertando estado de envío',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertShippingStatus','INFO','Inicio registro estado de envío',FALSE,0,employeeInChargeID);

	INSERT INTO shippingStatuses(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterDynamic('spInsertShippingStatus','INFO','Estado de envío registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar courier
DELIMITER $$
CREATE PROCEDURE spInsertCourier(
	nameData VARCHAR(50), phoneData VARCHAR(50),
	emailData VARCHAR(100), countryID INT, employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCourier','ERROR','Error insertando courier',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCourier','INFO','Inicio registro courier',FALSE,0,employeeInChargeID);

	INSERT INTO couriers(name, phone, email, countryId, isActive, createdAt, employeeId)
	VALUES(nameData, phoneData, emailData, countryID, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterDynamic('spInsertCourier','INFO','Courier registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar tipo de impuesto
DELIMITER $$
CREATE PROCEDURE spInsertTaxType(
	nameData VARCHAR(50),
	descData VARCHAR(150),
	appliesToData VARCHAR(30),
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertTaxType','ERROR','Error insertando tipo de impuesto',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertTaxType','INFO','Inicio registro tipo de impuesto',FALSE,0,employeeInChargeID);

	INSERT INTO taxTypes(
		name,
		description,
		appliesTo,
		isActive,
		createdAt,
		employeeId
	)
	VALUES(
		nameData,
		descData,
		appliesToData,
		TRUE,
		NOW(),
		employeeInChargeID
	);

	CALL spRegisterDynamic('spInsertTaxType','INFO','Tipo de impuesto registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar tasa de impuesto
DELIMITER $$
CREATE PROCEDURE spInsertTaxRate(
	countryID INT,
	taxTypeID INT,
	rateData DECIMAL(5,2),
	checksumData VARCHAR(64),
	validFromDate DATE,
	validToDate DATE,
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertTaxRate','ERROR','Error insertando tasa de impuesto',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertTaxRate','INFO','Inicio registro tasa de impuesto',FALSE,0,employeeInChargeID);

	INSERT INTO taxRates(
		countryId,
		taxTypeId,
		rate,
		checksum,
		validFrom,
		validTo,
		isActive,
		createdAt,
		employeeId
	)
	VALUES(
		countryID,
		taxTypeID,
		rateData,
		checksumData,
		validFromDate,
		validToDate,
		TRUE,
		NOW(),
		employeeInChargeID
	);

	CALL spRegisterDynamic('spInsertTaxRate','INFO','Tasa de impuesto registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar cliente
DELIMITER $$
CREATE PROCEDURE spInsertCustomer(
	firstNameData VARCHAR(50),
	lastNameData VARCHAR(100),
	emailData VARCHAR(80),
	passwordData VARBINARY(255),
	phoneData VARCHAR(15),
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCustomer','ERROR','Error insertando cliente',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCustomer','INFO','Inicio registro cliente',FALSE,0,employeeInChargeID);

	INSERT INTO customers(
		firstName,
		lastName,
		email,
		passwordHash,
		phone,
		isActive,
		createdAt
	)
	VALUES(
		firstNameData,
		lastNameData,
		emailData,
		passwordData,
		phoneData,
		TRUE,
		NOW()
	);

	CALL spRegisterDynamic('spInsertCustomer','INFO','Cliente registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- insertar dirección de cliente
DELIMITER $$
CREATE PROCEDURE spInsertCustomerAddress(
	customerID INT,
	addressID INT,
	isDefaultData BOOLEAN,
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spInsertCustomerAddress','ERROR','Error insertando dirección de cliente',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCustomerAddress','INFO','Inicio registro dirección de cliente',FALSE,0,employeeInChargeID);

	INSERT INTO customerAddresses(
		customerId,
		addressId,
		isDefault,
		createdAt
	)
	VALUES(
		customerID,
		addressID,
		isDefaultData,
		NOW()
	);

	CALL spRegisterDynamic('spInsertCustomerAddress','INFO','Dirección de cliente registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- ahora sp que unifican tablas 
-- insertar productos comerciales con precios desde JSON
DELIMITER $$
CREATE PROCEDURE spInsertCommercialProductsJson(
	productsJson JSON, employeeInChargeID INT
)
BEGIN
	DECLARE counterData INT DEFAULT 0;
	DECLARE totalItems INT DEFAULT 0;

	DECLARE commercialProductIDSaved INT;

	DECLARE brandID INT;
	DECLARE baseProductID INT;
	DECLARE productVariantID INT;
	DECLARE productName VARCHAR(80);
	DECLARE labelData VARCHAR(250);
	DECLARE descData VARCHAR(300);
	DECLARE attributesData JSON;

	DECLARE websiteID INT;
	DECLARE currencyID INT;
	DECLARE priceData DECIMAL(10,2);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		CALL spRegisterDynamic(
			'spInsertCommercialProductsJson',
			'ERROR',
			'Error insertando productos comerciales',
			TRUE,
			0,
			employeeInChargeID
		);
		RESIGNAL;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spInsertCommercialProductsJson','INFO','Inicio registro productos comerciales',FALSE,0,employeeInChargeID);

	SET totalItems = JSON_LENGTH(productsJson);

	WHILE counterData < totalItems DO

		SET brandID = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].brandId')));
		SET baseProductID = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].baseProductId')));
		SET productVariantID = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].productVariantId')));
		SET productName = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].name')));
		SET labelData = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].label')));
		SET descData = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].description')));
		SET attributesData = JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].productAttributes'));

		SET websiteID = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].websiteId')));
		SET currencyID = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].currencyId')));
		SET priceData = JSON_UNQUOTE(JSON_EXTRACT(productsJson, CONCAT('$[', counterData, '].price')));

		INSERT INTO commercialProducts(
			brandId,
			baseProductId,
			productVariantId,
			name,
			label,
			description,
			productAttributes,
			isActive,
			createdAt,
			employeeId
		)
		VALUES(
			brandID,
			baseProductID,
			productVariantID,
			productName,
			labelData,
			descData,
			attributesData,
			TRUE,
			NOW(),
			employeeInChargeID
		);

		SET commercialProductIDSaved = LAST_INSERT_ID();

		INSERT INTO productPrices(
			commercialProductId,
			websiteId,
			currencyId,
			price,
			validFrom,
			validTo,
			isActive,
			createdAt,
			employeeId
		)
		VALUES(
			commercialProductIDSaved,
			websiteID,
			currencyID,
			priceData,
			CURDATE(),
			NULL,
			TRUE,
			NOW(),
			employeeInChargeID
		);

		SET counterData = counterData + 1;

	END WHILE;

	CALL spRegisterDynamic('spInsertCommercialProductsJson','INFO','Productos comerciales registrados correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- registrar pago
DELIMITER $$
CREATE PROCEDURE spRegisterPayment(
	orderID INT,
	paymentMethodID INT,
	currencyID INT,
	exchangeRateID INT,
	amountData DECIMAL(10,2),
	amountUsdData DECIMAL(10,2),
	paymentStatusID INT,
	transactionReferenceData VARCHAR(100),
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spRegisterPayment','ERROR','Error registrando pago',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spRegisterPayment','INFO','Inicio registro pago',FALSE,0,employeeInChargeID);

	INSERT INTO payments(
		orderId,
		paymentMethodId,
		currencyId,
		exchangeRateId,
		amount,
		amountUsd,
		paymentDate,
		paymentStatusId,
		transactionReference,
		createdAt,
		employeeId
	)
	VALUES(
		orderID,
		paymentMethodID,
		currencyID,
		exchangeRateID,
		amountData,
		amountUsdData,
		NOW(),
		paymentStatusID,
		transactionReferenceData,
		NOW(),
		employeeInChargeID
	);

	CALL spRegisterDynamic('spRegisterPayment','INFO','Pago registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- registrar envío
DELIMITER $$
CREATE PROCEDURE spRegisterShipment(
	orderID INT, courierID INT, trackingCodeData VARCHAR(50),
	shippingStatusID INT, shippedAtData DATETIME, deliveredAtData DATETIME,
	employeeInChargeID INT
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spRegisterShipment','ERROR','Error registrando envío',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spRegisterShipment','INFO','Inicio registro envío',FALSE,0,employeeInChargeID);

	INSERT INTO shipments(
		orderId,
		courierId,
		trackingCode,
		shippingStatusId,
		shippedAt,
		deliveredAt,
		isActive,
		createdAt,
		employeeId
	)
	VALUES(
		orderID,
		courierID,
		trackingCodeData,
		shippingStatusID,
		shippedAtData,
		deliveredAtData,
		TRUE,
		NOW(),
		employeeInChargeID
	);

	CALL spRegisterDynamic('spRegisterShipment','INFO','Envío registrado correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;

-- registrar orden con detalles desde JSON
DELIMITER $$
CREATE PROCEDURE spRegisterOrderJson(
	websiteID INT,
	customerID INT,
	addressID INT,
	currencyID INT,
	orderStatusID INT,
	exchangeRateID INT,
	taxTypeID INT,
	taxRateID INT,
	shippingCostData DECIMAL(10,2),
	detailsJson JSON,
	employeeInChargeID INT
)
BEGIN
	DECLARE counterData INT DEFAULT 0;
	DECLARE totalItems INT DEFAULT 0;

	DECLARE orderIDSaved INT;
	DECLARE commercialProductID INT;
	DECLARE quantityData INT;
	DECLARE unitPriceData DECIMAL(10,2);
	DECLARE lineSubtotalData DECIMAL(10,2);

	DECLARE subtotalData DECIMAL(10,2) DEFAULT 0;
	DECLARE taxRateData DECIMAL(5,2) DEFAULT 0;
	DECLARE taxAmountData DECIMAL(10,2) DEFAULT 0;
	DECLARE totalData DECIMAL(10,2) DEFAULT 0;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		CALL spRegisterDynamic('spRegisterOrderJson','ERROR','Error registrando orden',TRUE,0,employeeInChargeID);
		ROLLBACK;
	END;

	START TRANSACTION;

	CALL spRegisterDynamic('spRegisterOrderJson','INFO','Inicio registro orden',FALSE,0,employeeInChargeID);

	SET totalItems = JSON_LENGTH(detailsJson);

	WHILE counterData < totalItems DO
		SET quantityData = JSON_UNQUOTE(JSON_EXTRACT(detailsJson, CONCAT('$[', counterData, '].quantity')));
		SET unitPriceData = JSON_UNQUOTE(JSON_EXTRACT(detailsJson, CONCAT('$[', counterData, '].unitPrice')));

		SET subtotalData = subtotalData + (quantityData * unitPriceData);
		SET counterData = counterData + 1;
	END WHILE;

	SELECT rate
	INTO taxRateData
	FROM taxRates
	WHERE taxRateId = taxRateID
	LIMIT 1;

	SET taxAmountData = subtotalData * (taxRateData / 100);
	SET totalData = subtotalData + taxAmountData + shippingCostData;

	INSERT INTO orders(
		websiteId,
		customerId,
		addressId,
		currencyId,
		orderStatusId,
		exchangeRateId,
		orderDate,
		subtotal,
		taxAmount,
		shippingCost,
		total,
		isActive,
		createdAt
	)
	VALUES(
		websiteID,
		customerID,
		addressID,
		currencyID,
		orderStatusID,
		exchangeRateID,
		NOW(),
		subtotalData,
		taxAmountData,
		shippingCostData,
		totalData,
		TRUE,
		NOW()
	);

	SET orderIDSaved = LAST_INSERT_ID();

	SET counterData = 0;

	WHILE counterData < totalItems DO
		SET commercialProductID = JSON_UNQUOTE(JSON_EXTRACT(detailsJson, CONCAT('$[', counterData, '].commercialProductId')));
		SET quantityData = JSON_UNQUOTE(JSON_EXTRACT(detailsJson, CONCAT('$[', counterData, '].quantity')));
		SET unitPriceData = JSON_UNQUOTE(JSON_EXTRACT(detailsJson, CONCAT('$[', counterData, '].unitPrice')));

		SET lineSubtotalData = quantityData * unitPriceData;

		INSERT INTO orderDetails(
			orderId,
			commercialProductId,
			quantity,
			unitPrice,
			lineSubtotal,
			createdAt,
			employeeId
		)
		VALUES(
			orderIDSaved,
			commercialProductID,
			quantityData,
			unitPriceData,
			lineSubtotalData,
			NOW(),
			employeeInChargeID
		);

		SET counterData = counterData + 1;
	END WHILE;

	INSERT INTO orderTaxes(
		orderId,
		taxTypeId,
		taxRateId,
		taxableAmount,
		taxAmount,
		createdAt
	)
	VALUES(
		orderIDSaved,
		taxTypeID,
		taxRateID,
		subtotalData,
		taxAmountData,
		NOW()
	);

	CALL spRegisterDynamic('spRegisterOrderJson','INFO','Orden registrada correctamente',FALSE,0,employeeInChargeID);

	COMMIT;
END$$
DELIMITER ;


-- orquestador que llama todos los sp anteriores para la insercion de datos}
-- orquestador final DynamicBrands
DROP PROCEDURE IF EXISTS spSeedDynamicBrands;

DELIMITER $$

CREATE PROCEDURE spSeedDynamicBrands()
BEGIN
	DECLARE adminID INT;

	DECLARE costaRicaID INT;
	DECLARE nicaraguaID INT;
	DECLARE colombiaID INT;
	DECLARE peruID INT;
	DECLARE mexicoID INT;

	DECLARE sanJoseID INT;
	DECLARE addressID INT;

	DECLARE crcID INT;
	DECLARE usdID INT;
	DECLARE exchangeRateID INT;

	DECLARE focusID INT;
	DECLARE brandID INT;

	DECLARE websiteID INT;
	DECLARE categoryID INT;
	DECLARE baseProductID INT;
	DECLARE commercialProductID INT;

	DECLARE orderStatusID INT;
	DECLARE paymentMethodID INT;
	DECLARE paymentStatusID INT;
	DECLARE shippingStatusID INT;
	DECLARE courierID INT;

	DECLARE taxTypeID INT;
	DECLARE taxRateID INT;

	DECLARE customerID INT;
	DECLARE orderID INT;

	-- persona administradora de los empleados
	INSERT IGNORE INTO employees(fullName, email, passwordHash, isActive, createdAt)
	VALUES('Admin Sistema', 'admin@dynamicbrands.com', 'hash123', TRUE, NOW());

	SELECT e.employeeId INTO adminID
	FROM employees e
	WHERE e.email = 'admin@dynamicbrands.com'
	ORDER BY e.employeeId DESC
	LIMIT 1;

	IF adminID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener adminID';
	END IF;

	-- Insertar tipos de procesos 
	INSERT IGNORE INTO processTypes(name, description, isActive)
	VALUES
	('spInsertCountry','Inserta países',TRUE),
	('spInsertCity','Inserta ciudades',TRUE),
	('spInsertAddress','Inserta direcciones',TRUE),
	('spInsertCurrency','Inserta monedas',TRUE),
	('spInsertExchangeRate','Inserta tipos de cambio',TRUE),
	('spInsertMarketingFocus','Inserta enfoques de marketing',TRUE),
	('spInsertBrand','Inserta marcas',TRUE),
	('spInsertWebsite','Inserta sitios web dinámicos',TRUE),
	('spInsertProductCategory','Inserta categorías',TRUE),
	('spInsertBaseProduct','Inserta productos base',TRUE),
	('spInsertCommercialProductsJson','Inserta productos comerciales JSON',TRUE),
	('spInsertTaxType','Inserta tipos de impuesto',TRUE),
	('spInsertTaxRate','Inserta tasas de impuesto',TRUE),
	('spInsertCustomer','Inserta clientes',TRUE),
	('spInsertCustomerAddress','Inserta direcciones de cliente',TRUE),
	('spInsertOrderStatus','Inserta estados de orden',TRUE),
	('spInsertPaymentMethod','Inserta métodos de pago',TRUE),
	('spInsertPaymentStatus','Inserta estados de pago',TRUE),
	('spInsertShippingStatus','Inserta estados de envío',TRUE),
	('spInsertCourier','Inserta couriers',TRUE),
	('spRegisterOrderJson','Registra órdenes JSON',TRUE),
	('spRegisterPayment','Registra pagos',TRUE),
	('spRegisterShipment','Registra envíos',TRUE),
	('spSeedDynamicBrands','Orquestador DynamicBrands',TRUE);

	-- insertar los paises
	CALL spInsertCountry('Costa Rica', 'CR', adminID);
	CALL spInsertCountry('Nicaragua',  'NI', adminID);
	CALL spInsertCountry('Colombia',   'CO', adminID);
	CALL spInsertCountry('Peru',       'PE', adminID);
	CALL spInsertCountry('Mexico',     'MX', adminID);

	SELECT c.countryId INTO costaRicaID
	FROM countries c
	WHERE c.isoCode = 'CR'
	ORDER BY c.countryId DESC
	LIMIT 1;

	SELECT c.countryId INTO nicaraguaID
	FROM countries c
	WHERE c.isoCode = 'NI'
	ORDER BY c.countryId DESC
	LIMIT 1;

	SELECT c.countryId INTO colombiaID
	FROM countries c
	WHERE c.isoCode = 'CO'
	ORDER BY c.countryId DESC
	LIMIT 1;

	SELECT c.countryId INTO peruID
	FROM countries c
	WHERE c.isoCode = 'PE'
	ORDER BY c.countryId DESC
	LIMIT 1;

	SELECT c.countryId INTO mexicoID
	FROM countries c
	WHERE c.isoCode = 'MX'
	ORDER BY c.countryId DESC
	LIMIT 1;

	IF costaRicaID IS NULL OR nicaraguaID IS NULL OR colombiaID IS NULL
	   OR peruID IS NULL OR mexicoID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudieron obtener los countryId';
	END IF;

	-- colocar ciudad y direccion
	CALL spInsertCity(costaRicaID, 'San José', adminID);

	SELECT ci.cityId INTO sanJoseID
	FROM cities ci
	WHERE ci.name = 'San José'
	ORDER BY ci.cityId DESC
	LIMIT 1;

	IF sanJoseID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener sanJoseID';
	END IF;

	CALL spInsertAddress(
		sanJoseID,
		'Avenida Central, edificio principal',
		'Piso 2',
		'10101',
		adminID
	);

	SELECT a.addressId INTO addressID
	FROM addresses a
	ORDER BY a.addressId DESC
	LIMIT 1;

	IF addressID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener addressID';
	END IF;

	-- insertar las monedas por pais
	CALL spInsertCurrency('₡',  'Costa Rican Colon',  costaRicaID, 'CRC', adminID);
	CALL spInsertCurrency('C$', 'Nicaraguan Cordoba', nicaraguaID, 'NIO', adminID);
	CALL spInsertCurrency('$',  'Colombian Peso',     colombiaID,  'COP', adminID);
	CALL spInsertCurrency('S/', 'Peruvian Sol',       peruID,      'PEN', adminID);
	CALL spInsertCurrency('$',  'Mexican Peso',       mexicoID,    'MXN', adminID);
	CALL spInsertCurrency('$',  'US Dollar',          costaRicaID, 'USD', adminID);

	SELECT cu.currencyId INTO crcID
	FROM currencies cu
	WHERE cu.isoCode = 'CRC'
	ORDER BY cu.currencyId DESC
	LIMIT 1;

	SELECT cu.currencyId INTO usdID
	FROM currencies cu
	WHERE cu.isoCode = 'USD'
	ORDER BY cu.currencyId DESC
	LIMIT 1;

	IF crcID IS NULL OR usdID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudieron obtener crcID o usdID';
	END IF;

	-- insertar el tipo de cambio
	CALL spInsertExchangeRate(usdID, crcID, 520.0000, adminID);

	SELECT er.exchangeRateId INTO exchangeRateID
	FROM exchangeRates er
	WHERE er.fromCurrencyId = usdID
	  AND er.toCurrencyId   = crcID
	ORDER BY er.exchangeRateId DESC
	LIMIT 1;

	IF exchangeRateID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener exchangeRateID';
	END IF;

	-- insertar marca y el focus deseado
	CALL spInsertMarketingFocus(
		'Wellness Premium',
		'Productos naturales de alta gama con enfoque saludable',
		'Adultos interesados en bienestar natural',
		adminID
	);

	SELECT mf.marketingFocusId INTO focusID
	FROM marketingFocus mf
	WHERE mf.name = 'Wellness Premium'
	ORDER BY mf.marketingFocusId DESC
	LIMIT 1;

	IF focusID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener focusID';
	END IF;

	CALL spInsertBrand(
		'NatureAI',
		'https://cdn.dynamicbrands.com/natureai.png',
		'Marca blanca generada por IA para productos naturales',
		focusID,
		adminID
	);

	SELECT b.brandId INTO brandID
	FROM brands b
	WHERE b.name = 'NatureAI'
	ORDER BY b.brandId DESC
	LIMIT 1;

	IF brandID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener brandID';
	END IF;

	-- 9 sitios web de acuerdo al profe 
	CALL spInsertWebsite(brandID, 'PuraVida Wellness',     'https://puravidawellness.cr',    costaRicaID, JSON_OBJECT('theme','green', 'market','CR'), adminID);
	CALL spInsertWebsite(brandID, 'Caribe Natural NI',     'https://caribenatural.ni',       nicaraguaID, JSON_OBJECT('theme','blue',  'market','NI'), adminID);
	CALL spInsertWebsite(brandID, 'Andes Glow CO',         'https://andesglow.co',           colombiaID,  JSON_OBJECT('theme','gold',  'market','CO'), adminID);
	CALL spInsertWebsite(brandID, 'Sol Herbal PE',         'https://solherbal.pe',           peruID,      JSON_OBJECT('theme','orange','market','PE'), adminID);
	CALL spInsertWebsite(brandID, 'Azteca Wellness MX',    'https://aztecawellness.mx',      mexicoID,    JSON_OBJECT('theme','red',   'market','MX'), adminID);
	CALL spInsertWebsite(brandID, 'BioSkin Costa Rica',    'https://bioskin.cr',             costaRicaID, JSON_OBJECT('theme','white', 'market','CR'), adminID);
	CALL spInsertWebsite(brandID, 'Nica Herbal Shop',      'https://nicaherbalshop.ni',      nicaraguaID, JSON_OBJECT('theme','green', 'market','NI'), adminID);
	CALL spInsertWebsite(brandID, 'Colombia Natural Care', 'https://colombianaturalcare.co', colombiaID,  JSON_OBJECT('theme','purple','market','CO'), adminID);
	CALL spInsertWebsite(brandID, 'Lima Wellness Store',   'https://limawellness.pe',        peruID,      JSON_OBJECT('theme','beige', 'market','PE'), adminID);

	SELECT w.websiteId INTO websiteID
	FROM websites w
	WHERE w.name = 'PuraVida Wellness'
	ORDER BY w.websiteId DESC
	LIMIT 1;

	IF websiteID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener websiteID';
	END IF;

	-- insertar la categoria del producto
	CALL spInsertProductCategory('Aceites', 'Aceites esenciales y medicinales', adminID);

	SELECT pc.productCategoryId INTO categoryID
	FROM productCategories pc
	WHERE pc.name = 'Aceites'
	ORDER BY pc.productCategoryId DESC
	LIMIT 1;

	IF categoryID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener categoryID';
	END IF;

	-- insertar el producto base 
	CALL spInsertBaseProduct(
		categoryID,
		'Aceite Natural Premium',
		'Producto base importado desde Etheria',
		adminID
	);

	SELECT bp.baseProductId INTO baseProductID
	FROM baseProducts bp
	WHERE bp.name = 'Aceite Natural Premium'
	ORDER BY bp.baseProductId DESC
	LIMIT 1;

	IF baseProductID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener baseProductID';
	END IF;

	-- productos comerciales
	-- productVariantId 41 y 42 provienen de Etheria
	CALL spInsertCommercialProductsJson(
		JSON_ARRAY(
			JSON_OBJECT(
				'brandId',           brandID,
				'baseProductId',     baseProductID,
				'productVariantId',  41,
				'name',              'Aceite Premium NatureAI',
				'label',             'Aceite esencial premium',
				'description',       'Producto natural de alta gama',
				'productAttributes', JSON_OBJECT('aroma','lavanda','benefit','relajación'),
				'websiteId',         websiteID,
				'currencyId',        crcID,
				'price',             12950.00
			),
			JSON_OBJECT(
				'brandId',           brandID,
				'baseProductId',     baseProductID,
				'productVariantId',  42,
				'name',              'Aceite Premium NatureAI B',
				'label',             'Aceite esencial premium B',
				'description',       'Producto natural de alta gama B',
				'productAttributes', JSON_OBJECT('aroma','menta','benefit','energía'),
				'websiteId',         websiteID,
				'currencyId',        crcID,
				'price',             13950.00
			)
		),
		adminID
	);

	SELECT cp.commercialProductId INTO commercialProductID
	FROM commercialProducts cp
	WHERE cp.name = 'Aceite Premium NatureAI'
	ORDER BY cp.commercialProductId DESC
	LIMIT 1;

	IF commercialProductID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener commercialProductID';
	END IF;

	-- insertar parte de catalogos generales
	CALL spInsertOrderStatus('Paid',      'Orden pagada',     adminID);
	CALL spInsertPaymentMethod('Tarjeta',                     adminID);
	CALL spInsertPaymentStatus('Approved', 'Pago aprobado',   adminID);
	CALL spInsertShippingStatus('Prepared','Envío preparado', adminID);
	CALL spInsertCourier('Correos Express', '2222-2222', 'courier@dynamicbrands.com', costaRicaID, adminID);
	CALL spInsertTaxType('IVA', 'Impuesto al valor agregado', 'SALE', adminID);

	SELECT os.orderStatusId INTO orderStatusID
	FROM orderStatuses os
	WHERE os.name = 'Paid'
	ORDER BY os.orderStatusId DESC
	LIMIT 1;

	SELECT pm.paymentMethodId INTO paymentMethodID
	FROM paymentMethods pm
	WHERE pm.name = 'Tarjeta'
	ORDER BY pm.paymentMethodId DESC
	LIMIT 1;

	SELECT ps.paymentStatusId INTO paymentStatusID
	FROM paymentStatuses ps
	WHERE ps.name = 'Approved'
	ORDER BY ps.paymentStatusId DESC
	LIMIT 1;

	SELECT ss.shippingStatusId INTO shippingStatusID
	FROM shippingStatuses ss
	WHERE ss.name = 'Prepared'
	ORDER BY ss.shippingStatusId DESC
	LIMIT 1;

	SELECT co.courierId INTO courierID
	FROM couriers co
	WHERE co.name = 'Correos Express'
	ORDER BY co.courierId DESC
	LIMIT 1;

	SELECT tt.taxTypeId INTO taxTypeID
	FROM taxTypes tt
	WHERE tt.name = 'IVA'
	ORDER BY tt.taxTypeId DESC
	LIMIT 1;

	IF orderStatusID IS NULL OR paymentMethodID IS NULL OR paymentStatusID IS NULL
	   OR shippingStatusID IS NULL OR courierID IS NULL OR taxTypeID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener algún ID de catálogos';
	END IF;

	-- insertar tasa de impuesto
	CALL spInsertTaxRate(
		costaRicaID,
		taxTypeID,
		13.00,
		'IVA-CR-13',
		CURDATE(),
		NULL,
		adminID
	);

	SELECT tr.taxRateId INTO taxRateID
	FROM taxRates tr
	WHERE tr.countryId = costaRicaID
	  AND tr.taxTypeId = taxTypeID
	ORDER BY tr.taxRateId DESC
	LIMIT 1;

	IF taxRateID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener taxRateID';
	END IF;

	-- registrar cliente
	CALL spInsertCustomer(
		'Carlos',
		'Ramírez',
		'carlos@test.com',
		'hash123',
		'88888888',
		adminID
	);

	SELECT cu.customerId INTO customerID
	FROM customers cu
	WHERE cu.email = 'carlos@test.com'
	ORDER BY cu.customerId DESC
	LIMIT 1;

	IF customerID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener customerID';
	END IF;

	CALL spInsertCustomerAddress(
		customerID,
		addressID,
		TRUE,
		adminID
	);

	-- registrar order
	CALL spRegisterOrderJson(
		websiteID,
		customerID,
		addressID,
		crcID,
		orderStatusID,
		exchangeRateID,
		taxTypeID,
		taxRateID,
		2500.00,
		JSON_ARRAY(
			JSON_OBJECT(
				'commercialProductId', commercialProductID,
				'quantity',            2,
				'unitPrice',           12950.00
			)
		),
		adminID
	);

	SELECT o.orderId INTO orderID
	FROM orders o
	ORDER BY o.orderId DESC
	LIMIT 1;

	IF orderID IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo obtener orderID';
	END IF;

	-- pagar
	CALL spRegisterPayment(
		orderID,
		paymentMethodID,
		crcID,
		exchangeRateID,
		31767.00,
		61.09,
		paymentStatusID,
		'TX-DYNAMIC-001',
		adminID
	);

	-- parte de envio 
	CALL spRegisterShipment(
		orderID,
		courierID,
		'TRACK-DYN-001',
		shippingStatusID,
		NOW(),
		NULL,
		adminID
	);

END$$

DELIMITER ;

call spSeedDynamicBrands();

