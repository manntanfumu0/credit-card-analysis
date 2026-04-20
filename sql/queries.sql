-- =========================================
-- PROJETO: Análise de Aprovação de Crédito
-- OBJETIVO: Entender fatores que influenciam aprovação
-- =========================================


-- =========================================
-- 1. VISÃO GERAL
-- =========================================
-- Taxa de aprovação geral
SELECT 
    aprovado,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentual
FROM dados_limpos
GROUP BY aprovado;


-- =========================================
-- 2. ANÁLISE DE RENDA
-- =========================================
-- Renda média por status de aprovação
SELECT 
    aprovado,
    ROUND(AVG(renda), 2) AS renda_media
FROM dados_limpos
GROUP BY aprovado;

-- =========================================
-- 3. ANÁLISE DE DÍVIDA
-- =========================================

-- Dívida média por status de aprovação
SELECT 
    aprovado,
    ROUND(AVG(divida), 2) AS divida_media
FROM dados_limpos
GROUP BY aprovado;

-- =========================================
-- 4. RISCO E INADIMPLÊNCIA
-- =========================================

-- Taxa de aprovação por histórico de inadimplência
SELECT 
    inadimplencia_anterior,
    ROUND(AVG(aprovado) * 100, 2) AS taxa_aprovacao
FROM dados_limpos
GROUP BY inadimplencia_anterior;


-- =========================================
-- 5. SCORE DE CRÉDITO
-- =========================================
-- Score médio por aprovação
SELECT 
    aprovado,
    ROUND(AVG(pontuacao_de_credito), 2) AS score_medio
FROM dados_limpos
GROUP BY aprovado;


-- =========================================
-- 6. PERFIS
-- =========================================
SELECT 
    idade,
    renda,
    divida,
    pontuacao_de_credito
FROM dados_limpos
WHERE aprovado = 0
ORDER BY renda ASC
LIMIT 10;



SELECT 
    AVG(idade) AS idade_media,
    AVG(renda) AS renda_media,
    AVG(pontuacao_de_credito) AS score_medio
FROM dados_limpos
WHERE aprovado = 1;


-- Ranking de clientes por score
SELECT 
    *,
    RANK() OVER (ORDER BY pontuacao_de_credito DESC) AS ranking_score
FROM dados_limpos;