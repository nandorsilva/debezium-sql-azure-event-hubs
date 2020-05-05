-- Create the test database
CREATE DATABASE dbEcommerce;
GO
USE dbEcommerce;
EXEC sys.sp_cdc_enable_db;

-- Create and populate our products using a single insert with many rows
CREATE TABLE produtos (
  id INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  descricao VARCHAR(512)
);
INSERT INTO produtos(nome,descricao)  VALUES ('Lapis','lapis de escrever');
INSERT INTO produtos(nome,descricao)  VALUES ('Borracha','borracha muito boa');
INSERT INTO produtos(nome,descricao)  VALUES ('Celular','celular hawaui');
INSERT INTO produtos(nome,descricao)  VALUES ('TV','50 polegadas');
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'produtos', @role_name = NULL, @supports_net_changes = 0;
GO
