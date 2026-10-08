# 🛒 TechStore Analytics

Projeto de análise de dados de ponta a ponta sobre o e-commerce brasileiro **Olist**: do dado bruto até um dashboard de KPIs de vendas, logística, clientes e produtos.

```
CSVs brutos ──► Limpeza (Python/pandas) ──► Banco (Supabase/PostgreSQL) ──► Dashboard (Power BI)
     ✅                  ✅                           🔜                           🔜
```

## 🎯 Objetivo

Responder perguntas de negócio do e-commerce e entregar um dashboard com os principais KPIs:

| Área | Perguntas |
|---|---|
| 📊 Comercial | Qual categoria e qual produto vendem mais? Quais estados compram mais? |
| 💰 Financeiro | Receita total, ticket médio, frete médio e forma de pagamento mais usada |
| 🚚 Logística | Tempo médio de entrega, pedidos atrasados e estados com maior atraso |
| 👥 Clientes | Clientes únicos, clientes recorrentes e distribuição por estado |
| 📦 Produtos | Categorias e produtos mais vendidos |

Lista completa em [`docs/business_questions.md`](docs/business_questions.md) e [`docs/kpis.md`](docs/kpis.md).

## 📦 Dados

Dataset público **Brazilian E-Commerce Public Dataset by Olist** ([Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)): cerca de 100 mil pedidos entre setembro de 2016 e outubro de 2018, distribuídos em 9 tabelas.

| Tabela | Linhas (bruto) | Conteúdo |
|---|---:|---|
| `orders` | 99.441 | Pedidos, status e datas |
| `order_items` | 112.650 | Itens, preço e frete |
| `order_payments` | 103.886 | Formas de pagamento e parcelas |
| `order_reviews` | 99.224 | Avaliações dos clientes |
| `customers` | 99.441 | Clientes e localização |
| `sellers` | 3.095 | Vendedores e localização |
| `products` | 32.951 | Produtos, categoria e medidas |
| `geolocation` | 1.000.163 | Coordenadas por prefixo de CEP |
| `product_category_name_translation` | 71 | Categorias em português e inglês |

Dicionário completo e relacionamentos em [`docs/data_dictionary.md`](docs/data_dictionary.md).

## ✅ Situação do projeto

| Etapa | Status |
|---|---|
| Documentação de negócio (dicionário, KPIs, perguntas) | ✅ Concluído |
| Profiling e limpeza dos 9 datasets | ✅ Concluído |
| Schema e chaves estrangeiras do banco | 🟡 Criados, com ajustes pendentes |
| Carga no Supabase | 🔜 Próxima etapa |
| Índices e views dos KPIs | 🔜 Pendente |
| Análises das perguntas de negócio | 🔜 Pendente |
| Dashboard no Power BI | 🔜 Pendente |

## 🧹 Limpeza de dados

Cada dataset tem um notebook que faz o profiling, trata os problemas, valida o resultado e salva o arquivo limpo em `data/processed/`. Os dados brutos nunca são alterados e nenhum pedido é descartado.

| Notebook | Dataset | Principais tratamentos |
|---|---|---|
| [`01`](notebooks/01_products_profiling.ipynb) | products | 610 produtos sem categoria → `Unknown`; demais nulos pela mediana |
| [`02`](notebooks/02_order_items_profiling.ipynb) | order_items | `shipping_limit_date` convertida para data |
| [`03`](notebooks/03_orders_profiling.ipynb) | orders | Datas convertidas; 189 datas de envio incoerentes e 6 entregas de pedidos cancelados anuladas |
| [`04`](notebooks/04_customers_profiling.ipynb) | customers | Dados já consistentes; CEP preservado como texto |
| [`05`](notebooks/05_sellers_profiling.ipynb) | sellers | 18 cidades sujas corrigidas pela geolocalização do CEP |
| [`06`](notebooks/06_order_payments_profiling.ipynb) | order_payments | Parcelas 0 → 1; total pago confere com itens + frete em 99,61% dos pedidos |
| [`07`](notebooks/07_order_reviews_profiling.ipynb) | order_reviews | Datas convertidas; comentários normalizados |
| [`08`](notebooks/08_geolocation_profiling.ipynb) | geolocation | 1.000.163 → 720.461 linhas (duplicatas e coordenadas inválidas removidas); tabela por CEP |
| [`09`](notebooks/09_category_translation_profiling.ipynb) | category_translation | 3 categorias sem tradução adicionadas |

Decisões, validações e pontos de atenção em [`docs/data_cleaning.md`](docs/data_cleaning.md).

## 🗂️ Estrutura do projeto

```
TechStore Analytics/
├── data/
│   ├── raw/            # 9 CSVs originais (não alterados)
│   └── processed/      # CSVs tratados (*_clean.csv)
├── notebooks/          # 01 a 09: profiling e limpeza, um por dataset
├── database/           # schema.sql, constraints.sql, indexes.sql, views.sql
├── docs/
│   ├── data_dictionary.md    # tabelas, colunas e relacionamentos
│   ├── data_cleaning.md      # o que foi feito na limpeza e por quê
│   ├── business_questions.md # perguntas de negócio
│   └── kpis.md               # KPIs do dashboard
├── requirements.txt
└── README.md
```

## 🚀 Como executar

Requisitos: Python 3.12.

```bash
# 1. Criar e ativar o ambiente virtual (Windows)
python -m venv .venv
.venv\Scripts\activate

# 2. Instalar as dependências
pip install -r requirements.txt

# 3. Abrir os notebooks
jupyter lab
```

Execute os notebooks da pasta `notebooks/` na ordem numérica. O `01` precisa rodar antes do `02` e do `09`, que usam `olist_products_dataset_clean.csv`.

> ⚠️ **CEP deve ser lido como texto.** Com o tipo padrão do pandas ele vira inteiro e perde o zero à esquerda (`01046` → `1046`).
> Use `pd.read_csv(..., dtype={"customer_zip_code_prefix": str})` (o mesmo vale para `seller_zip_code_prefix` e `geolocation_zip_code_prefix`).

## 🛠️ Tecnologias

- **Python** (pandas) e **Jupyter** para profiling e limpeza
- **PostgreSQL / Supabase** para o banco de dados
- **Power BI** para o dashboard

## 🔜 Próximos passos

1. Definir as regras dos KPIs: filtro de status dos pedidos e janela de tempo (sugestão: 2017-01 a 2018-08).
2. Ajustar o schema do banco (chave de `order_reviews`, tipos inteiros de `products` e tabela de geolocalização por CEP).
3. Carregar os dados tratados no Supabase.
4. Criar índices e views com os KPIs.
5. Construir o dashboard no Power BI e documentar os insights.

## 📄 Fonte dos dados

Olist, *Brazilian E-Commerce Public Dataset by Olist*, disponível no Kaggle. Os dados são anonimizados e públicos.
