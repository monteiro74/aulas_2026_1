-- =======================================================
-- 1) CRIAÇÃO DO BANCO DE DADOS
-- =======================================================

CREATE DATABASE IF NOT EXISTS cafe;
USE cafe;

-- =======================================================
-- 2) CRIAÇÃO DA TABELA ALUNOS
-- =======================================================

DROP TABLE IF EXISTS tblPresencas;
DROP TABLE IF EXISTS tblTurmas;
DROP TABLE IF EXISTS tblPets;
DROP TABLE IF EXISTS tblSituacao;
DROP TABLE IF EXISTS tblCursos;
DROP TABLE IF EXISTS tblAlunos;

CREATE TABLE tblAlunos
(
    IdAluno      INT NOT NULL AUTO_INCREMENT,
    Nome         VARCHAR(100) NOT NULL,
    Aniversario  DATE NOT NULL,
    Sexo         VARCHAR(1) NOT NULL,
    Salario      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (IdAluno)
);

-- =======================================================
-- 3) INSERINDO DADOS NA TABELA ALUNOS
-- =======================================================

INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('ANA',     '1997-12-31', 'F', 5000.00);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('BOB',     '1998-05-22', 'M', 2500.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('BILL',    '1995-07-15', 'M', 3500.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('CLARA',   '1981-08-17', 'F', 4000.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('DANIEL',  '2003-11-25', 'M', 3500.00);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('DANIELA', '2003-12-20', 'F', 5500.00);

SELECT IdAluno, Nome, Aniversario, Sexo, Salario
FROM tblAlunos
LIMIT 1000;

SELECT * FROM tblAlunos;

-- =======================================================
-- 4) TABELA SITUAÇÃO (STATUS DO ALUNO)
-- =======================================================

CREATE TABLE tblSituacao
(
    IdSituacao INT NOT NULL,
    Situacao   VARCHAR(30) NOT NULL,
    PRIMARY KEY (IdSituacao)
);

INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (1, 'MATRICULADO');
INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (2, 'CURSANDO');
INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (3, 'APROVADO');
INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (4, 'REPROVADO');
INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (5, 'SUSPENSO');
INSERT INTO tblSituacao (IdSituacao, Situacao) VALUES (6, 'CANCELADO');

SELECT * FROM tblSituacao;

-- =======================================================
-- 5) TABELA CURSOS
-- =======================================================

CREATE TABLE tblCursos
(
    IdCurso   INT NOT NULL,
    NomeCurso VARCHAR(50) NOT NULL,
    PRIMARY KEY (IdCurso)
);

INSERT INTO tblCursos (IdCurso, NomeCurso) VALUES (1, 'PROGRAMACAO C++');
INSERT INTO tblCursos (IdCurso, NomeCurso) VALUES (2, 'BANCO DE DADOS 1');
INSERT INTO tblCursos (IdCurso, NomeCurso) VALUES (3, 'SISTEMAS OPERACIONAIS');
INSERT INTO tblCursos (IdCurso, NomeCurso) VALUES (4, 'REDES 2');

SELECT * FROM tblCursos;

-- =======================================================
-- 6) TABELA TURMAS
-- =======================================================

CREATE TABLE tblTurmas
(
    IdTurma        INT NOT NULL AUTO_INCREMENT,
    IdAluno        INT NOT NULL,
    IdCurso        INT NOT NULL,
    DescricaoTurma VARCHAR(50) NOT NULL,
    PrecoTurma     DECIMAL(15,2) NOT NULL,
    DataInicio     DATE NOT NULL,
    DataFim        DATE NULL,
    PRIMARY KEY (IdTurma)
);

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 1, 'C++ DE FÉRIAS', 1250.50, '2023-10-25', '2023-10-29');

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 2, 'C++ DE FÉRIAS', 1250.50, '2023-10-25', '2023-10-29');

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 3, 'C++ DE FÉRIAS', 0.00, '2023-10-25', '2023-10-29');

