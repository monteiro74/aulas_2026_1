# Diagrama Entidade-Relacionamento — Exercício SQL

```mermaid
erDiagram

    tblAlunos {
        INT IdAluno PK
        VARCHAR_100 Nome
        DATE Aniversario
        VARCHAR_1 Sexo
        DECIMAL_10_2 Salario
    }

    tblSituacao {
        INT IdSituacao PK
        VARCHAR_30 Situacao
    }

    tblCursos {
        INT IdCurso PK
        VARCHAR_50 NomeCurso
    }

    tblTurmas {
        INT IdTurma PK
        INT IdAluno FK
        INT IdCurso FK
        VARCHAR_50 DescricaoTurma
        DECIMAL_15_2 PrecoTurma
        DATE DataInicio
        DATE DataFim
    }

    tblPresencas {
        INT IdTurma FK
        INT IdAluno FK
        INT IdSituacao FK
        DATE DataPresenca
    }

    tblPets {
        INT IdPet PK
        VARCHAR_50 Apelido
        VARCHAR_50 Raca
        INT IdAluno FK
        DECIMAL_18_2 Valor
    }

    tblAlunos   ||--o{ tblTurmas    : possui
    tblCursos   ||--o{ tblTurmas    : compoe
    tblTurmas   ||--o{ tblPresencas : registra
    tblAlunos   ||--o{ tblPresencas : participa
    tblSituacao ||--o{ tblPresencas : classifica
    tblAlunos   ||--o{ tblPets      : possui
```