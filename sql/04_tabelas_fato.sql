-- ============================================================
-- 04_tabelas_fato.sql
-- Tabelas fato finais, consumidas diretamente pelo Power BI.
-- Todas partem de vw_base_tratada.
-- ============================================================

-- f_carteira: posição mensal consolidada da carteira ---------------
CREATE OR REPLACE TABLE f_carteira AS
SELECT
    dat_base,
    mes_contratacao,
    datediff('month', mes_contratacao, dat_base) AS idade_safra,
    tipo_cliente,
    des_cliente,
    cod_modalidade,
    des_modalidade_sintetico,
    cod_risco_operacao,
    nivel_risco AS categoria_risco,

    COUNT(*)                AS qtd_contratos,
    SUM(vlr_contrato)       AS vlr_contrato,
    SUM(vlr_saldo_ativo)    AS vlr_saldo_ativo,
    SUM(vlr_saldo_perda)    AS vlr_saldo_perda,
    SUM(prov_constituida)   AS vlr_provisao,

    SUM(over30)  AS qtd_over30,
    SUM(over60)  AS qtd_over60,
    SUM(over90)  AS qtd_over90,

    SUM(ever30)  AS qtd_ever30,
    SUM(ever60)  AS qtd_ever60,
    SUM(ever90)  AS qtd_ever90,

    SUM(vlr_over30) AS vlr_over30,
    SUM(vlr_over60) AS vlr_over60,
    SUM(vlr_over90) AS vlr_over90,

    SUM(vlr_ever30_saldo) AS vlr_ever30_saldo,
    SUM(vlr_ever60_saldo) AS vlr_ever60_saldo,
    SUM(vlr_ever90_saldo) AS vlr_ever90_saldo,

    SUM(vlr_ever30_originado) AS vlr_ever30_originado,
    SUM(vlr_ever60_originado) AS vlr_ever60_originado,
    SUM(vlr_ever90_originado) AS vlr_ever90_originado,

    AVG(tax_efetiva) AS taxa_media
FROM vw_base_tratada
GROUP BY ALL;


-- f_concessao: uma linha por contrato, na safra de originação ------
CREATE OR REPLACE TABLE f_concessao AS
WITH base_contrato AS (
    SELECT
        cod_contrato,
        MIN(mes_contratacao)        AS mes_contratacao,
        MAX(tipo_cliente)            AS tipo_cliente,
        MAX(des_cliente)             AS des_cliente,
        MAX(cod_modalidade)          AS cod_modalidade,
        MAX(des_modalidade_sintetico) AS des_modalidade_sintetico,
        MAX(cod_risco_operacao)      AS cod_risco_operacao,
        MAX(nivel_risco)             AS nivel_risco,
        MAX(vlr_contrato)            AS vlr_contrato,
        AVG(tax_efetiva)             AS tax_efetiva
    FROM vw_base_tratada
    WHERE mes_contratacao >= '2022-01-01'
      AND mes_contratacao IS NOT NULL
    GROUP BY cod_contrato
)
SELECT
    mes_contratacao,
    tipo_cliente,
    des_cliente,
    cod_modalidade,
    des_modalidade_sintetico,
    cod_risco_operacao,
    nivel_risco,

    COUNT(*)             AS qtd_contratos,
    SUM(vlr_contrato)    AS vlr_concedido,
    AVG(vlr_contrato)    AS ticket_medio,
    AVG(tax_efetiva)     AS taxa_media
FROM base_contrato
GROUP BY ALL
ORDER BY mes_contratacao DESC;


-- f_safra: análise de vintage / cohort com aging --------------------
CREATE OR REPLACE TABLE f_safra AS
WITH Base_Formatada AS (
    SELECT
        cod_contrato,
        CAST(DATE_TRUNC('month', mes_contratacao) AS DATE) AS safra,
        CAST(dat_base AS DATE)                              AS data_base,
        CAST(vlr_contrato_inicial AS DECIMAL(18,2))         AS vlr_contrato_inicial,
        CAST(vlr_saldo_ativo AS DECIMAL(18,2))              AS vlr_saldo_ativo,
        CAST(tax_efetiva AS DECIMAL(10,4))                  AS tax_efetiva,
        CAST(num_dias_atraso AS INTEGER)                    AS num_dias_atraso,
        CAST(idade_operacao_meses AS INTEGER)               AS mes_seasoning
    FROM vw_base_tratada
),

