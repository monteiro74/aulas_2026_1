-- =======================================================
-- 1) CRIAÇÃO DO BANCO DE DADOS
-- =======================================================

-- No PostgreSQL, CREATE DATABASE deve ser executado fora de transação
-- e a conexão precisa ser aberta no banco depois.
-- Execute como usuário com permissão apropriada.

-- CREATE DATABASE cafe;

-- Depois conecte no banco "cafe" antes de executar o restante do script.
-- Exemplo no psql:
-- \c cafe

-- =======================================================
-- 2) CRIAÇÃO DA TABELA ALUNOS
-- =======================================================

DROP TABLE IF EXISTS tblPresencas CASCADE;
DROP TABLE IF EXISTS tblTurmas CASCADE;
DROP TABLE IF EXISTS tblPets CASCADE;
DROP TABLE IF EXISTS tblSituacao CASCADE;
DROP TABLE IF EXISTS tblCursos CASCADE;
DROP TABLE IF EXISTS tblAlunos CASCADE;

CREATE TABLE tblAlunos
(
    IdAluno      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nome         VARCHAR(100) NOT NULL,
    Aniversario  DATE NOT NULL,
    Sexo         VARCHAR(1) NOT NULL,
    Salario      NUMERIC(10,2) NOT NULL
);

-- =======================================================
-- 3) INSERINDO DADOS NA TABELA ALUNOS
-- =======================================================

INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('ANA',     DATE '1997-12-31', 'F', 5000.00);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('BOB',     DATE '1998-05-22', 'M', 2500.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('BILL',    DATE '1995-07-15', 'M', 3500.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('CLARA',   DATE '1981-08-17', 'F', 4000.50);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('DANIEL',  DATE '2003-11-25', 'M', 3500.00);
INSERT INTO tblAlunos (Nome, Aniversario, Sexo, Salario) VALUES ('DANIELA', DATE '2003-12-20', 'F', 5500.00);

SELECT IdAluno, Nome, Aniversario, Sexo, Salario
FROM tblAlunos
LIMIT 1000;

SELECT * FROM tblAlunos;

-- =======================================================
-- 4) TABELA SITUAÇÃO (STATUS DO ALUNO)
-- =======================================================

CREATE TABLE tblSituacao
(
    IdSituacao INT PRIMARY KEY,
    Situacao   VARCHAR(30) NOT NULL
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
    IdCurso   INT PRIMARY KEY,
    NomeCurso VARCHAR(50) NOT NULL
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
    IdTurma        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    IdAluno        INT NOT NULL,
    IdCurso        INT NOT NULL,
    DescricaoTurma VARCHAR(50) NOT NULL,
    PrecoTurma     NUMERIC(15,2) NOT NULL,
    DataInicio     DATE NOT NULL,
    DataFim        DATE NULL
);

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 1, 'C++ DE FÉRIAS', 1250.50, DATE '2023-10-25', DATE '2023-10-29');

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 2, 'C++ DE FÉRIAS', 1250.50, DATE '2023-10-25', DATE '2023-10-29');

INSERT INTO tblTurmas (IdAluno, IdCurso, DescricaoTurma, PrecoTurma, DataInicio, DataFim)
VALUES (1, 3, 'C++ DE FÉRIAS', 0.00, DATE '2023-10-25', DATE '2023-10-29');

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
VALUES (1, 1, 2, DATE '2023-10-26');

INSERT INTO tblPresencas (IdTurma, IdAluno, IdSituacao, DataPresenca)
VALUES (1, 2, 2, DATE '2023-10-26');

INSERT INTO tblPresencas (IdTurma, IdAluno, IdSituacao, DataPresenca)
VALUES (1, 3, 2, DATE '2023-10-26');

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
    IdPet   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Apelido VARCHAR(50)   NOT NULL,
    Raca    VARCHAR(50)   NOT NULL,
    IdAluno INT           NULL,
    Valor   NUMERIC(18,2) NULL
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

SELECT *
FROM tblAlunos a
FULL OUTER JOIN tblPets b ON a.IdAluno = b.IdAluno;

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

SELECT 500 / 2 AS valor;
SELECT POWER(2, 2) AS valor;
SELECT SQRT(35) AS valor;
SELECT PI() AS valorPI;

SELECT CURRENT_TIMESTAMP AS data_hora_atual;

-- =======================================================
-- 14) VIEW E TRIGGER
-- =======================================================

DROP VIEW IF EXISTS minhaView;

CREATE VIEW minhaView AS
SELECT p.Apelido, p.Raca, p.Valor, a.Nome AS Dono
FROM tblPets AS p
JOIN tblAlunos AS a ON p.IdAluno = a.IdAluno;

-- No PostgreSQL, trigger precisa de função antes

DROP TRIGGER IF EXISTS aviso ON tblPets;
DROP FUNCTION IF EXISTS fn_aviso_tblpets();

CREATE OR REPLACE FUNCTION fn_aviso_tblpets()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Avisar o usuario';
END;
$$;

CREATE TRIGGER aviso
AFTER INSERT OR UPDATE OR DELETE
ON tblPets
FOR EACH STATEMENT
EXECUTE FUNCTION fn_aviso_tblpets();

-- Teste do trigger
-- Este comando irá falhar propositalmente por causa do RAISE EXCEPTION
-- INSERT INTO tblPets (Apelido, Raca, Valor) VALUES ('DOG5', 'FILA', 2300.00);

-- =======================================================
-- 15) USUÁRIO/ROLE PARA BACKUP
-- =======================================================

-- No PostgreSQL, login e role são tratados como roles.
-- Exemplo didático:

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'login_backup_cafe') THEN
      CREATE ROLE login_backup_cafe LOGIN PASSWORD 'Troque_Esta_Senha!123';
   END IF;
END
$$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_backuponly') THEN
      CREATE ROLE db_backuponly;
   END IF;
END
$$;

GRANT db_backuponly TO login_backup_cafe;

-- Observação:
-- Backup no PostgreSQL normalmente é feito com pg_dump/pg_basebackup,
-- não com comando SQL equivalente a BACKUP DATABASE do SQL Server.

-- =======================================================
-- 16) TAMANHO DO BANCO "cafe"
-- =======================================================

SELECT
    current_database() AS database_name,
    pg_size_pretty(pg_database_size(current_database())) AS size_pretty,
    pg_database_size(current_database()) AS size_bytes;

-- =======================================================
-- 17) TABELAS, COLUNAS E TIPOS DE DADOS
-- =======================================================

SELECT
    table_schema,
    table_name,
    ordinal_position AS column_id,
    column_name,
    data_type,
    character_maximum_length AS max_length,
    numeric_precision,
    numeric_scale,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name, ordinal_position;

-- =======================================================
-- 18) RECURSOS / VISÕES ADMINISTRATIVAS
-- =======================================================

-- O SQL original usa DMVs específicas do SQL Server para CPU, memória e I/O.
-- No PostgreSQL, equivalentes comuns dependem de extensões e visões de estatística.
-- Exemplos simples:

-- Estatísticas de banco
SELECT
    datname,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted
FROM pg_stat_database
WHERE datname = current_database();

-- Tamanho por relação (tabelas/índices)
SELECT
    schemaname,
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Arquivos do banco (visão aproximada do storage)
SELECT
    oid,
    datname
FROM pg_database
WHERE datname = current_database();