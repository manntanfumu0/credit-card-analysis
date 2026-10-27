# 📊 Credit Approval Analytics à Política de Cutoff

> **Pergunta de negócio:** como reduzir a inadimplência sem derrubar a taxa de aprovação? **Qual é o melhor ponto de corte (cutoff) de score?**

Este projeto evolui o *Credit Approval Analytics* em duas fases:

| Fase | O que é | Base de dados | Status |
|---|---|---|---|
| **1. Análise descritiva** | EDA, SQL e dashboard sobre a aprovação de crédito | Base fictícia (672 registros) | ✅ Concluída |
| **2. Risco com modelagem** | Modelo de PD, métricas de risco, simulação de cutoff em R$ e política de crédito | *Give Me Some Credit* (Kaggle) | 🚧 Em andamento |

O modelo não é o centro. O centro é o **trade-off aprovação × perda** e a tradução do score em **política de crédito**.

---

## 🧭 Fase 2: visão geral da solução

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
| Métricas | O modelo separa bem (KS, Gini) e é estável (PSI)? A PD é calibrada? |
| SHAP | Quais variáveis explicam o risco, em nível global e individual? |
| Simulação | Para cada cutoff: aprovação, inadimplência, perda e resultado em R$ |
| Power BI | Qual cutoff recomendar e quais faixas de score usar na política? |

---

## 🛠️ Stack

- **SQL (PostgreSQL):** carga, limpeza e engenharia de features
- **Python:** pandas, scikit-learn, XGBoost, SHAP, matplotlib
- **Power BI:** dashboard de política de crédito
- **Git & GitHub**

