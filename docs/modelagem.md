# Estrutura da modelagem

## Visão geral

A modelagem foi construída em camadas, saindo da base bruta do Doc3040 até quatro tabelas fato prontas para consumo no Power BI. A ideia foi separar responsabilidades: cada camada resolve um problema específico, e a camada seguinte só usa o que já foi tratado, sem repetir lógica.

```
Doc3040_resumido.csv (bruto)
        │
        ▼
   fat_base_3040          → renomeia colunas para um padrão legível
        │
        ▼
vw_base_enriquecida        → junta com as dimensões (cliente, modalidade, risco)
        │
        ▼
   vw_base_atraso          → calcula histórico de atraso (over e ever30/60/90)
        │
        ▼
   vw_base_risco           → camada de passagem (isolada para futuras regras de risco)
        │
        ▼
  vw_base_financeira        → calcula idade da operação e comprometimento de renda
        │
        ▼
   vw_base_tratada          → base final, única fonte para as tabelas fato
        │
        ├──► f_carteira      (posição mensal da carteira)
        ├──► f_concessao     (novas concessões por mês)
        ├──► f_safra         (análise de vintage/cohort)
        └──► f_clientes      (perfil de comprometimento de renda)
```

## Por que separar em camadas

Dava para fazer tudo em uma query só, mas eu preferi separar por dois motivos:

1. **Rastreabilidade**: se um número parecer errado no dashboard, dá pra isolar em qual camada o problema está, sem precisar reler 200 linhas de SQL de uma vez.
2. **Reuso**: `vw_base_tratada` é a fonte única de verdade. As quatro tabelas fato (carteira, concessão, safra, clientes) partem todas dela, então qualquer correção feita uma vez se propaga para as quatro.

## Decisões de modelagem que valem explicar

**Over vs. Ever.** "Over30" indica que o contrato está com mais de 30 dias de atraso *naquele mês específico*. "Ever30" indica que o contrato *já chegou a ficar* com mais de 30 dias de atraso em algum momento da sua história, mesmo que hoje esteja em dia. Essa segunda métrica é calculada com uma window function (`MAX() OVER (PARTITION BY cod_contrato ORDER BY dat_base ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`), olhando o acumulado até a data-base atual. É a métrica usada em análise de vintage, porque mostra o comportamento real da safra ao longo do tempo, não só a foto do mês.

**Safra e seasoning.** Cada contrato é associado ao mês da sua contratação (safra) e, para cada data-base, calculamos há quantos meses aquela safra está "amadurecendo" (`idade_safra` / `mes_seasoning`). Isso permite comparar safras diferentes no mesmo estágio de vida, por exemplo: a safra de janeiro/2023 com 6 meses de idade teve mais inadimplência que a de janeiro/2024 com 6 meses de idade?

**Comprometimento de renda.** Para pessoa física, é a parcela dividida pela renda informada. Para pessoa jurídica, o faturamento anual foi convertido para base mensal antes do cálculo, porque comparar parcela mensal com faturamento anual bruto distorceria o indicador.

**Checagens de qualidade antes de modelar.** Antes de criar qualquer view, rodei validações de duplicidade de contrato/data-base, valores negativos em campos que não deveriam ser negativos, e nulos em colunas-chave. Isso não aparece no dashboard final, mas evitou que inconsistências da base bruta se propagassem para os indicadores.
