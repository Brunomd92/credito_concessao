# Dicionário de dados

## Base de origem: Doc3040_resumido.csv

Base fictícia com estrutura equivalente ao Documento 3040 (SCR), enviado mensalmente ao Banco Central. Já vem agregada por contrato e fechamento de mês.

| Coluna original | Renomeada para | Descrição |
|---|---|---|
| DtBase | dat_base | Data-base do fechamento mensal |
| Tp | tipo_cliente | Tipo de cliente (1 = PF, 2 = PJ) |
| Autorzc | cod_autorizacao | Código de autorização da operação |
| FatAnual | vlr_faturamento_cliente | Faturamento anual (PJ) ou renda anual (PF) |
| Contrt | cod_contrato | Identificador único do contrato |
| Mod | cod_modalidade | Código da modalidade de crédito |
| TaxEft | tax_efetiva | Taxa efetiva de juros da operação |
| DtContr | dat_contratacao | Data de contratação da operação |
| VlrContr | vlr_contrato | Valor total contratado |
| ClassOp | cod_risco_operacao | Classificação de risco (AA a H, conforme Bacen) |
| ProvConsttd | prov_constituida | Provisão constituída para a operação |
| DiaAtraso | num_dias_atraso | Dias de atraso na data-base |
| VlrProxParcela | vlr_proxima_parcela | Valor da próxima parcela a vencer |
| QtdParcelas | num_qtd_parcelas | Quantidade total de parcelas do contrato |
| SaldoAtivo | vlr_saldo_ativo | Soma do saldo dos vencimentos entre os códigos 101 e 299 |
| SaldoPerda | vlr_saldo_perda | Soma do saldo dos vencimentos a partir do código 300 (perda) |

## Dimensões criadas

**dim_tipo_cliente**

| cod_cliente | des_cliente |
|---|---|
| 1 | PF |
| 2 | PJ |

**dim_modalidade / dim_modalidade_sintetico**

| cod_modalidade | des_modalidade | des_modalidade_sintetico |
|---|---|---|
| 801 | Crédito Rural - Custeio | Crédito Rural |
| 802 | Crédito Rural - Investimento | Crédito Rural |
| 202 | Crédito Consignado | Crédito Consignado |
| 203 | Crédito Pessoal | Crédito Pessoal |
| 215 | Capital de Giro | Capital de Giro |

**dim_classificacao_risco**

Classificação de risco conforme faixas de atraso do Bacen (Resolução CMN 2.682), com percentual de provisão mínima exigida por faixa (de 0% na classe AA até 100% na H).

| classop | nivel_risco | atraso_dias | categoria_macro | pct_provisao |
|---|---|---|---|---|
| AA | Mínimo | 0 | Baixo Risco | 0,0% |
| A | Baixo | 1-14 | Baixo Risco | 0,5% |
| B | Moderado Baixo | 15-30 | Baixo Risco | 1,0% |
| C | Moderado | 31-60 | Risco Moderado | 3,0% |
| D | Substancial | 61-90 | Risco Moderado | 10,0% |
| E | Elevado | 91-120 | Risco Crítico | 30,0% |
| F | Muito Alto | 121-150 | Risco Crítico | 50,0% |
| G | Extremo | 151-180 | Risco Crítico | 70,0% |
| H | Inadimplência | > 180 | Default/Perda | 100,0% |
| HH | Prejuízo | Baixado | Default/Perda | 100,0% |
| 01 | Default Técnico | N/A | Default/Perda | 100,0% |

## Métricas derivadas (calculadas nas views)

| Métrica | Como é calculada | O que significa |
|---|---|---|
| over30 / over60 / over90 | `num_dias_atraso > N` no mês | Contrato está atrasado acima de N dias *naquele mês* |
| ever30 / ever60 / ever90 | `MAX()` acumulado por contrato via window function | Contrato *já chegou a ficar* atrasado acima de N dias em algum momento |
| idade_operacao_meses | `datediff('month', dat_contratacao, dat_base)` | Quantos meses se passaram desde a contratação |
| idade_safra / mes_seasoning | `datediff('month', mes_contratacao, dat_base)` | Maturação da safra: quantos meses após a originação |
| pct_comprometimento_renda | parcela / renda mensal (PJ com faturamento anual /12) | Percentual da renda comprometido com a parcela do contrato |
| faixa_comprometimento | bucket sobre pct_comprometimento_renda | 0-30% / 30-50% / +50% |
