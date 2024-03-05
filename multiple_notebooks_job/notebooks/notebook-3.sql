CREATE
OR REPLACE TABLE poc_catalog.poc_schema.employeeTable3 (
  id INT NOT NULL,
  name STRING NOT NULL,
  age INT DEFAULT 10,
  PRIMARY KEY(id)
) TBLPROPERTIES (
  delta.enableChangeDataFeed = true,
  delta.feature.allowColumnDefaults = 'supported'
);

insert into  poc_catalog.poc_schema.employeeTable3(id, name, age) values(1,'sanjiv',21);