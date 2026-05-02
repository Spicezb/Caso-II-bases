USE DynamicBrandsRetail;

-- =========================
-- 1. Variables base
-- =========================

SET @adminID = (
	SELECT e.employeeId
	FROM employees e
	ORDER BY e.employeeId
	LIMIT 1
);

SET @focusID = (
	SELECT mf.marketingFocusId
	FROM marketingFocus mf
	ORDER BY mf.marketingFocusId DESC
	LIMIT 1
);

SET @baseProductID = (
	SELECT bp.baseProductId
	FROM baseProducts bp
	ORDER BY bp.baseProductId DESC
	LIMIT 1
);

SET @crcID = (
	SELECT c.currencyId
	FROM currencies c
	WHERE c.isoCode = 'CRC'
	ORDER BY c.currencyId DESC
	LIMIT 1
);

SET @orderStatusID = (
	SELECT os.orderStatusId
	FROM orderStatuses os
	WHERE os.name = 'Paid'
	ORDER BY os.orderStatusId DESC
	LIMIT 1
);

SET @paymentCustomerID = (
	SELECT cu.customerId
	FROM customers cu
	ORDER BY cu.customerId DESC
	LIMIT 1
);

SET @addressID = (
	SELECT a.addressId
	FROM addresses a
	ORDER BY a.addressId DESC
	LIMIT 1
);

SET @exchangeRateID = (
	SELECT er.exchangeRateId
	FROM exchangeRates er
	ORDER BY er.exchangeRateId DESC
	LIMIT 1
);

SET @taxTypeID = (
	SELECT tt.taxTypeId
	FROM taxTypes tt
	WHERE tt.name = 'IVA'
	ORDER BY tt.taxTypeId DESC
	LIMIT 1
);

SET @taxRateID = (
	SELECT tr.taxRateId
	FROM taxRates tr
	ORDER BY tr.taxRateId DESC
	LIMIT 1
);

-- =========================
-- 2. Crear marcas nuevas
-- =========================

CALL spInsertBrand(
	'HerbalNova',
	'https://cdn.dynamicbrands.com/herbalnova.png',
	'Segunda marca de productos naturales',
	@focusID,
	@adminID
);

CALL spInsertBrand(
	'BioZen',
	'https://cdn.dynamicbrands.com/biozen.png',
	'Tercera marca de bienestar natural',
	@focusID,
	@adminID
);

SET @herbalNovaID = (
	SELECT b.brandId
	FROM brands b
	WHERE b.name = 'HerbalNova'
	ORDER BY b.brandId DESC
	LIMIT 1
);

SET @bioZenID = (
	SELECT b.brandId
	FROM brands b
	WHERE b.name = 'BioZen'
	ORDER BY b.brandId DESC
	LIMIT 1
);

-- =========================
-- 3. Obtener websites por país
-- =========================

SET @websiteCR = (
	SELECT w.websiteId
	FROM websites w
	WHERE w.name = 'PuraVida Wellness'
	ORDER BY w.websiteId DESC
	LIMIT 1
);

SET @websiteCO = (
	SELECT w.websiteId
	FROM websites w
	WHERE w.name = 'Andes Glow CO'
	ORDER BY w.websiteId DESC
	LIMIT 1
);

SET @websitePE = (
	SELECT w.websiteId
	FROM websites w
	WHERE w.name = 'Lima Wellness Store'
	ORDER BY w.websiteId DESC
	LIMIT 1
);

-- =========================
-- 4. Productos comerciales nuevos
-- =========================

CALL spInsertCommercialProductsJson(
	JSON_ARRAY(
		JSON_OBJECT(
			'brandId', @herbalNovaID,
			'baseProductId', @baseProductID,
			'productVariantId', 43,
			'name', 'HerbalNova Variante 43',
			'label', 'HerbalNova 43',
			'description', 'Producto HerbalNova conectado a Etheria',
			'productAttributes', JSON_OBJECT('aroma','eucalipto'),
			'websiteId', @websiteCR,
			'currencyId', @crcID,
			'price', 15500.00
		),
		JSON_OBJECT(
			'brandId', @herbalNovaID,
			'baseProductId', @baseProductID,
			'productVariantId', 44,
			'name', 'HerbalNova Variante 44',
			'label', 'HerbalNova 44',
			'description', 'Producto HerbalNova conectado a Etheria',
			'productAttributes', JSON_OBJECT('aroma','romero'),
			'websiteId', @websiteCO,
			'currencyId', @crcID,
			'price', 16500.00
		),
		JSON_OBJECT(
			'brandId', @bioZenID,
			'baseProductId', @baseProductID,
			'productVariantId', 45,
			'name', 'BioZen Variante 45',
			'label', 'BioZen 45',
			'description', 'Producto BioZen conectado a Etheria',
			'productAttributes', JSON_OBJECT('aroma','limón'),
			'websiteId', @websitePE,
			'currencyId', @crcID,
			'price', 17500.00
		),
		JSON_OBJECT(
			'brandId', @bioZenID,
			'baseProductId', @baseProductID,
			'productVariantId', 46,
			'name', 'BioZen Variante 46',
			'label', 'BioZen 46',
			'description', 'Producto BioZen conectado a Etheria',
			'productAttributes', JSON_OBJECT('aroma','cedro'),
			'websiteId', @websiteCR,
			'currencyId', @crcID,
			'price', 18500.00
		),
		JSON_OBJECT(
			'brandId', @bioZenID,
			'baseProductId', @baseProductID,
			'productVariantId', 47,
			'name', 'BioZen Variante 47',
			'label', 'BioZen 47',
			'description', 'Producto BioZen conectado a Etheria',
			'productAttributes', JSON_OBJECT('aroma','naranja'),
			'websiteId', @websiteCO,
			'currencyId', @crcID,
			'price', 19500.00
		)
	),
	@adminID
);

