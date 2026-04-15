# -*- coding: utf-8 -*-
# ==============================================================================
# Nome do Script: p1.py - Exportação de Dados de Empresas para CSV
# Descrição: Este script conecta-se a um banco de dados MySQL, realiza uma
#            consulta SQL na tabela de empresas e exporta os registros
#            obtidos para um arquivo CSV. O objetivo é extrair dados
#            diretamente do banco para posterior análise em ferramentas
#            externas.
#
# Autor: Nome do aluno
# Data de Criação: 
# Hora de Criação: 
#
# Dependências:
# - pandas: Para manipulação e exportação dos dados em CSV.
# - sqlalchemy: Para criar a conexão com o banco de dados MySQL.
# - pymysql: Driver utilizado na conexão com MySQL.
# - os: Para manipulação de caminhos de arquivos.
#
# Uso: Ajuste as credenciais de conexão no início do script ou utilize os
#      inputs comentados para inseri-las em tempo de execução. Execute o
#      programa e o CSV será gerado na mesma pasta do script.
# ==============================================================================

import pandas as pd
import os
from sqlalchemy import create_engine

# ======= DADOS DE ACESSO =======
host = "localhost"
user = "root"
password = ""
database = "dados_abertos"
tabela = "empresas"

# ======= ENTRADA VIA USUÁRIO (opcional) =======
# host = input("Digite o host (ex: localhost): ")
# user = input("Digite o usuário (ex: admin): ")
# password = input("Digite a senha (ex: 123): ")
# database = input("Digite o nome do banco (ex: dados_abertos): ")
# tabela = input("Digite o nome da tabela (ex: empresas): ")

# ======= STRING DE CONEXÃO =======
try:
    engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}/{database}")
    print("Conexão realizada com sucesso!")

    # ======= CONSULTA SQL =======
    query = f"SELECT * FROM `{tabela}` LIMIT 1000;"
    
    # ======= EXPORTAÇÃO =======
    df = pd.read_sql(query, con=engine)
    nome_arquivo = os.path.join(os.getcwd(), f"{tabela}_export.csv")
    df.to_csv(nome_arquivo, index=False, sep=';', encoding='utf-8')

    print(f"Exportação concluída com sucesso: {nome_arquivo}")

except Exception as e:
    print(f"Erro ao conectar ou exportar: {e}")
