# Host: 127.0.0.1  (Version 8.0.30)
# Date: 2026-04-15 13:23:00
# Generator: MySQL-Front 6.1  (Build 1.26)


#
# Structure for table "endereco_lojas1"
#

CREATE TABLE `endereco_lojas1` (
  `id_endereco_loja` int NOT NULL,
  `rua` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cidade` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estado` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cep` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_endereco_loja`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

#
# Data for table "endereco_lojas1"
#

INSERT INTO `endereco_lojas1` VALUES (1,'Rua A, 123','São Paulo','SP','01000-000'),(2,'Av. B, 456','Rio de Janeiro','RJ','20000-000'),(3,'Rua C, 789','Belo Horizonte','MG','30000-000'),(4,'Av. D, 101','Curitiba','PR','80000-000'),(5,'Rua E, 202','Porto Alegre','RS','90000-000');

#
# Structure for table "lojas1"
#

CREATE TABLE `lojas1` (
  `id_loja` int NOT NULL,
  `numero_da_loja` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_endereco_loja` int DEFAULT NULL,
  PRIMARY KEY (`id_loja`),
  KEY `id_endereco_loja` (`id_endereco_loja`),
  CONSTRAINT `lojas1_ibfk_1` FOREIGN KEY (`id_endereco_loja`) REFERENCES `endereco_lojas1` (`id_endereco_loja`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

#
# Data for table "lojas1"
#

INSERT INTO `lojas1` VALUES (1,'LJ001',1),(2,'LJ002',2),(3,'LJ003',3),(4,'LJ004',4),(5,'LJ005',5);

#
# Structure for table "produtos1"
#

CREATE TABLE `produtos1` (
  `id_produto` int NOT NULL,
  `nome_produto` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `marca_produto` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fornecedor_produto` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `categoria_produto` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_produto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

#
# Data for table "produtos1"
#

INSERT INTO `produtos1` VALUES (1,'Smartphone X','TechBrand','Fornecedor A','Eletrônicos'),(2,'Notebook Pro','NoteCo','Fornecedor B','Informática'),(3,'TV 50\"','VisionTV','Fornecedor C','Eletrônicos'),(4,'Fone de Ouvido','SoundMax','Fornecedor A','Acessórios'),(5,'Mouse Gamer','GameTech','Fornecedor B','Informática');

#
# Structure for table "vendas1"
#

CREATE TABLE `vendas1` (
  `id_data` date NOT NULL,
  `id_loja` int NOT NULL,
  `id_produto` int NOT NULL,
  `unidades_vendidas` int DEFAULT NULL,
  `valor_total` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_data`,`id_loja`,`id_produto`),
  KEY `id_loja` (`id_loja`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `vendas1_ibfk_1` FOREIGN KEY (`id_loja`) REFERENCES `lojas1` (`id_loja`),
  CONSTRAINT `vendas1_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produtos1` (`id_produto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

#
# Data for table "vendas1"
#

INSERT INTO `vendas1` VALUES ('2025-04-01',1,1,10,5000.00),('2025-04-01',2,2,5,12500.00),('2025-04-02',3,3,3,7500.00),('2025-04-03',4,4,15,1500.00),('2025-04-03',5,5,7,1050.00);
