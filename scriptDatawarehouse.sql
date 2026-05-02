
CREATE TABLE products (
    productid SERIAL PRIMARY KEY,
    categoryName VARCHAR(100)
);

CREATE TABLE markets (
    marketid SERIAL PRIMARY KEY,
    countryName VARCHAR(100),
    brandName VARCHAR(100)
);

CREATE TABLE dates (
    dateid SERIAL PRIMARY KEY,
    month INT,
    monthName VARCHAR(20),
    year INT
);

CREATE TABLE summaries (
    summaryid SERIAL PRIMARY KEY,

    productid INT NOT NULL,
    marketid INT NOT NULL,
    dateid INT NOT NULL,

    costTypeName VARCHAR(50),

    totalCostUsd NUMERIC(12,2),
    totalRevenueUsd NUMERIC(12,2),
    totalProfitUsd NUMERIC(12,2),

    -- FOREIGN KEYS
    CONSTRAINT fk_summaries_product
        FOREIGN KEY (productid)
        REFERENCES products(productid),

    CONSTRAINT fk_summaries_market
        FOREIGN KEY (marketid)
        REFERENCES markets(marketid),

    CONSTRAINT fk_summaries_date
        FOREIGN KEY (dateid)
        REFERENCES dates(dateid)
);

CREATE INDEX idx_summaries_product ON summaries(productid);
CREATE INDEX idx_summaries_market ON summaries(marketid);
CREATE INDEX idx_summaries_date ON summaries(dateid);
CREATE INDEX idx_summaries_costtype ON summaries(costTypeName);