-- ============================================================
-- 01_staging.sql
-- Renomeia as colunas da base bruta do Doc3040 para nomes legíveis
-- Fonte: Doc3040_resumido.csv
-- ============================================================

CREATE OR REPLACE TABLE fat_base_3040 AS
SELECT
    base.DtBase          AS dat_base,
    base.Tp               AS tipo_cliente,
    base.Autorzc          AS cod_autorizacao,
    base.FatAnual          AS vlr_faturamento_cliente,
    base.Contrt           AS cod_contrato,
    base.Mod               AS cod_modalidade,
    base.TaxEft            AS tax_efetiva,
    base.DtContr           AS dat_contratacao,
    base.VlrContr          AS vlr_contrato,
    base.ClassOp           AS cod_risco_operacao,
    base.ProvConsttd       AS prov_constituida,
    base.DiaAtraso         AS num_dias_atraso,
    base.VlrProxParcela    AS vlr_proxima_parcela,
    base.QtdParcelas       AS num_qtd_parcelas,
    base.SaldoAtivo        AS vlr_saldo_ativo,
    base.SaldoPerda        AS vlr_saldo_perda
FROM Doc3040_resumido base;