-- =========================
-- 5. Obtener commercialProductId
-- =========================

SET @cp43 = (
	SELECT cp.commercialProductId
	FROM commercialProducts cp
	WHERE cp.productVariantId = 43
	  AND cp.brandId = @herbalNovaID
	ORDER BY cp.commercialProductId DESC
	LIMIT 1
);

SET @cp44 = (
	SELECT cp.commercialProductId
	FROM commercialProducts cp
	WHERE cp.productVariantId = 44
	  AND cp.brandId = @herbalNovaID
	ORDER BY cp.commercialProductId DESC
	LIMIT 1
);

SET @cp45 = (
	SELECT cp.commercialProductId
	FROM commercialProducts cp
	WHERE cp.productVariantId = 45
	  AND cp.brandId = @bioZenID
	ORDER BY cp.commercialProductId DESC
	LIMIT 1
);

SET @cp46 = (
	SELECT cp.commercialProductId
	FROM commercialProducts cp
	WHERE cp.productVariantId = 46
	  AND cp.brandId = @bioZenID
	ORDER BY cp.commercialProductId DESC
	LIMIT 1
);

SET @cp47 = (
	SELECT cp.commercialProductId
	FROM commercialProducts cp
	WHERE cp.productVariantId = 47
	  AND cp.brandId = @bioZenID
	ORDER BY cp.commercialProductId DESC
	LIMIT 1
);

-- =========================
-- 6. Ventas
-- =========================

CALL spRegisterOrderJson(
	@websiteCR,
	@paymentCustomerID,
	@addressID,
	@crcID,
	@orderStatusID,
	@exchangeRateID,
	@taxTypeID,
	@taxRateID,
	2500.00,
	JSON_ARRAY(
		JSON_OBJECT('commercialProductId', @cp43, 'quantity', 2, 'unitPrice', 15500.00)
	),
	@adminID
);

CALL spRegisterOrderJson(
	@websiteCO,
	@paymentCustomerID,
	@addressID,
	@crcID,
	@orderStatusID,
	@exchangeRateID,
	@taxTypeID,
	@taxRateID,
	2500.00,
	JSON_ARRAY(
		JSON_OBJECT('commercialProductId', @cp44, 'quantity', 3, 'unitPrice', 16500.00)
	),
	@adminID
);

CALL spRegisterOrderJson(
	@websitePE,
	@paymentCustomerID,
	@addressID,
	@crcID,
	@orderStatusID,
	@exchangeRateID,
	@taxTypeID,
	@taxRateID,
	2500.00,
	JSON_ARRAY(
		JSON_OBJECT('commercialProductId', @cp45, 'quantity', 1, 'unitPrice', 17500.00)
	),
	@adminID
);

CALL spRegisterOrderJson(
	@websiteCR,
	@paymentCustomerID,
	@addressID,
	@crcID,
	@orderStatusID,
	@exchangeRateID,
	@taxTypeID,
	@taxRateID,
	2500.00,
	JSON_ARRAY(
		JSON_OBJECT('commercialProductId', @cp46, 'quantity', 4, 'unitPrice', 18500.00)
	),
	@adminID
);

CALL spRegisterOrderJson(
	@websiteCO,
	@paymentCustomerID,
	@addressID,
	@crcID,
	@orderStatusID,
	@exchangeRateID,
	@taxTypeID,
	@taxRateID,
	2500.00,
	JSON_ARRAY(
		JSON_OBJECT('commercialProductId', @cp47, 'quantity', 2, 'unitPrice', 19500.00)
	),
	@adminID
);

-- =========================
-- 7. Verificación
-- =========================

SELECT DISTINCT cp.productVariantId
FROM commercialProducts cp
ORDER BY cp.productVariantId;

SELECT
	b.name AS brandName,
	w.name AS websiteName,
	w.countryId,
	cp.productVariantId,
	od.quantity,
	od.unitPrice,
	od.lineSubtotal
FROM orderDetails od
JOIN commercialProducts cp
	ON od.commercialProductId = cp.commercialProductId
JOIN brands b
	ON cp.brandId = b.brandId
JOIN orders o
	ON od.orderId = o.orderId
JOIN websites w
	ON o.websiteId = w.websiteId
ORDER BY b.name, w.countryId, cp.productVariantId;