SELECT * FROM tblTurmas;

-- =======================================================
-- 7) TABELA PRESENÇAS
-- =======================================================

CREATE TABLE tblPresencas
(
    IdTurma      INT NOT NULL,
    IdAluno      INT NOT NULL,
    IdSituacao   INT NOT NULL,
    DataPresenca DATE NOT NULL
);

INSERT INTO tblPresencas (IdTurma, IdAluno, IdSituacao, DataPresenca)
VALUES (1, 1, 2, '2023-10-26');

INSERT INTO tblPresencas (IdTurma, IdAluno, IdSituacao, DataPresenca)
VALUES (1, 2, 2, '2023-10-26');

INSERT INTO tblPresencas (IdTurma, IdAluno, IdSituacao, DataPresenca)
VALUES (1, 3, 2, '2023-10-26');

-- =======================================================
-- 8) RELACIONAMENTOS (FOREIGN KEYS)
-- =======================================================

ALTER TABLE tblTurmas
  ADD CONSTRAINT fk_Turmas_Alunos
  FOREIGN KEY (IdAluno) REFERENCES tblAlunos(IdAluno);

ALTER TABLE tblTurmas
  ADD CONSTRAINT fk_Turmas_Cursos
  FOREIGN KEY (IdCurso) REFERENCES tblCursos(IdCurso);

ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_Presenca_Turma
  FOREIGN KEY (IdTurma) REFERENCES tblTurmas(IdTurma);

ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_Presenca_Aluno
  FOREIGN KEY (IdAluno) REFERENCES tblAlunos(IdAluno);

ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_Presenca_Sit
  FOREIGN KEY (IdSituacao) REFERENCES tblSituacao(IdSituacao);

-- =======================================================
-- 9) CONSULTAS AGREGADAS
-- =======================================================

SELECT COUNT(IdTurma) AS qtdeTurma FROM tblTurmas;
SELECT SUM(PrecoTurma) AS somaPreco FROM tblTurmas;
SELECT AVG(Salario) AS mediaSalario FROM tblAlunos;
SELECT MAX(Salario) AS maxSalario FROM tblAlunos;
SELECT MIN(Salario) AS minSalario FROM tblAlunos;

-- =======================================================
-- 10) TABELA PETS
-- =======================================================

CREATE TABLE tblPets
(
    IdPet   INT NOT NULL AUTO_INCREMENT,
    Apelido VARCHAR(50) NOT NULL,
    Raca    VARCHAR(50) NOT NULL,
    IdAluno INT NULL,
    Valor   DECIMAL(18,2) NULL,
    PRIMARY KEY (IdPet)
);

ALTER TABLE tblPets
  ADD CONSTRAINT fk_Pets_Alunos
  FOREIGN KEY (IdAluno) REFERENCES tblAlunos(IdAluno);

INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('DOG1', 'MASTIN',    1, 1500.00);
INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('DOG2', 'FILA',      2, 2500.00);
INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('DOG3', 'BULDOGUE',  3, 3500.00);
INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('CAT1', 'PERSA',     2, 1800.00);
INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('CAT2', 'ANGORA',    2, 2300.00);
INSERT INTO tblPets (Apelido, Raca, IdAluno, Valor) VALUES ('CAT3', 'SIAMES',    3,  990.00);
INSERT INTO tblPets (Apelido, Raca, Valor)          VALUES ('CAT4', 'SIAMES',       1000.00);
INSERT INTO tblPets (Apelido, Raca, Valor)          VALUES ('DOG4', 'FILA',         2000.00);

-- =======================================================
-- 11) CONSULTAS COM JOIN E CÁLCULOS
-- =======================================================

SELECT Apelido, Raca, IdAluno AS Dono, Valor, (Valor * 0.90) AS valorVendaAVista
FROM tblPets;