Base_Flags AS (
    SELECT
        *,
        CASE WHEN num_dias_atraso > 30 THEN 1 ELSE 0 END AS flg_over30,
        CASE WHEN num_dias_atraso > 60 THEN 1 ELSE 0 END AS flg_over60,
        CASE WHEN num_dias_atraso > 90 THEN 1 ELSE 0 END AS flg_over90,

        MAX(CASE WHEN num_dias_atraso > 30 THEN 1 ELSE 0 END)
            OVER (PARTITION BY cod_contrato ORDER BY data_base
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS flg_ever30,

        MAX(CASE WHEN num_dias_atraso > 60 THEN 1 ELSE 0 END)
            OVER (PARTITION BY cod_contrato ORDER BY data_base
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS flg_ever60,

        MAX(CASE WHEN num_dias_atraso > 90 THEN 1 ELSE 0 END)
            OVER (PARTITION BY cod_contrato ORDER BY data_base
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS flg_ever90
    FROM Base_Formatada
),

Resumo_Originacao AS (
    SELECT
        safra,
        COUNT(DISTINCT cod_contrato) AS qtd_contratos_safra,
        SUM(vlr_contrato_inicial)    AS vlr_originado_safra,
        AVG(tax_efetiva)             AS taxa_media_safra
    FROM (
        SELECT
            safra,
            cod_contrato,
            vlr_contrato_inicial,
            tax_efetiva,
            ROW_NUMBER() OVER (PARTITION BY cod_contrato ORDER BY data_base) AS rn
        FROM Base_Formatada
    ) sub
    WHERE rn = 1
    GROUP BY safra
),

Agregacao_Aging AS (
    SELECT
        safra,
        mes_seasoning,

        COUNT(cod_contrato)      AS qtd_contratos_ativos,
        SUM(vlr_saldo_ativo)     AS vlr_saldo_ativo_total,

        SUM(flg_over30) AS qtd_over30,
        SUM(flg_over60) AS qtd_over60,
        SUM(flg_over90) AS qtd_over90,

        SUM(CASE WHEN flg_over30 = 1 THEN vlr_saldo_ativo ELSE 0 END) AS vlr_over30,
        SUM(CASE WHEN flg_over60 = 1 THEN vlr_saldo_ativo ELSE 0 END) AS vlr_over60,
        SUM(CASE WHEN flg_over90 = 1 THEN vlr_saldo_ativo ELSE 0 END) AS vlr_over90,

        SUM(flg_ever30) AS qtd_ever30,
        SUM(flg_ever60) AS qtd_ever60,
        SUM(flg_ever90) AS qtd_ever90,

        SUM(CASE WHEN flg_ever30 = 1 THEN vlr_contrato_inicial ELSE 0 END) AS vlr_ever30,
        SUM(CASE WHEN flg_ever60 = 1 THEN vlr_contrato_inicial ELSE 0 END) AS vlr_ever60,
        SUM(CASE WHEN flg_ever90 = 1 THEN vlr_contrato_inicial ELSE 0 END) AS vlr_ever90
    FROM Base_Flags
    GROUP BY safra, mes_seasoning
)

SELECT
    a.safra,
    a.mes_seasoning,
    o.taxa_media_safra,
    o.qtd_contratos_safra,
    o.vlr_originado_safra,
    a.qtd_contratos_ativos,
    a.vlr_saldo_ativo_total,
    a.qtd_over30, a.qtd_over60, a.qtd_over90,
    a.vlr_over30, a.vlr_over60, a.vlr_over90,
    a.qtd_ever30, a.qtd_ever60, a.qtd_ever90,
    a.vlr_ever30, a.vlr_ever60, a.vlr_ever90
FROM Agregacao_Aging a
INNER JOIN Resumo_Originacao o
    ON a.safra = o.safra;


-- f_clientes: perfil de comprometimento de renda na originação -----
CREATE OR REPLACE TABLE f_clientes AS
WITH base_origem AS (
    SELECT
        mes_contratacao,
        dat_base,
        cod_contrato,
        des_modalidade_sintetico,
        des_cliente,
        tax_efetiva,
        vlr_faturamento_cliente,
        vlr_proxima_parcela,
        vlr_contrato_inicial,

        CASE
            WHEN des_cliente = 'PF' THEN vlr_faturamento_cliente
            WHEN des_cliente = 'PJ' THEN vlr_faturamento_cliente / 12.0
            ELSE vlr_faturamento_cliente
        END AS vlr_renda_mensal,

        ROW_NUMBER() OVER (PARTITION BY cod_contrato ORDER BY dat_base) AS rn
    FROM vw_base_tratada
    WHERE mes_contratacao IS NOT NULL
      AND mes_contratacao >= '2022-01-01'
      AND vlr_proxima_parcela != 'inf'
      AND vlr_proxima_parcela > 0
),

historico_contrato AS (
    SELECT
        cod_contrato,
        MAX(over30) AS over30, MAX(over60) AS over60, MAX(over90) AS over90,
        MAX(ever30) AS ever30, MAX(ever60) AS ever60, MAX(ever90) AS ever90
    FROM vw_base_tratada
    WHERE mes_contratacao IS NOT NULL
      AND mes_contratacao >= '2022-01-01'
    GROUP BY cod_contrato
),

base_inicial AS (
    SELECT
        b.mes_contratacao, b.dat_base, b.cod_contrato, b.tax_efetiva,
        b.vlr_faturamento_cliente, b.vlr_renda_mensal, b.vlr_proxima_parcela,
        b.vlr_contrato_inicial,
        h.over30, h.over60, h.over90, h.ever30, h.ever60, h.ever90
    FROM base_origem b
    LEFT JOIN historico_contrato h ON b.cod_contrato = h.cod_contrato
    WHERE b.rn = 1
      AND DATE_TRUNC('month', b.dat_base) = DATE_TRUNC('month', b.mes_contratacao)
),

base_filtrada AS (
    SELECT
        *,
        ROUND((vlr_proxima_parcela / NULLIF(vlr_renda_mensal, 0)) * 100, 2) AS pct_comprometimento_renda
    FROM base_inicial
    WHERE vlr_renda_mensal > 500
),

base_tratada AS (
    SELECT
        mes_contratacao, cod_contrato, tax_efetiva, vlr_faturamento_cliente,
        vlr_renda_mensal, vlr_proxima_parcela, vlr_contrato_inicial,
        pct_comprometimento_renda, over30, over60, over90, ever30, ever60, ever90,

        CASE
            WHEN pct_comprometimento_renda < 30 THEN '0-30%'
            WHEN pct_comprometimento_renda < 50 THEN '30-50%'
            ELSE '+50%'
        END AS faixa_comprometimento,

        CASE
            WHEN pct_comprometimento_renda < 30 THEN 1
            WHEN pct_comprometimento_renda < 50 THEN 2
            ELSE 3
        END AS ordem_faixa_comprometimento
    FROM base_filtrada
    WHERE pct_comprometimento_renda <= 200
)

SELECT
    mes_contratacao,
    faixa_comprometimento,
    ordem_faixa_comprometimento,

    COUNT(*)                    AS qtd_contratos,
    SUM(vlr_contrato_inicial)   AS vlr_concedido,
    AVG(vlr_contrato_inicial)   AS ticket_medio,
    AVG(tax_efetiva)            AS taxa_media,
    AVG(vlr_proxima_parcela)    AS parcela_media,
    AVG(vlr_renda_mensal)       AS renda_media_mensal,
    AVG(pct_comprometimento_renda) AS pct_comprometimento_medio,

    SUM(over30) AS qtd_over30, SUM(over60) AS qtd_over60, SUM(over90) AS qtd_over90,
    SUM(ever30) AS qtd_ever30, SUM(ever60) AS qtd_ever60, SUM(ever90) AS qtd_ever90,

    SUM(over30) * 1.0 / COUNT(*) AS pct_over30,
    SUM(over60) * 1.0 / COUNT(*) AS pct_over60,
    SUM(over90) * 1.0 / COUNT(*) AS pct_over90,
    SUM(ever30) * 1.0 / COUNT(*) AS pct_ever30,
    SUM(ever60) * 1.0 / COUNT(*) AS pct_ever60,
    SUM(ever90) * 1.0 / COUNT(*) AS pct_ever90
FROM base_tratada
GROUP BY ALL
ORDER BY mes_contratacao, ordem_faixa_comprometimento;
