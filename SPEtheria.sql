-- Implemente un SP independiente que registre cada paso ejecutado en las tablas de destino, 
-- este SP es llamado por los otros SP de inserción de datos.

create or replace PROCEDURE spRegisterEtheria(
	logTypeName varchar, prodecureName varchar, messageData varchar, 
	isError boolean, executionTime int, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
Declare 
	logTypeIDSaved int;
	procedureIDSaved int;
Begin
	SELECT logTypeId
    INTO logTypeIDSaved
    FROM logTypes
    WHERE name = logTypeName;

	SELECT procedureId
    INTO procedureIDSaved
    FROM procedures
    WHERE name = prodecureName;

	INSERT INTO systemLogs (
    	logTypeId,
        procedureId,
        message,
        isError,
        executionTimeMs,
        employeeId
    )

	VALUES (
        logTypeIDSaved,
        procedureIDSaved,
        messageData,
        isError,
        executionTime,
        employeeInChargeID
    );

END;
$$;


-- todos los sps basicos/sencillos
-- Registrar proveedores 

create or replace Procedure insertSupplier(
	supplierName varchar, 
    suppCountryId int,
	suppEmail varchar, 
    suppemployeeID int
)
LANGUAGE plpgsql
AS $$
Begin
	CALL spRegisterEtheria(
        'INFO',
        'insertSupplier',
        'Iniciando con el registro de proveedor',
        FALSE,
        0,
        suppemployeeID
    );

    -- Validar país
    IF NOT EXISTS (
        SELECT 1 
        FROM countries 
        WHERE countryId = suppCountryId
        AND isActive = TRUE
    ) THEN
        RAISE EXCEPTION 'El país no existe o está inactivo';
    END IF;

    -- Validar empleado
    IF NOT EXISTS (
        SELECT 1 
        FROM employees 
        WHERE employeeId = suppemployeeID
        AND isActive = TRUE
    ) THEN
        RAISE EXCEPTION 'El empleado no existe o está inactivo';
    END IF;

    -- 🔹 Insert
    INSERT INTO suppliers (
        name,
        countryId,
        contactEmail,
        isActive,
        createdAt,
        employeeId
    )
	 VALUES (
        supplierName,
        suppCountryId,
        suppEmail,
        TRUE,
        NOW(),
        suppemployeeID
    );

	 CALL spRegisterEtheria(
        'INFO',
        'insertSupplier',
        'Proveedor registrado correctamente',
        FALSE,
        0,
        suppemployeeID
    );

EXCEPTION
    WHEN OTHERS THEN
	    CALL spRegisterEtheria(
            'ERROR',
            'insertSupplier',
            SQLERRM,
            TRUE,
            0,
            suppemployeeID
        );

	RAISE; 
END;
$$;


--Insertar empleado

CREATE OR REPLACE PROCEDURE spInsertEmployee(
	firstNameData varchar, lastNameData varchar,
	emailData varchar, passwordData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertEmployee','Inicio registro empleado',FALSE,0,employeeInChargeID);

	INSERT INTO employees(
		firstName, lastName, email, passwordHash, isActive, createdAt
	)
	VALUES(
		firstNameData, lastNameData, emailData, passwordData, TRUE, NOW()
	);

	CALL spRegisterEtheria('INFO','spInsertEmployee','Empleado registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertEmployee',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;

-- Insertar pais 
CREATE OR REPLACE PROCEDURE spInsertCountry(
	countryName varchar, isoCodeData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertCountry','Inicio registro país',FALSE,0,employeeInChargeID);

	INSERT INTO countries(name, isoCode, isActive, createdAt)
	VALUES(countryName, isoCodeData, TRUE, NOW());

	CALL spRegisterEtheria('INFO','spInsertCountry','País registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertCountry',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;

-- Insertar currency
CREATE OR REPLACE PROCEDURE spInsertCurrency(
	nameData varchar, symbolData varchar,
	isoCodeData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertCurrency','Inicio moneda',FALSE,0,employeeInChargeID);

	INSERT INTO currencies(name, symbol, isoCode, isActive, createdAt, employeeId)
	VALUES(nameData, symbolData, isoCodeData, TRUE, NOW(), employeeInChargeID);

	CALL spRegisterEtheria('INFO','spInsertCurrency','Moneda registrada',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertCurrency',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;


-- Insertar estados}
CREATE OR REPLACE PROCEDURE spInsertStatus(
	nameData varchar, descData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertStatus','Inicio status',FALSE,0,employeeInChargeID);

	INSERT INTO statuses(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterEtheria('INFO','spInsertStatus','Status registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertStatus',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;


-- insertar movimiento
CREATE OR REPLACE PROCEDURE spInsertMovement(
	nameData varchar, descData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertMovement','Inicio movimiento',FALSE,0,employeeInChargeID);

	INSERT INTO movements(movementName, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterEtheria('INFO','spInsertMovement','Movimiento registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertMovement',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;


-- insertar tipo de registro
CREATE OR REPLACE PROCEDURE spInsertLogType(
	nameData varchar, descData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertLogType','Inicio logType',FALSE,0,employeeInChargeID);

	INSERT INTO logTypes(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterEtheria('INFO','spInsertLogType','LogType registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertLogType',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;


-- insertar procedimientos
CREATE OR REPLACE PROCEDURE spInsertProcedure(
	nameData varchar, descData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertProcedure','Inicio procedure',FALSE,0,employeeInChargeID);

	INSERT INTO procedures(name, description, isActive)
	VALUES(nameData, descData, TRUE);

	CALL spRegisterEtheria('INFO','spInsertProcedure','Procedure registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertProcedure',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;

-- Insertar warehouse
CREATE OR REPLACE PROCEDURE spInsertWarehouse(
	nameData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertWarehouse','Inicio warehouse',FALSE,0,employeeInChargeID);

	INSERT INTO warehouses(name, createdAt, employeeId)
	VALUES(nameData, NOW(), employeeInChargeID);

	CALL spRegisterEtheria('INFO','spInsertWarehouse','Warehouse registrado',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertWarehouse',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;



-- insertar ubicacione más detalladas
CREATE OR REPLACE PROCEDURE spInsertWarehouseLocation(
	warehouseID int, zoneData varchar,
	aisleData varchar, shelfData varchar,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertWarehouseLocation','Inicio location',FALSE,0,employeeInChargeID);

	INSERT INTO warehouseLocations(
		warehouseId, zone, aisle, shelf, isActive, createdAt, employeeId
	)
	VALUES(
		warehouseID, zoneData, aisleData, shelfData, TRUE, NOW(), employeeInChargeID
	);

	CALL spRegisterEtheria('INFO','spInsertWarehouseLocation','Location registrada',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertWarehouseLocation',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;

-- insertar categoria de producto}
CREATE OR REPLACE PROCEDURE spInsertProductCategory(
	nameData varchar, descData varchar, employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria('INFO','spInsertProductCategory','Inicio categoría',FALSE,0,employeeInChargeID);

	INSERT INTO productCategories(name, description, createdAt, employeeId)
	VALUES(nameData, descData, NOW(), employeeInChargeID);

	CALL spRegisterEtheria('INFO','spInsertProductCategory','Categoría registrada',FALSE,0,employeeInChargeID);

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria('ERROR','spInsertProductCategory',SQLERRM,TRUE,0,employeeInChargeID);
	RAISE;
END;
$$;

-- insertar relaciones de cambio de moneda
CREATE OR REPLACE PROCEDURE spInsertExchangeRate(
	fromCurrencyID int,
	toCurrencyID int,
	rateData numeric,
	validFromDate date,
	validToDate date,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria(
        'INFO',
        'spInsertExchangeRate',
        'Inicio registro tipo de cambio',
        FALSE,
        0,
        employeeInChargeID
    );

	INSERT INTO exchangeRates(
		fromCurrencyId,
		toCurrencyId,
		rate,
		validFrom,
		validTo,
		createdAt,
		employeeId
	)
	VALUES(
		fromCurrencyID,
		toCurrencyID,
		rateData,
		validFromDate,
		validToDate,
		NOW(),
		employeeInChargeID
	);

	CALL spRegisterEtheria(
        'INFO',
        'spInsertExchangeRate',
        'Tipo de cambio registrado correctamente',
        FALSE,
        0,
        employeeInChargeID
    );

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria(
        'ERROR',
        'spInsertExchangeRate',
        SQLERRM,
        TRUE,
        0,
        employeeInChargeID
    );
	RAISE;
END;
$$;

-- insertar movimiento de inventario
CREATE OR REPLACE PROCEDURE spRegisterInventoryMovement(
	lotID int,
	productVariantID int,
	warehouseID int,
	locationID int,
	movementID int,
	quantityData int,
	referenceID int,
	referenceTypeData varchar,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria(
        'INFO',
        'spRegisterInventoryMovement',
        'Inicio registro movimiento inventario',
        FALSE,
        0,
        employeeInChargeID
    );

	INSERT INTO inventoryMovements(
		lotId,
		productVariantId,
		warehouseId,
		locationId,
		movementId,
		quantity,
		referenceId,
		referenceType,
		employeeId
	)
	VALUES(
		lotID,
		productVariantID,
		warehouseID,
		locationID,
		movementID,
		quantityData,
		referenceID,
		referenceTypeData,
		employeeInChargeID
	);

	CALL spRegisterEtheria(
        'INFO',
        'spRegisterInventoryMovement',
        'Movimiento inventario registrado correctamente',
        FALSE,
        0,
        employeeInChargeID
    );

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria(
        'ERROR',
        'spRegisterInventoryMovement',
        SQLERRM,
        TRUE,
        0,
        employeeInChargeID
    );

	RAISE;
END;
$$;

-- sp de llenado para variante de productos: 
-- usamos json para que se puedieran elistar variantes de forma más rapida

----------------------------------------

CREATE OR REPLACE PROCEDURE spInsertProductWithVariantsJson(
	productName varchar,
	categoryID int,
	productDesc varchar,
	variantsJson json,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
DECLARE
	productIDSaved int;
	variantItem json;
BEGIN
	CALL spRegisterEtheria(
        'INFO',
        'spInsertProductWithVariantsJson',
        'Inicio registro producto con variantes',
        FALSE,
        0,
        employeeInChargeID
    );

	-- Insert producto
	INSERT INTO products(
		name,
		productCategoryId,
		description,
		isActive,
		createdAt,
		employeeId
	)
	VALUES(
		productName,
		categoryID,
		productDesc,
		TRUE,
		NOW(),
		employeeInChargeID
	)
	RETURNING productId INTO productIDSaved;

	-- Loop sobre JSON
	FOR variantItem IN SELECT * FROM json_array_elements(variantsJson) --convierte el json en elementos individuales
	LOOP
		
		INSERT INTO productVariants(
			productId,
			description,
			sku,
			size,
			unit,
			isActive,
			createdAt,
			employeeId
		)
		VALUES(
			productIDSaved,
			variantItem->>'description',
			variantItem->>'sku',
			variantItem->>'size',
			variantItem->>'unit',
			TRUE,
			NOW(),
			employeeInChargeID
		);

	END LOOP;

	CALL spRegisterEtheria(
        'INFO',
        'spInsertProductWithVariantsJson',
        'Producto y variantes registradas correctamente',
        FALSE,
        0,
        employeeInChargeID
    );

EXCEPTION
WHEN OTHERS THEN --captura cualquier error
	CALL spRegisterEtheria(
        'ERROR',
        'spInsertProductWithVariantsJson',
        SQLERRM,
        TRUE,
        0,
        employeeInChargeID
    );
	RAISE; --Vuelve a lanzar el error
END;
$$;


-- registrar importaciones
CREATE OR REPLACE PROCEDURE spRegisterImportJson(
	supplierID int,
	statusID int,
	itemsJson json,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
DECLARE
	importIDSaved int;
	itemData json;
	totalCost numeric(10,2) := 0;
	movementIDSaved int;
BEGIN
	CALL spRegisterEtheria(
        'INFO',
        'spRegisterImportJson',
        'Inicio registro importacion',
        FALSE,
        0,
        employeeInChargeID
    );

	-- Calcular total de la importación
	FOR itemData IN SELECT * FROM json_array_elements(itemsJson)
	LOOP
		totalCost := totalCost + ((itemData->>'quantity')::int * (itemData->>'unitCostUsd')::numeric);
	END LOOP;

	-- Insertar importación
	INSERT INTO imports(
		supplierId,
		importDate,
		totalCostUsd,
		statusId,
		createdAt,
		employeeId
	)
	VALUES(
		supplierID,
		CURRENT_DATE,
		totalCost,
		statusID,
		NOW(),
		employeeInChargeID
	)
	RETURNING importId INTO importIDSaved;

	-- Buscar movimiento de entrada
	SELECT movementId
	INTO movementIDSaved
	FROM movements
	WHERE movementName = 'IN';

	-- Insertar items, lotes, inventario y movimientos
	FOR itemData IN SELECT * FROM json_array_elements(itemsJson)
	LOOP
		DECLARE
			importItemIDSaved int;
			lotIDSaved int;
			inventoryIDSaved int;
		BEGIN
			INSERT INTO importItems(
				importId,
				productVariantId,
				quantity,
				currencyId,
				exchangeRateId,
				unitCostLocal,
				unitCostUsd,
				employeeId
			)
			VALUES(
				importIDSaved,
				(itemData->>'productVariantId')::int,
				(itemData->>'quantity')::int,
				(itemData->>'currencyId')::int,
				(itemData->>'exchangeRateId')::int,
				(itemData->>'unitCostLocal')::numeric,
				(itemData->>'unitCostUsd')::numeric,
				employeeInChargeID
			)
			RETURNING importItemId INTO importItemIDSaved;

			INSERT INTO inventoryLots(
				importItemId,
				productVariantId,
				locationId,
				quantityAvailable,
				quantityReserved,
				receivedAt,
				employeeId
			)
			VALUES(
				importItemIDSaved,
				(itemData->>'productVariantId')::int,
				(itemData->>'locationId')::int,
				(itemData->>'quantity')::int,
				0,
				NOW(),
				employeeInChargeID
			)
			RETURNING lotId INTO lotIDSaved;

			-- Si ya existe inventario, suma, si no, lo crea
			SELECT inventoryId
			INTO inventoryIDSaved
			FROM inventory
			WHERE warehouseId = (itemData->>'warehouseId')::int
			  AND productVariantId = (itemData->>'productVariantId')::int;

			IF inventoryIDSaved IS NULL THEN
				INSERT INTO inventory(
					warehouseId,
					productVariantId,
					quantityAvailable,
					lastUpdated,
					employeeId
				)
				VALUES(
					(itemData->>'warehouseId')::int,
					(itemData->>'productVariantId')::int,
					(itemData->>'quantity')::int,
					NOW(),
					employeeInChargeID
				);
			ELSE
				UPDATE inventory
				SET quantityAvailable = quantityAvailable + (itemData->>'quantity')::int,
					lastUpdated = NOW(),
					employeeId = employeeInChargeID
				WHERE inventoryId = inventoryIDSaved;
			END IF;

			INSERT INTO inventoryMovements(
				lotId,
				productVariantId,
				warehouseId,
				locationId,
				movementId,
				quantity,
				referenceId,
				referenceType,
				employeeId
			)
			VALUES(
				lotIDSaved,
				(itemData->>'productVariantId')::int,
				(itemData->>'warehouseId')::int,
				(itemData->>'locationId')::int,
				movementIDSaved,
				(itemData->>'quantity')::int,
				importIDSaved,
				'IMPORT',
				employeeInChargeID
			);
		END;
	END LOOP;

	CALL spRegisterEtheria(
        'INFO',
        'spRegisterImportJson',
        'Importacion registrada correctamente',
        FALSE,
        0,
        employeeInChargeID
    );

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria(
        'ERROR',
        'spRegisterImportJson',
        SQLERRM,
        TRUE,
        0,
        employeeInChargeID
    );
	RAISE;
END;
$$;


-- registrar metodo de pago }
CREATE OR REPLACE PROCEDURE spRegisterImportPayment(
	importID int,
	currencyID int,
	exchangeRateID int,
	amountData numeric,
	amountUsdData numeric,
	paymentMethodData varchar,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
BEGIN
	CALL spRegisterEtheria(
        'INFO',
        'spRegisterImportPayment',
        'Inicio registro pago importacion',
        FALSE,
        0,
        employeeInChargeID
    );

	-- Insertar pago
	INSERT INTO importPayments(
		importId,
		currencyId,
		exchangeRateId,
		amount,
		amountUsd,
		paymentDate,
		paymentMethod,
		employeeId
	)
	VALUES(
		importID,
		currencyID,
		exchangeRateID,
		amountData,
		amountUsdData,
		CURRENT_DATE,
		paymentMethodData,
		employeeInChargeID
	);

	CALL spRegisterEtheria(
        'INFO',
        'spRegisterImportPayment',
        'Pago registrado correctamente',
        FALSE,
        0,
        employeeInChargeID
    );

EXCEPTION
WHEN OTHERS THEN
	CALL spRegisterEtheria(
        'ERROR',
        'spRegisterImportPayment',
        SQLERRM,
        TRUE,
        0,
        employeeInChargeID
    );
	RAISE;
END;
$$;

-- sp auxiliar que genera 20 productos por pais 
-- 1. Recibe un prefijo de país.
-- 2. Recibe una categoría.
-- 3. Recibe un rango de números.
-- 4. Genera nombres de productos.
-- 5. Genera SKUs únicos.
-- 6. Llama al SP de productos con variantes.
-- 7. Repite hasta completar el rango.
CREATE OR REPLACE PROCEDURE spSeedProductsByCountry(
	countryPrefix varchar,
	categoryID int,
	startNumber int,
	endNumber int,
	employeeInChargeID int
)
LANGUAGE plpgsql
AS $$
DECLARE
	counterData int;
	productNameData varchar;
	skuData varchar;
BEGIN
	FOR counterData IN startNumber..endNumber
	LOOP
		productNameData := 'Producto Natural ' || countryPrefix || ' ' || counterData;
		skuData := countryPrefix || '-PROD-' || LPAD(counterData::text, 3, '0');

		CALL spInsertProductWithVariantsJson(
			productNameData,
			categoryID,
			'Producto natural premium generado para carga inicial',
			(
				'[
					{
						"description":"Presentación estándar",
						"sku":"' || skuData || '",
						"size":"500ml",
						"unit":"ml"
					}
				]'
			)::json,
			employeeInChargeID
		);
	END LOOP;
END;
$$;


-- Orquestador para cargar datos llamando a los demás SP
CREATE OR REPLACE PROCEDURE spSeedEtheria()
LANGUAGE plpgsql
AS $$
DECLARE
	adminID int;

	costaRicaID int;
	nicaraguaID int;
	colombiaID int;
	peruID int;
	mexicoID int;

	usdID int;
	usdRateID int;

	receivedStatusID int;

	aceitesCategoryID int;
	cosmeticaCategoryID int;
	aromaterapiaCategoryID int;

	warehouseIDSaved int;
	locationID int;

	supplierAmazoniaID int;

	variantOneID int;
	variantTwoID int;

	importIDSaved int;
BEGIN
	-- Bootstrap mínimo sin logs: datos necesarios para que todos los sp funcionen
	INSERT INTO employees(firstName, lastName, email, passwordHash, isActive, createdAt)
	VALUES('Admin', 'Sistema', 'admin@etheria.com', 'hash123', TRUE, NOW())
	ON CONFLICT (email) DO NOTHING;

	SELECT employeeId INTO adminID
	FROM employees
	WHERE email = 'admin@etheria.com';

	INSERT INTO logTypes(name, description, isActive)
	VALUES
	('INFO', 'Mensaje informativo del sistema', TRUE),
	('ERROR', 'Mensaje de error del sistema', TRUE),
	('WARNING', 'Mensaje de advertencia del sistema', TRUE)
	ON CONFLICT (name) DO NOTHING;

	INSERT INTO procedures(name, description, isActive)
	VALUES
	('spSeedEtheria', 'Orquestador de carga inicial de Etheria', TRUE),
	('spRegisterEtheria', 'Registra logs del sistema Etheria', TRUE),
	('spInsertEmployee', 'Inserta empleados', TRUE),
	('spInsertCountry', 'Inserta países', TRUE),
	('spInsertCurrency', 'Inserta monedas', TRUE),
	('spInsertStatus', 'Inserta estados de importación', TRUE),
	('spInsertMovement', 'Inserta tipos de movimiento', TRUE),
	('insertSupplier', 'Inserta proveedores', TRUE),
	('spInsertProductCategory', 'Inserta categorías de producto', TRUE),
	('spInsertWarehouse', 'Inserta bodegas', TRUE),
	('spInsertWarehouseLocation', 'Inserta ubicaciones de bodega', TRUE),
	('spInsertExchangeRate', 'Inserta tipos de cambio', TRUE),
	('spInsertProductWithVariantsJson', 'Inserta productos con variantes desde JSON', TRUE),
	('spRegisterImportJson', 'Registra importaciones desde JSON', TRUE),
	('spRegisterImportPayment', 'Registra pagos de importaciones', TRUE),
	('spRegisterInventoryMovement', 'Registra movimientos de inventario', TRUE),
	('spSeedProductsByCountry', 'Genera productos por país', TRUE)
	ON CONFLICT (name) DO NOTHING;

	-- Países
	CALL spInsertCountry('Costa Rica', 'CR', adminID);
	CALL spInsertCountry('Nicaragua', 'NI', adminID);
	CALL spInsertCountry('Colombia', 'CO', adminID);
	CALL spInsertCountry('Peru', 'PE', adminID);
	CALL spInsertCountry('Mexico', 'MX', adminID);

	SELECT countryId INTO costaRicaID FROM countries WHERE isoCode = 'CR';
	SELECT countryId INTO nicaraguaID FROM countries WHERE isoCode = 'NI';
	SELECT countryId INTO colombiaID FROM countries WHERE isoCode = 'CO';
	SELECT countryId INTO peruID FROM countries WHERE isoCode = 'PE';
	SELECT countryId INTO mexicoID FROM countries WHERE isoCode = 'MX';

	-- Moneda y tipo de cambio
	CALL spInsertCurrency('US Dollar', '$', 'USD', adminID);

	SELECT currencyId INTO usdID
	FROM currencies
	WHERE isoCode = 'USD';

	CALL spInsertExchangeRate(usdID, usdID, 1.0000, CURRENT_DATE, NULL, adminID);

	SELECT exchangeRateId INTO usdRateID
	FROM exchangeRates
	WHERE fromCurrencyId = usdID
	  AND toCurrencyId = usdID
	ORDER BY exchangeRateId DESC
	LIMIT 1;

	-- Estados y movimientos
	CALL spInsertStatus('Pending', 'Importación pendiente', adminID);
	CALL spInsertStatus('Received', 'Importación recibida', adminID);
	CALL spInsertStatus('Cancelled', 'Importación cancelada', adminID);

	CALL spInsertMovement('IN', 'Entrada de inventario', adminID);
	CALL spInsertMovement('OUT', 'Salida de inventario', adminID);
	CALL spInsertMovement('ADJUST', 'Ajuste manual de inventario', adminID);

	SELECT statusId INTO receivedStatusID
	FROM statuses
	WHERE name = 'Received';

	-- Categorías
	CALL spInsertProductCategory('Aceites', 'Aceites esenciales y medicinales', adminID);
	CALL spInsertProductCategory('Cosmetica', 'Productos dermatológicos y cosméticos', adminID);
	CALL spInsertProductCategory('Aromaterapia', 'Productos aromáticos naturales', adminID);

	SELECT productCategoryId INTO aceitesCategoryID FROM productCategories WHERE name = 'Aceites';
	SELECT productCategoryId INTO cosmeticaCategoryID FROM productCategories WHERE name = 'Cosmetica';
	SELECT productCategoryId INTO aromaterapiaCategoryID FROM productCategories WHERE name = 'Aromaterapia';

	-- Warehouse y ubicación
	CALL spInsertWarehouse('HUB Caribe Nicaragua', adminID);

	SELECT warehouseId INTO warehouseIDSaved
	FROM warehouses
	WHERE name = 'HUB Caribe Nicaragua';

	CALL spInsertWarehouseLocation(warehouseIDSaved, 'A', '01', '01', adminID);

	SELECT wl.locationId INTO locationID
	FROM warehouseLocations wl
	WHERE wl.warehouseId = warehouseIDSaved
  	AND wl.zone = 'A'
  	AND wl.aisle = '01'
 	AND wl.shelf = '01';

	-- Proveedores, uno por país
	CALL insertSupplier('Proveedor Natural Costa Rica', costaRicaID, 'cr@etheria.com', adminID);
	CALL insertSupplier('Proveedor Natural Nicaragua', nicaraguaID, 'ni@etheria.com', adminID);
	CALL insertSupplier('Amazonia Natural Labs', colombiaID, 'co@etheria.com', adminID);
	CALL insertSupplier('Andes Wellness Export', peruID, 'pe@etheria.com', adminID);
	CALL insertSupplier('Azteca Herbal Export', mexicoID, 'mx@etheria.com', adminID);

	SELECT supplierId INTO supplierAmazoniaID
	FROM suppliers
	WHERE name = 'Amazonia Natural Labs';

	-- 100 productos distribuidos entre 5 países
	-- CR: 1-20
	CALL spSeedProductsByCountry('CR', aceitesCategoryID, 1, 20, adminID);

	-- NI: 21-40
	CALL spSeedProductsByCountry('NI', cosmeticaCategoryID, 21, 40, adminID);

	-- CO: 41-60
	CALL spSeedProductsByCountry('CO', aromaterapiaCategoryID, 41, 60, adminID);

	-- PE: 61-80
	CALL spSeedProductsByCountry('PE', aceitesCategoryID, 61, 80, adminID);

	-- MX: 81-100
	CALL spSeedProductsByCountry('MX', cosmeticaCategoryID, 81, 100, adminID);

	-- Tomamos dos variantes reales para registrar una importación de prueba
	SELECT productVariantId INTO variantOneID
	FROM productVariants
	WHERE sku = 'CO-PROD-041'
	LIMIT 1;
	
	SELECT productVariantId INTO variantTwoID
	FROM productVariants
	WHERE sku = 'CO-PROD-042'
	LIMIT 1;
	
	-- Si por algún motivo no existen esos SKU, toma las primeras dos variantes existentes
	IF variantOneID IS NULL THEN
		SELECT productVariantId INTO variantOneID
		FROM productVariants
		ORDER BY productVariantId
		LIMIT 1;
	END IF;
	
	IF variantTwoID IS NULL THEN
		SELECT productVariantId INTO variantTwoID
		FROM productVariants
		ORDER BY productVariantId
		OFFSET 1
		LIMIT 1;
	END IF;
	
	-- Validación final
	IF variantOneID IS NULL OR variantTwoID IS NULL THEN
		RAISE EXCEPTION 'No existen variantes suficientes para registrar la importación';
	END IF;

	-- Importación de prueba
	CALL spRegisterImportJson(
		supplierAmazoniaID,
		receivedStatusID,
		(
		'[
			{
				"productVariantId": ' || variantOneID || ',
				"quantity": 100,
				"currencyId": ' || usdID || ',
				"exchangeRateId": ' || usdRateID || ',
				"unitCostLocal": 5.50,
				"unitCostUsd": 5.50,
				"warehouseId": ' || warehouseIDSaved || ',
				"locationId": ' || locationID || '
			},
			{
				"productVariantId": ' || variantTwoID || ',
				"quantity": 80,
				"currencyId": ' || usdID || ',
				"exchangeRateId": ' || usdRateID || ',
				"unitCostLocal": 8.20,
				"unitCostUsd": 8.20,
				"warehouseId": ' || warehouseIDSaved || ',
				"locationId": ' || locationID || '
			}
		]'
		)::json,
		adminID
	);

	SELECT importId INTO importIDSaved
	FROM imports
	ORDER BY importId DESC
	LIMIT 1;

	-- Pago de importación
	CALL spRegisterImportPayment(
		importIDSaved,
		usdID,
		usdRateID,
		1206.00,
		1206.00,
		'Transferencia',
		adminID
	);
END;
$$;