SELECT p.Apelido, p.Raca, p.Valor, a.Nome AS Dono
FROM tblPets AS p
JOIN tblAlunos AS a ON p.IdAluno = a.IdAluno;

SELECT *
FROM tblAlunos a
INNER JOIN tblPets b ON a.IdAluno = b.IdAluno;

SELECT *
FROM tblAlunos a
LEFT JOIN tblPets b ON a.IdAluno = b.IdAluno;

-- MariaDB não possui FULL OUTER JOIN nativo.
-- Equivalente didático:
SELECT *
FROM tblAlunos a
LEFT JOIN tblPets b ON a.IdAluno = b.IdAluno

UNION

SELECT *
FROM tblAlunos a
RIGHT JOIN tblPets b ON a.IdAluno = b.IdAluno;

-- =======================================================
-- 12) AGRUPAMENTO, HAVING E ORDER
-- =======================================================

SELECT Raca, AVG(Valor) AS mediaPreco, COUNT(*) AS qtdeRaca
FROM tblPets
GROUP BY Raca
ORDER BY Raca;

SELECT Raca, SUM(Valor) AS somaValor
FROM tblPets
GROUP BY Raca
HAVING SUM(Valor) > 1800
ORDER BY somaValor ASC;

-- =======================================================
-- 13) FUNÇÕES NUMÉRICAS E DE DATA
-- =======================================================

SELECT 500/2 AS valor;
SELECT POWER(2,2) AS valor;
SELECT SQRT(35) AS valor;
SELECT PI() AS valorPI;

SELECT NOW() AS data_hora_atual;

-- =======================================================
-- 14) VIEW E TRIGGER
-- =======================================================

DROP VIEW IF EXISTS minhaView;

CREATE VIEW minhaView AS
SELECT p.Apelido, p.Raca, p.Valor, a.Nome AS Dono
FROM tblPets AS p
JOIN tblAlunos AS a ON p.IdAluno = a.IdAluno;

-- Trigger em MariaDB exige delimitador
DROP TRIGGER IF EXISTS aviso;

DELIMITER $$

CREATE TRIGGER aviso
AFTER INSERT ON tblPets
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Avisar o usuario';
END$$

DELIMITER ;

-- Teste do trigger
-- Este INSERT vai disparar erro propositalmente:
-- INSERT INTO tblPets (Apelido, Raca, Valor) VALUES ('DOG5', 'FILA', 2300.00);

-- =======================================================
-- 15) USUÁRIO PARA ROTINAS DE BACKUP
-- =======================================================

-- Exemplo didático.
-- Em MariaDB, backup normalmente é feito com mysqldump/mariadb-dump,
-- não com BACKUP DATABASE como no SQL Server.

CREATE USER IF NOT EXISTS 'login_backup_cafe'@'localhost' IDENTIFIED BY 'Troque_Esta_Senha!123';

-- Ajuste as permissões conforme sua política de segurança.
GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES ON cafe.* TO 'login_backup_cafe'@'localhost';
FLUSH PRIVILEGES;

-- =======================================================
-- 16) TAMANHO DO BANCO "cafe"
-- =======================================================

SELECT
    table_schema AS database_name,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'cafe'
GROUP BY table_schema;

-- =======================================================
-- 17) TABELAS, COLUNAS E TIPOS DE DADOS
-- =======================================================

SELECT
    table_schema,
    table_name,
    ordinal_position AS column_id,
    column_name,
    column_type,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_key,
    extra
FROM information_schema.columns
WHERE table_schema = 'cafe'
ORDER BY table_name, ordinal_position;

-- =======================================================
-- 18) RECURSOS / STATUS BÁSICO
-- =======================================================

-- Consultas simples de monitoramento no MariaDB

SHOW DATABASES;
SHOW TABLE STATUS FROM cafe;
SHOW PROCESSLIST;

-- Variáveis e status do servidor
SHOW GLOBAL STATUS;
SHOW VARIABLES;