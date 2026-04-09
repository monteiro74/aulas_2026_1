USE [cafe]
GO

/****** Object:  Table [dbo].[vendas]    Script Date: 09/04/2026 11:18:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[vendas](
	[Codigo] [int] IDENTITY(1,1) NOT NULL,
	[DataVenda] [date] NOT NULL,
	[Vendedor] [varchar](100) NOT NULL,
	[Cidade] [varchar](100) NOT NULL,
	[Municipio] [varchar](100) NOT NULL,
	[Loja] [varchar](100) NOT NULL,
	[CategoriaProduto] [varchar](100) NOT NULL,
	[GrupoProduto] [varchar](100) NOT NULL,
	[Estado] [char](2) NOT NULL,
	[ClasseCliente] [varchar](20) NOT NULL,
	[Quantidade] [int] NOT NULL,
	[ValorVenda] [decimal](12, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[vendas]  WITH CHECK ADD  CONSTRAINT [CK_vendas_ClasseCliente] CHECK  (([ClasseCliente]='Diamante' OR [ClasseCliente]='Ouro' OR [ClasseCliente]='Prata' OR [ClasseCliente]='Bronze'))
GO

ALTER TABLE [dbo].[vendas] CHECK CONSTRAINT [CK_vendas_ClasseCliente]
GO

ALTER TABLE [dbo].[vendas]  WITH CHECK ADD  CONSTRAINT [CK_vendas_Quantidade] CHECK  (([Quantidade]>(0)))
GO

ALTER TABLE [dbo].[vendas] CHECK CONSTRAINT [CK_vendas_Quantidade]
GO

ALTER TABLE [dbo].[vendas]  WITH CHECK ADD  CONSTRAINT [CK_vendas_ValorVenda] CHECK  (([ValorVenda]>=(0)))
GO

ALTER TABLE [dbo].[vendas] CHECK CONSTRAINT [CK_vendas_ValorVenda]
GO

