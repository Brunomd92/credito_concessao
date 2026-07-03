# case_credito_concessao

# Análise de Carteira e Concessões de Crédito

Case técnico de analista de dados, focado em construir um dashboard de acompanhamento mensal de carteira de crédito para a alta gestão de um banco fictício, a partir dos dados que o Banco Central exige no Documento 3040 (SCR).

> **Sobre os dados**: todas as informações usadas aqui são fictícias, geradas para fins de teste técnico. Nenhum dado real de cliente, contrato ou instituição financeira está presente neste repositório.

## Por que esse projeto

Trabalho há alguns anos com dados de crédito no dia a dia (originação, conciliação, reconciliação de consignado) e queria ter um projeto público que mostrasse isso de ponta a ponta: da base bruta do Bacen até um dashboard pronto para decisão de negócio. Esse case surgiu de um processo seletivo e resolvi continuar evoluindo e publicar como portfólio.

## O desafio

Construir indicadores e visualizações que respondam duas perguntas centrais para a alta gestão:
- Qual o comportamento histórico da carteira de crédito?
- Qual a situação atual da carteira e das concessões?

Partindo de uma base já agregada por contrato e mês (padrão do Doc3040), sem nenhuma modelagem prévia.

## O que foi entregue

| Item | Onde está |
|---|---|
| Query de tratamento e modelagem dos dados | [`/sql`](./sql) |
| Dashboard interativo (Power BI) | [`/dashboard`](./dashboard) |
| Estrutura da modelagem | [`/docs/modelagem.md`](./docs/modelagem.md) |
| Dicionário de dados | [`/docs/dicionario_dados.md`](./docs/dicionario_dados.md) |
| Insights obtidos | [`/docs/insights.md`](./docs/insights.md) |

## Stack utilizada

- **DuckDB** (via Python) para tratamento e modelagem da base, simulando um ambiente de SQL analítico
- **Python / Pandas** para exploração inicial e checagens de qualidade de dados
- **Power BI** para o dashboard final

## Estrutura do dashboard

O relatório tem 4 páginas:

1. **Carteira de Crédito**: evolução do saldo ativo e da perda ao longo do tempo
2. **Concessão**: volume e ticket médio de novas concessões, distribuição por faixa de comprometimento de renda
3. **Safra**: análise de vintage/cohort, inadimplência por safra de originação (ever30/60/90)
4. **Política de Crédito**: relação entre comprometimento de renda, taxa efetiva e valor concedido, pensada como insumo para revisão de política de crédito

## Como reproduzir

1. Os dados de entrada (`Doc3040_resumido.csv` e o leiaute oficial `SCR3040_Leiaute.xls`) não estão neste repositório por terem sido fornecidos originalmente pelo processo seletivo. A estrutura das tabelas e o dicionário de dados em [`/docs/dicionario_dados.md`](./docs/dicionario_dados.md) permitem recriar uma base sintética equivalente.
2. As queries em [`/sql`](./sql) devem ser executadas na ordem numerada (01 → 04), pois cada etapa depende da anterior.
3. O arquivo `.pbix` em [`/dashboard`](./dashboard) pode ser aberto diretamente no Power BI Desktop.

## Sobre o autor

Bruno Medeiros Dornelles, analista de dados com background em contabilidade e ~10 anos de experiência em crédito e processos financeiros. [LinkedIn](#) · [outros projetos](#)
