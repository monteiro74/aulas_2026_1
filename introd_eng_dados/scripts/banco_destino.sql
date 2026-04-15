-- ============================================================
--  banco_destino_snowflake.sql
--  Conversão: banco_origem (modelo flat/estrela)
--           → banco_destino (modelo Snowflake)
--  SGBD   : MariaDB
--  Gerado : 2026-04-15
-- ============================================================
--  MODELO SNOWFLAKE – visão geral
--
--  fato_vendas
--    └─► dim_loja
--          └─► dim_endereco_loja
--                └─► dim_localizacao   (cidade / estado / cep)
--    └─► dim_produto
--          ├─► dim_marca
--          ├─► dim_fornecedor
--          └─► dim_categoria
--    └─► dim_tempo
-- ============================================================

-- -------------------------------------------------------
-- 0. Seleciona / cria o banco de destino
-- -------------------------------------------------------
CREATE DATABASE IF NOT EXISTS banco_destino
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE banco_destino;

-- -------------------------------------------------------
-- 1. DIMENSÃO LOCALIZAÇÃO  (subdimensão de endereço)
--    Normaliza cidade, estado e CEP fora do endereço.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_localizacao` (
    `id_localizacao`  INT            NOT NULL AUTO_INCREMENT,
    `cidade`          VARCHAR(50)    NOT NULL,
    `estado`          VARCHAR(50)    NOT NULL,
    `cep`             VARCHAR(10)    NOT NULL,
    PRIMARY KEY (`id_localizacao`),
    UNIQUE KEY `uq_localizacao` (`cidade`, `estado`, `cep`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Subdimensão de localização geográfica das lojas';

-- -------------------------------------------------------
-- 2. DIMENSÃO ENDEREÇO LOJA  (normalizada, referencia dim_localizacao)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_endereco_loja` (
    `id_endereco_loja`  INT           NOT NULL AUTO_INCREMENT,
    `rua`               VARCHAR(100)  DEFAULT NULL,
    `id_localizacao`    INT           NOT NULL,
    PRIMARY KEY (`id_endereco_loja`),
    CONSTRAINT `fk_endereco_localizacao`
        FOREIGN KEY (`id_localizacao`)
        REFERENCES `dim_localizacao` (`id_localizacao`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Dimensão de endereço das lojas – referencia dim_localizacao';

-- -------------------------------------------------------
-- 3. DIMENSÃO LOJA
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_loja` (
    `id_loja`           INT           NOT NULL AUTO_INCREMENT,
    `numero_da_loja`    VARCHAR(20)   DEFAULT NULL,
    `id_endereco_loja`  INT           NOT NULL,
    PRIMARY KEY (`id_loja`),
    CONSTRAINT `fk_loja_endereco`
        FOREIGN KEY (`id_endereco_loja`)
        REFERENCES `dim_endereco_loja` (`id_endereco_loja`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Dimensão loja – referencia dim_endereco_loja';

-- -------------------------------------------------------
-- 4. SUBDIMENSÕES DE PRODUTO
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_marca` (
    `id_marca`    INT          NOT NULL AUTO_INCREMENT,
    `nome_marca`  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (`id_marca`),
    UNIQUE KEY `uq_marca` (`nome_marca`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Subdimensão marca do produto';

CREATE TABLE IF NOT EXISTS `dim_fornecedor` (
    `id_fornecedor`    INT          NOT NULL AUTO_INCREMENT,
    `nome_fornecedor`  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (`id_fornecedor`),
    UNIQUE KEY `uq_fornecedor` (`nome_fornecedor`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Subdimensão fornecedor do produto';

CREATE TABLE IF NOT EXISTS `dim_categoria` (
    `id_categoria`    INT          NOT NULL AUTO_INCREMENT,
    `nome_categoria`  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (`id_categoria`),
    UNIQUE KEY `uq_categoria` (`nome_categoria`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Subdimensão categoria do produto';

-- -------------------------------------------------------
-- 5. DIMENSÃO PRODUTO  (referencia três subdimensões)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_produto` (
    `id_produto`     INT           NOT NULL AUTO_INCREMENT,
    `nome_produto`   VARCHAR(100)  DEFAULT NULL,
    `id_marca`       INT           NOT NULL,
    `id_fornecedor`  INT           NOT NULL,
    `id_categoria`   INT           NOT NULL,
    PRIMARY KEY (`id_produto`),
    CONSTRAINT `fk_produto_marca`
        FOREIGN KEY (`id_marca`)
        REFERENCES `dim_marca` (`id_marca`),
    CONSTRAINT `fk_produto_fornecedor`
        FOREIGN KEY (`id_fornecedor`)
        REFERENCES `dim_fornecedor` (`id_fornecedor`),
    CONSTRAINT `fk_produto_categoria`
        FOREIGN KEY (`id_categoria`)
        REFERENCES `dim_categoria` (`id_categoria`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Dimensão produto – normalizada em marca, fornecedor e categoria';

-- -------------------------------------------------------
-- 6. DIMENSÃO TEMPO  (expandida a partir de id_data)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `dim_tempo` (
    `id_tempo`      INT          NOT NULL AUTO_INCREMENT,
    `data_completa` DATE         NOT NULL,
    `dia`           TINYINT      NOT NULL,
    `mes`           TINYINT      NOT NULL,
    `ano`           SMALLINT     NOT NULL,
    `trimestre`     TINYINT      NOT NULL,
    `nome_mes`      VARCHAR(15)  NOT NULL,
    `dia_semana`    VARCHAR(15)  NOT NULL,
    PRIMARY KEY (`id_tempo`),
    UNIQUE KEY `uq_data` (`data_completa`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Dimensão temporal expandida';

-- -------------------------------------------------------
-- 7. TABELA FATO – VENDAS
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `fato_vendas` (
    `id_fato`           INT             NOT NULL AUTO_INCREMENT,
    `id_tempo`          INT             NOT NULL,
    `id_loja`           INT             NOT NULL,
    `id_produto`        INT             NOT NULL,
    `unidades_vendidas` INT             DEFAULT NULL,
    `valor_total`       DECIMAL(10,2)   DEFAULT NULL,
    PRIMARY KEY (`id_fato`),
    CONSTRAINT `fk_fato_tempo`
        FOREIGN KEY (`id_tempo`)
        REFERENCES `dim_tempo` (`id_tempo`),
    CONSTRAINT `fk_fato_loja`
        FOREIGN KEY (`id_loja`)
        REFERENCES `dim_loja` (`id_loja`),
    CONSTRAINT `fk_fato_produto`
        FOREIGN KEY (`id_produto`)
        REFERENCES `dim_produto` (`id_produto`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci
  COMMENT='Tabela fato de vendas – modelo Snowflake';


-- ============================================================
-- CARGA DE DADOS  (migração do banco_origem)
-- ============================================================

-- -------------------------------------------------------
-- 8. Popula dim_localizacao  (deduplica cidade/estado/cep)
-- -------------------------------------------------------
INSERT INTO `dim_localizacao` (`cidade`, `estado`, `cep`)
SELECT DISTINCT `cidade`, `estado`, `cep`
FROM   `banco_origem`.`endereco_lojas1`;

-- -------------------------------------------------------
-- 9. Popula dim_endereco_loja
-- -------------------------------------------------------
INSERT INTO `dim_endereco_loja` (`id_endereco_loja`, `rua`, `id_localizacao`)
SELECT
    e.`id_endereco_loja`,
    e.`rua`,
    l.`id_localizacao`
FROM  `banco_origem`.`endereco_lojas1` e
JOIN  `banco_destino`.`dim_localizacao` l
      ON  l.`cidade` = e.`cidade`
      AND l.`estado` = e.`estado`
      AND l.`cep`    = e.`cep`;

-- -------------------------------------------------------
-- 10. Popula dim_loja
-- -------------------------------------------------------
INSERT INTO `dim_loja` (`id_loja`, `numero_da_loja`, `id_endereco_loja`)
SELECT `id_loja`, `numero_da_loja`, `id_endereco_loja`
FROM   `banco_origem`.`lojas1`;

-- -------------------------------------------------------
-- 11. Popula subdimensões de produto
-- -------------------------------------------------------
INSERT INTO `dim_marca` (`nome_marca`)
SELECT DISTINCT `marca_produto`
FROM   `banco_origem`.`produtos1`;

INSERT INTO `dim_fornecedor` (`nome_fornecedor`)
SELECT DISTINCT `fornecedor_produto`
FROM   `banco_origem`.`produtos1`;

INSERT INTO `dim_categoria` (`nome_categoria`)
SELECT DISTINCT `categoria_produto`
FROM   `banco_origem`.`produtos1`;

-- -------------------------------------------------------
-- 12. Popula dim_produto
-- -------------------------------------------------------
INSERT INTO `dim_produto` (`id_produto`, `nome_produto`, `id_marca`, `id_fornecedor`, `id_categoria`)
SELECT
    p.`id_produto`,
    p.`nome_produto`,
    m.`id_marca`,
    f.`id_fornecedor`,
    c.`id_categoria`
FROM  `banco_origem`.`produtos1`   p
JOIN  `banco_destino`.`dim_marca`      m ON m.`nome_marca`      = p.`marca_produto`
JOIN  `banco_destino`.`dim_fornecedor` f ON f.`nome_fornecedor`  = p.`fornecedor_produto`
JOIN  `banco_destino`.`dim_categoria`  c ON c.`nome_categoria`   = p.`categoria_produto`;

-- -------------------------------------------------------
-- 13. Popula dim_tempo  (extrai atributos de cada data distinta)
-- -------------------------------------------------------
INSERT INTO `dim_tempo` (`data_completa`, `dia`, `mes`, `ano`, `trimestre`, `nome_mes`, `dia_semana`)
SELECT DISTINCT
    v.`id_data`                                  AS `data_completa`,
    DAY(v.`id_data`)                             AS `dia`,
    MONTH(v.`id_data`)                           AS `mes`,
    YEAR(v.`id_data`)                            AS `ano`,
    QUARTER(v.`id_data`)                         AS `trimestre`,
    DATE_FORMAT(v.`id_data`, '%M')               AS `nome_mes`,
    DATE_FORMAT(v.`id_data`, '%W')               AS `dia_semana`
FROM  `banco_origem`.`vendas1` v;

-- -------------------------------------------------------
-- 14. Popula fato_vendas
-- -------------------------------------------------------
INSERT INTO `fato_vendas` (`id_tempo`, `id_loja`, `id_produto`, `unidades_vendidas`, `valor_total`)
SELECT
    t.`id_tempo`,
    v.`id_loja`,
    v.`id_produto`,
    v.`unidades_vendidas`,
    v.`valor_total`
FROM  `banco_origem`.`vendas1`     v
JOIN  `banco_destino`.`dim_tempo`  t ON t.`data_completa` = v.`id_data`;


-- ============================================================
-- VERIFICAÇÃO  (consultas rápidas para conferência)
-- ============================================================
-- SELECT * FROM banco_destino.dim_localizacao;
-- SELECT * FROM banco_destino.dim_endereco_loja;
-- SELECT * FROM banco_destino.dim_loja;
-- SELECT * FROM banco_destino.dim_marca;
-- SELECT * FROM banco_destino.dim_fornecedor;
-- SELECT * FROM banco_destino.dim_categoria;
-- SELECT * FROM banco_destino.dim_produto;
-- SELECT * FROM banco_destino.dim_tempo;
-- SELECT * FROM banco_destino.fato_vendas;

-- Consulta analítica de exemplo (une todas as camadas):
-- SELECT
--     t.data_completa, t.nome_mes, t.ano,
--     lj.numero_da_loja,
--     loc.cidade, loc.estado,
--     p.nome_produto,
--     m.nome_marca, f.nome_fornecedor, c.nome_categoria,
--     fv.unidades_vendidas, fv.valor_total
-- FROM fato_vendas   fv
-- JOIN dim_tempo     t   ON t.id_tempo     = fv.id_tempo
-- JOIN dim_loja      lj  ON lj.id_loja     = fv.id_loja
-- JOIN dim_endereco_loja el ON el.id_endereco_loja = lj.id_endereco_loja
-- JOIN dim_localizacao   loc ON loc.id_localizacao = el.id_localizacao
-- JOIN dim_produto   p   ON p.id_produto   = fv.id_produto
-- JOIN dim_marca     m   ON m.id_marca     = p.id_marca
-- JOIN dim_fornecedor f  ON f.id_fornecedor = p.id_fornecedor
-- JOIN dim_categoria  c  ON c.id_categoria  = p.id_categoria
-- ORDER BY t.data_completa, lj.numero_da_loja;