**Dados da Fase 2:** [Give Me Some Credit](https://www.kaggle.com/c/GiveMeSomeCredit) (150 mil clientes, alvo `SeriousDlqin2yrs` = inadimplência em 2 anos). O arquivo `cs-training.csv` não é versionado; baixe do Kaggle e coloque em `data/raw/`.

---

## 📐 Metodologia (Fase 2)

### 1. Alvo e amostra
- Variável-alvo: `default` (1 = inadimplente em 2 anos)
- Split estratificado 70/30 (a base não tem coluna temporal, então não há validação *out-of-time*)
- Tratamentos: idade < 18, códigos especiais 96/98 nos atrasos, utilização de crédito e `DebtRatio` com valores extremos, renda nula (~20%)

### 2. Features (SQL + Python)
- Utilização de crédito, endividamento, atrasos (30-59, 60-89, 90+), renda, idade, dependentes
- Criadas: `total_late`, `income_missing`, `log_income`
- Em SQL (`sql/02_features.sql`) e espelhadas em Python (`src/data.py`) para rodar sem banco

### 3. Modelos
- **Baseline:** regressão logística (imputação pela mediana + padronização)
- **Challenger:** XGBoost com *early stopping*. Não reponderei as classes de propósito: isso distorceria a calibração da PD, e a simulação em R$ precisa de PD calibrada

### 4. Métricas de risco
| Métrica | Para que serve |
|---|---|
| **AUC / Gini** (`Gini = 2·AUC − 1`) | Poder de ordenação do score |
| **KS** | Máxima separação entre bons e maus pagadores |
| **PSI** | Estabilidade da distribuição do score (treino → teste) |
| **Calibração** | A PD prevista reflete a inadimplência observada? |

### 5. Explicabilidade
- **SHAP** global (importância das variáveis) e local (por que um cliente específico tem PD alta)

### 6. Decisão: simulação de cutoff em R$
Política: aprovar quem tem `PD < cutoff`. Para cada cutoff, no conjunto de teste:

```
Taxa de aprovação   = aprovados / total
Inadimplência(c)    = maus entre os aprovados / aprovados
Receita (R$)        = bons aprovados × ticket × margem
Perda realizada (R$)= maus aprovados × ticket × LGD
Resultado (R$)      = Receita − Perda realizada
```

A perda esperada pela PD do modelo (`Σ PD × ticket × LGD`) também é calculada, para conferir a calibração.

**Premissas (hipóteses, em `config/premissas.yaml`):** ticket médio R$ 5.000, margem 15%, LGD 80%, aprovação mínima de 60%. O dataset público não traz valor de contrato, juros nem recuperação, então esses números são didáticos e podem ser alterados.

O cutoff recomendado é o que **maximiza o resultado respeitando a taxa mínima de aprovação** definida pelo negócio.

---

## 📊 Resultados da Fase 2

> ⚠️ **Pendente.** Preencher somente com números reais após rodar os notebooks na base *Give Me Some Credit*.

| Modelo | AUC | Gini | KS | PSI |
|---|---:|---:|---:|---:|
| Regressão Logística (baseline) | – | – | – | – |
| XGBoost | – | – | – | – |

| Indicador | Valor |
|---|---:|
| Cutoff recomendado | – |
| Taxa de aprovação no cutoff | – |
| Inadimplência no cutoff | – |
| Resultado financeiro estimado (R$) | – |
| Referência: aprovar todos (R$) | – |

*Gráficos a incluir: curva ROC e KS, calibração, SHAP summary, fronteira aprovação × inadimplência e resultado (R$) por cutoff.*

---

## 📈 Dashboard de política de crédito (Power BI)

A construir a partir de `data/processed/simulacao_cutoff_*.csv`:

- Taxa de aprovação × inadimplência por cutoff
- Resultado financeiro (R$) por cutoff e ponto ótimo
- Inadimplência observada por faixa de score
- Principais drivers de risco (SHAP)
- Parâmetros ajustáveis (LGD, margem, ticket)

<!-- inserir print do dashboard -->

---

## 🗂️ Fase 1: Análise descritiva da aprovação (base fictícia)

Objetivo: identificar os fatores associados à aprovação de crédito em uma base fictícia de **672 registros**.

### Pipeline
1. Ingestão de dados (CSV)
2. Limpeza e tratamento com Python
3. Análise exploratória (EDA)
4. Consultas SQL (PostgreSQL)
5. Dashboard no Power BI

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

### Inadimplência anterior × aprovação

| Inadimplência anterior | Média de aprovação |
|---|---:|
| 0 | 6,79% |
| 1 | 78,74% |

### Dashboard da Fase 1

<img width="1568" height="860" alt="Dashboard Fase 1" src="https://github.com/user-attachments/assets/93d8375d-c446-4696-a15e-048e9431e928" />

### Achados de qualidade de dados (motivo da Fase 2)

- **Relação invertida:** clientes com inadimplência anterior = 1 têm aprovação **maior** (78,7%) que os com 0 (6,8%). Isso contraria a lógica de crédito e sugere codificação invertida ou falha na simulação dos dados.
- **Escalas suspeitas:** renda média de 200,42 contra 2.058,40 e score de 0,63 contra 4,61 indicam variáveis sem escala ou unidade documentada.
- **Alvo inadequado para risco:** `aprovado` é uma decisão passada, não um desfecho. Um modelo treinado nele apenas reproduz a regra de quem decidiu, e não mede risco.
- **Amostra pequena:** 672 linhas são insuficientes para KS e PSI confiáveis e para comparar modelos.

Por isso a Fase 2 usa uma base pública com **inadimplência observada** (*Give Me Some Credit*). A base fictícia fica em `data/legacy/` como registro da Fase 1.

---

## 📁 Estrutura do projeto

```
credit-risk-cutoff/
├── config/
│   └── premissas.yaml            # ticket, margem, LGD, aprovação mínima
├── data/
│   ├── raw/                      # cs-training.csv (Kaggle, não versionado)
│   ├── processed/                # treino/teste, scores, simulações (para o Power BI)
│   └── legacy/                   # base fictícia da Fase 1
├── sql/
│   ├── 01_extracao.sql           # carga e limpeza
│   └── 02_features.sql           # features e visões analíticas
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_baseline_logistica.ipynb
│   ├── 03_xgboost.ipynb
│   ├── 04_metricas_ks_gini_psi.ipynb
│   ├── 05_shap.ipynb
│   └── 06_simulacao_cutoff.ipynb
├── src/
│   ├── data.py                   # carga, limpeza, features
│   ├── modeling.py               # regressão logística e XGBoost
│   └── risk_metrics.py           # AUC, Gini, KS, PSI, simulação de cutoff
├── dashboard/                    # arquivo .pbix e prints
├── requirements.txt
└── README.md
```

---

## ▶️ Como executar

```bash
pip install -r requirements.txt
# 1. baixe cs-training.csv do Kaggle e coloque em data/raw/
# 2. execute os notebooks na ordem 01 → 06 (cada um usa o resultado do anterior)
jupyter notebook notebooks/
```

Opcional: para usar o PostgreSQL, rode `sql/01_extracao.sql` e `sql/02_features.sql` (a carga usa `\copy` no `psql`).

---

## 💡 Principais aprendizados

*(Preencher após a Fase 2.)*

- Ganho do XGBoost sobre a regressão logística em Gini, e se compensa a perda de interpretabilidade
- Diferença entre o cutoff que maximiza o KS e o que maximiza o resultado em R$, e por quê
- Variáveis de maior contribuição SHAP e o que isso significa para a política de crédito

---

## ⚠️ Limitações

- Dados públicos de outro contexto; ticket, margem e LGD são hipóteses, não dados reais
- Sem *reject inference*: só observamos a inadimplência de quem foi aprovado
- Sem coluna temporal: o PSI compara treino × teste, não safras. Em produção seria preciso monitorar PSI e performance por safra

---

## 🔗 Autor

Desenvolvido por **Manuel**
