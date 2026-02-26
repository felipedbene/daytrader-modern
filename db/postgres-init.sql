-- DayTrader PostgreSQL schema
-- Converted from daytrader-ee7-ejb/src/main/resources/META-INF/daytrader.sql
-- Changes: DOUBLE → DOUBLE PRECISION, DECIMAL → NUMERIC for PostgreSQL

DROP TABLE IF EXISTS holdingejb, orderejb, accountejb, accountprofileejb, quoteejb, keygenejb CASCADE;

CREATE TABLE keygenejb (
  keyval   INTEGER NOT NULL,
  keyname  VARCHAR(250) NOT NULL,
  PRIMARY KEY (keyname)
);

CREATE TABLE accountprofileejb (
  address    VARCHAR(250),
  passwd     VARCHAR(250),
  userid     VARCHAR(250) NOT NULL,
  email      VARCHAR(250),
  creditcard VARCHAR(250),
  fullname   VARCHAR(250),
  optlock    INTEGER,
  PRIMARY KEY (userid)
);

CREATE TABLE quoteejb (
  low         NUMERIC(10,2),
  open1       NUMERIC(10,2),
  volume      DOUBLE PRECISION NOT NULL,
  price       NUMERIC(10,2),
  high        NUMERIC(10,2),
  companyname VARCHAR(250),
  symbol      VARCHAR(250) NOT NULL,
  change1     DOUBLE PRECISION NOT NULL,
  optlock     INTEGER,
  PRIMARY KEY (symbol)
);

CREATE TABLE accountejb (
  creationdate   TIMESTAMP,
  openbalance    NUMERIC(10,2),
  logoutcount    INTEGER NOT NULL,
  balance        NUMERIC(10,2),
  accountid      INTEGER NOT NULL,
  lastlogin      TIMESTAMP,
  logincount     INTEGER NOT NULL,
  profile_userid VARCHAR(250),
  optlock        INTEGER,
  PRIMARY KEY (accountid)
);

CREATE TABLE holdingejb (
  purchaseprice    NUMERIC(10,2),
  holdingid        INTEGER NOT NULL,
  quantity         DOUBLE PRECISION NOT NULL,
  purchasedate     TIMESTAMP,
  account_accountid INTEGER,
  quote_symbol     VARCHAR(250),
  optlock          INTEGER,
  PRIMARY KEY (holdingid)
);

CREATE TABLE orderejb (
  orderfee          NUMERIC(10,2),
  completiondate    TIMESTAMP,
  ordertype         VARCHAR(250),
  orderstatus       VARCHAR(250),
  price             NUMERIC(10,2),
  quantity          DOUBLE PRECISION NOT NULL,
  opendate          TIMESTAMP,
  orderid           INTEGER NOT NULL,
  account_accountid INTEGER,
  quote_symbol      VARCHAR(250),
  holding_holdingid INTEGER,
  optlock           INTEGER,
  PRIMARY KEY (orderid)
);

CREATE INDEX profile_userid ON accountejb(profile_userid);
CREATE INDEX account_accountid ON holdingejb(account_accountid);
CREATE INDEX account_accountidt ON orderejb(account_accountid);
CREATE INDEX holding_holdingid ON orderejb(holding_holdingid);
CREATE INDEX orderstatus ON orderejb(orderstatus);
CREATE INDEX ordertype ON orderejb(ordertype);
