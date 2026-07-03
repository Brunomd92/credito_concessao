-- ============================================================
-- 02_dimensoes.sql
-- Tabelas de apoio criadas manualmente a partir do leiaute oficial
-- do Bacen (SCR3040_Leiaute.xls) e dos valores distintos encontrados
-- na base.
-- ============================================================

-- Tipo de cliente ------------------------------------------------
CREATE OR REPLACE TABLE dim_tipo_cliente (
    cod_cliente INTEGER,
    des_cliente VARCHAR
);

INSERT INTO dim_tipo_cliente VALUES
    (1, 'PF'),
    (2, 'PJ');


-- Classificação de risco (Resolução CMN 2.682) -------------------
CREATE OR REPLACE TABLE dim_classificacao_risco (
    classop         VARCHAR,
    descricao       VARCHAR,
    nivel_risco     VARCHAR,
    atraso_dias     VARCHAR,
    categoria_macro VARCHAR,
    pct_provisao    DECIMAL(5,4)
);

INSERT INTO dim_classificacao_risco VALUES
    ('AA', 'Classificação de risco AA',        'Minimo',          '0',     'Baixo Risco',     0.00),
    ('A',  'Classificação de risco A',          'Baixo',           '1-14',  'Baixo Risco',     0.005),
    ('B',  'Classificação de risco B',          'Moderado Baixo',  '15-30', 'Baixo Risco',     0.01),
    ('C',  'Classificação de risco C',          'Moderado',        '31-60', 'Risco Moderado',  0.03),
    ('D',  'Classificação de risco D',          'Substancial',     '61-90', 'Risco Moderado',  0.10),
    ('E',  'Classificação de risco E',          'Elevado',         '91-120','Risco Crítico',   0.30),
    ('F',  'Classificação de risco F',          'Muito Alto',      '121-150','Risco Crítico',  0.50),
    ('G',  'Classificação de risco G',          'Extremo',         '151-180','Risco Crítico',  0.70),
    ('H',  'Classificação de risco H',          'Inadimplencia',   '> 180', 'Default/Perda',   1.00),
    ('HH', 'Créditos baixados como prejuízo',   'Prejuizo',        'Baixado','Default/Perda',  1.00),
    ('01', 'Default para Fundos Administrados', 'Default Técnico', 'N/A',   'Default/Perda',   1.00);


-- Modalidade de crédito -------------------------------------------
CREATE OR REPLACE TABLE dim_modalidade (
    cod_modalidade INTEGER,
    des_modalidade VARCHAR
);

INSERT INTO dim_modalidade VALUES
    (801, 'Credito Rural - Custeio'),
    (802, 'Credito Rural - Investimento'),
    (202, 'Credito Consignado'),
    (203, 'Credito pessoal'),
    (215, 'Capital de giro');


-- Modalidade sintética (agrupamento para relatórios executivos) ---
CREATE OR REPLACE TABLE dim_modalidade_sintetico (
    cod_modalidade            INTEGER,
    des_modalidade_sintetico  VARCHAR
);

INSERT INTO dim_modalidade_sintetico VALUES
    (801, 'Credito Rural'),
    (802, 'Credito Rural'),
    (202, 'Credito Consignado'),
    (203, 'Credito pessoal'),
    (215, 'Capital de giro');
