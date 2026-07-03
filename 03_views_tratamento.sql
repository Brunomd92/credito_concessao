-- ============================================================
-- 03_views_tratamento.sql
-- Camadas de tratamento, cada view parte da anterior.
-- Ordem: enriquecida -> atraso -> risco -> financeira -> tratada
-- ============================================================

-- 1. Enriquecida: junta a base com as dimensões -------------------
CREATE OR REPLACE VIEW vw_base_enriquecida AS
SELECT
    base.dat_base,
    base.dat_contratacao,
    last_day(base.dat_contratacao)     AS mes_contratacao,
    base.tipo_cliente,
    cli.des_cliente,
    base.cod_autorizacao,
    base.vlr_faturamento_cliente,
    base.cod_contrato,
    base.cod_modalidade,
    mod.des_modalidade,
    mods.des_modalidade_sintetico,
    base.tax_efetiva,
    base.vlr_contrato,
    base.cod_risco_operacao,
    ris.descricao,
    ris.nivel_risco,
    base.prov_constituida,
    base.num_dias_atraso,
    base.vlr_proxima_parcela,
    base.num_qtd_parcelas,
    base.vlr_saldo_ativo,
    base.vlr_saldo_perda
FROM fat_base_3040 base
LEFT JOIN dim_tipo_cliente cli
    ON base.tipo_cliente = cli.cod_cliente
LEFT JOIN dim_classificacao_risco ris
    ON base.cod_risco_operacao = ris.classop
LEFT JOIN dim_modalidade mod
    ON base.cod_modalidade = mod.cod_modalidade
LEFT JOIN dim_modalidade_sintetico mods
    ON base.cod_modalidade = mods.cod_modalidade;


-- 2. Atraso: calcula flags over/ever de inadimplência --------------
CREATE OR REPLACE VIEW vw_base_atraso AS
WITH base_calc AS (
    SELECT
        *,
        MAX(num_dias_atraso) OVER (
            PARTITION BY cod_contrato
            ORDER BY dat_base
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS max_dias_atraso_acumulado,

        FIRST_VALUE(vlr_contrato) OVER (
            PARTITION BY cod_contrato
            ORDER BY dat_base
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS vlr_contrato_inicial
    FROM vw_base_enriquecida
)
SELECT
    *,
    max_dias_atraso_acumulado AS max_dias_atraso,

    CASE WHEN num_dias_atraso > 30 THEN 1 ELSE 0 END AS over30,
    CASE WHEN num_dias_atraso > 60 THEN 1 ELSE 0 END AS over60,
    CASE WHEN num_dias_atraso > 90 THEN 1 ELSE 0 END AS over90,

    CASE WHEN max_dias_atraso_acumulado > 30 THEN 1 ELSE 0 END AS ever30,
    CASE WHEN max_dias_atraso_acumulado > 60 THEN 1 ELSE 0 END AS ever60,
    CASE WHEN max_dias_atraso_acumulado > 90 THEN 1 ELSE 0 END AS ever90,

    CASE WHEN num_dias_atraso > 30 THEN vlr_saldo_ativo ELSE 0 END AS vlr_over30,
    CASE WHEN num_dias_atraso > 60 THEN vlr_saldo_ativo ELSE 0 END AS vlr_over60,
    CASE WHEN num_dias_atraso > 90 THEN vlr_saldo_ativo ELSE 0 END AS vlr_over90,

    CASE WHEN max_dias_atraso_acumulado > 30 THEN vlr_saldo_ativo ELSE 0 END AS vlr_ever30_saldo,
    CASE WHEN max_dias_atraso_acumulado > 60 THEN vlr_saldo_ativo ELSE 0 END AS vlr_ever60_saldo,
    CASE WHEN max_dias_atraso_acumulado > 90 THEN vlr_saldo_ativo ELSE 0 END AS vlr_ever90_saldo,

    CASE WHEN max_dias_atraso_acumulado > 30 THEN vlr_contrato_inicial ELSE 0 END AS vlr_ever30_originado,
    CASE WHEN max_dias_atraso_acumulado > 60 THEN vlr_contrato_inicial ELSE 0 END AS vlr_ever60_originado,
    CASE WHEN max_dias_atraso_acumulado > 90 THEN vlr_contrato_inicial ELSE 0 END AS vlr_ever90_originado
FROM base_calc;


-- 3. Risco: camada de passagem, isolada para futuras regras -------
CREATE OR REPLACE VIEW vw_base_risco AS
SELECT *
FROM vw_base_atraso;


-- 4. Financeira: idade da operação e comprometimento de renda -----
CREATE OR REPLACE VIEW vw_base_financeira AS
SELECT
    *,
    datediff('month', dat_contratacao, dat_base) AS idade_operacao_meses,

    CASE
        WHEN tipo_cliente = 1
         AND vlr_faturamento_cliente > 0.01
        THEN vlr_proxima_parcela / vlr_faturamento_cliente
    END AS pct_comprometimento_pf,

    CASE
        WHEN tipo_cliente = 2
         AND vlr_faturamento_cliente > 0.01
        THEN vlr_proxima_parcela / (vlr_faturamento_cliente / 12.0)
    END AS pct_comprometimento_pj
FROM vw_base_risco;


-- 5. Tratada: base final, fonte única para as tabelas fato --------
CREATE OR REPLACE VIEW vw_base_tratada AS
SELECT *
FROM vw_base_financeira;
