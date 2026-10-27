# 📊 Risco de Crédito: do Credit Approval Analytics à Política de Cutoff

> **Pergunta de negócio:** como reduzir a inadimplência sem derrubar a taxa de aprovação? **Qual é o melhor ponto de corte (cutoff) de score?**

Este projeto evolui o *Credit Approval Analytics* (análise descritiva da aprovação de crédito) para um fluxo completo de **risco de crédito**: modelo de probabilidade de inadimplência (PD), avaliação de performance e estabilidade, e **tradução do score em política de crédito com impacto financeiro em R$**.

O modelo não é o centro. O centro é o **trade-off aprovação × perda**.

---

## 🧭 Visão geral da solução

```
Dados (Kaggle) → SQL (extração + features) → EDA → Baseline (Reg. Logística)
      → XGBoost → Avaliação (AUC/Gini/KS/PSI) → SHAP → Simulação de cutoff (R$)
      → Power BI (política de crédito)
```

| Etapa | O que responde |
|---|---|
| EDA | Quem são os inadimplentes? Há variáveis com vazamento ou inconsistência? |
| Baseline | Quanto uma regressão logística simples já separa bons e maus pagadores? |
| XGBoost | O ganho de performance compensa a perda de interpretabilidade? |
| Métricas | O modelo separa bem (KS, Gini) e é estável no tempo (PSI)? |
| SHAP | Quais variáveis explicam o risco, em nível global e individual? |
| Simulação | Para cada cutoff: aprovação, inadimplência, perda e lucro esperado em R$ |
| Power BI | Qual cutoff recomendar e quais faixas de score usar na política? |

---

## 🛠️ Stack

- **SQL (PostgreSQL):** extração, definição da variável-alvo e engenharia de features
- **Python:** pandas, scikit-learn, XGBoost, SHAP, matplotlib
- **Power BI:** dashboard de política de crédito e simulador de cutoff
- **Git & GitHub**

