# Insights obtidos

## Crescimento da originação

O volume de concessões cresceu de forma consistente entre 2022 e 2024. Em janeiro/2022 foram 4.238 contratos somando R$ 239,2 milhões concedidos; em agosto/2024, o pico da série, foram 8.917 contratos e R$ 745,5 milhões. É praticamente o dobro em volume de contratos e mais que o triplo em valor concedido em pouco menos de 3 anos.

## Sazonalidade na concessão

A série mensal mostra um padrão sazonal bem definido: os meses de julho a setembro concentram os maiores volumes de concessão em todos os anos analisados (2022, 2023 e 2024), com queda nos meses de início de ano (janeiro a março). Isso é um ponto relevante para planejamento de capacidade operacional e de funding ao longo do ano.

## Comportamento por safra (vintage)

A análise de safra permite comparar diferentes coortes de originação no mesmo estágio de maturação, em vez de olhar só a foto do mês. Isso é o que possibilita identificar, por exemplo, se uma safra específica está performando pior que as anteriores já nos primeiros meses de vida, um sinal de alerta antecipado para revisão de política de crédito, muito antes do problema aparecer no saldo consolidado da carteira.

## Comprometimento de renda como preditor de risco

O cruzamento entre faixa de comprometimento de renda (0-30%, 30-50%, +50%) e indicadores de atraso (ever30/60/90) foi construído justamente para testar a hipótese de que clientes mais comprometidos financeiramente tendem a apresentar pior comportamento de pagamento. A página "Política de Crédito" do dashboard existe para dar suporte visual a essa análise e é a base para eventuais recomendações de ajuste de política (por exemplo, limitar concessão acima de determinada faixa de comprometimento).

## Qualidade da base como pré-requisito

Antes de qualquer indicador, a checagem de duplicidade, nulos e valores negativos evitou que inconsistências estruturais da base se propagassem para as métricas finais. Isso não é um "insight de negócio", mas é o tipo de disciplina que evita apresentar um número errado para a alta gestão.

---

> Nota: alguns números específicos de saldo consolidado (crescimento total da carteira no período, taxa média por safra completa) foram calculados na exploração em notebook mas não estão fixados aqui porque dependem da massa de dados fictícia gerada no momento do teste. Ao reproduzir com uma base sintética própria, vale recalcular e substituir os números acima pelos valores obtidos.