**Dados:** [Give Me Some Credit](https://www.kaggle.com/c/GiveMeSomeCredit) *(ou Home Credit Default Risk)*, dados públicos do Kaggle. Os dados fictícios do projeto anterior ficam em `data/legacy/` como fase de análise descritiva.

---

## 📐 Metodologia

### 1. Definição do alvo e da amostra
- Variável-alvo: inadimplência (`default = 1`) conforme definição do dataset
- Separação em treino / teste (e, quando houver coluna temporal, validação *out-of-time*)
- Tratamento de nulos, outliers e checagem de vazamento de informação (*data leakage*)

### 2. Features (SQL + Python)
- Utilização de crédito, endividamento, atrasos históricos, renda, idade, relacionamento
- Features criadas em SQL (`sql/features.sql`) e consumidas pelo notebook de modelagem

### 3. Modelos
- **Baseline:** regressão logística (com padronização e, opcionalmente, WoE/binning)
- **Challenger:** XGBoost com ajuste de hiperparâmetros e tratamento de desbalanceamento

### 4. Métricas de risco
| Métrica | Para que serve |
|---|---|
| **AUC / Gini** (`Gini = 2·AUC − 1`) | Poder de ordenação do score |
| **KS** | Máxima separação entre bons e maus pagadores |
| **PSI** | Estabilidade da distribuição do score entre treino e teste (ou safras) |
| **Calibração** | O score reflete a PD real? |

### 5. Explicabilidade
- **SHAP** global (importância) e local (por que um cliente específico foi negado)

### 6. Decisão: simulação de cutoff em R$
Para cada cutoff `c`, aprova-se quem tem `PD < c`:

```
Aprovados(c)        = nº de clientes com PD < c
Taxa de aprovação   = Aprovados / Total
Inadimplência(c)    = maus pagadores entre os aprovados / Aprovados
Perda esperada (R$) = Σ (PD × EAD × LGD)
Receita (R$)        = Σ (bons pagadores × ticket × margem)
Resultado (R$)      = Receita − Perda esperada
```

**Premissas (parametrizáveis):** ticket médio, LGD, margem financeira, custo de aquisição. Todas ficam em `config/premissas.yaml` e podem ser ajustadas no Power BI.

O cutoff recomendado é o que **maximiza o resultado financeiro respeitando uma taxa mínima de aprovação** definida pelo negócio.

---

## 📊 Resultados

## 📊 Resultados da análise exploratória

A análise exploratória foi realizada sobre uma base com **672 registros**, com o objetivo de compreender o perfil dos clientes e identificar características associadas à aprovação de crédito.

### Distribuição das decisões

| Indicador | Resultado |
|---|---:|
| Total de registros | 672 |
| Taxa de aprovação | 44,05% |
| Taxa de não aprovação | 55,95% |

### Perfil dos clientes por decisão

| Indicador | Não aprovados (0) | Aprovados (1) |
|---|---:|---:|
| Renda média | 200,42 | 2.058,40 |
| Dívida média | 3,75 | 5,69 |
| Pontuação de crédito média | 0,63 | 4,61 |

### Relação com a inadimplência anterior

A média da variável `aprovado` por grupo de inadimplência anterior apresentou os seguintes resultados:

| Inadimplência anterior | Média de aprovação |
|---|---:|
| 0 | 6,79% |
| 1 | 78,74% |

**Observação:** é necessário validar a codificação dessa variável e a consistência dos dados antes de interpretar esse resultado como uma relação entre inadimplência anterior e aprovação.

### Avaliação dos modelos

| Modelo | AUC | Gini | KS | PSI |
|---|---:|---:|---:|---:|
| Regressão Logística (baseline) | Pendente | Pendente | Pendente | Pendente |
| XGBoost | Pendente | Pendente | Pendente | Pendente |

**Cutoff recomendado:** Pendente  
**Taxa de aprovação no cutoff:** Pendente  
**Taxa de inadimplência no cutoff:** Pendente  
**Resultado financeiro estimado:** Pendente

As métricas de desempenho dos modelos, a definição do cutoff e a estimativa financeira deverão ser preenchidas após o treinamento, a validação e a simulação das decisões de crédito.


---

## 📈 Dashboard de política de crédito (Power BI)

- Taxa de aprovação × inadimplência por cutoff
- Resultado financeiro (R$) por cutoff e ponto ótimo
- Distribuição por faixa de score (*rating*) com inadimplência observada
- Principais drivers de risco (SHAP)
- Parâmetros de simulação ajustáveis (LGD, margem, ticket)

<!-- inserir print do dashboard -->

---

## 📁 Estrutura do projeto

```
credit-risk-cutoff/
├── config/
│   └── premissas.yaml
├── data/
│   ├── raw/
│   ├── processed/
│   └── legacy/              # projeto anterior (Credit Approval Analytics)
├── sql/
│   ├── 01_extracao.sql
│   └── 02_features.sql
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_baseline_logistica.ipynb
│   ├── 03_xgboost.ipynb
│   ├── 04_metricas_ks_gini_psi.ipynb
│   ├── 05_shap.ipynb
│   └── 06_simulacao_cutoff.ipynb
├── src/                      # funções reutilizáveis (KS, PSI, simulação)
├── dashboard/
└── README.md
```

---

## 💡 Principais aprendizados

- *(ex.: o ganho do XGBoost sobre a regressão logística foi de X pontos de Gini; vale a complexidade?)*
- *(ex.: cutoff ótimo em R$ difere do cutoff que maximiza KS, e por quê)*
- *(ex.: variáveis com maior contribuição SHAP e o que isso significa para a política)*

---

## ⚠️ Limitações

- Dados públicos de outro contexto; premissas financeiras (LGD, margem, ticket) são hipóteses
- Sem *reject inference*: só observamos inadimplência de quem foi aprovado
- Em produção seria necessário monitorar PSI e performance por safra

---

## 🔗 Autor

Desenvolvido por **Manuel**
