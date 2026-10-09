# 🛒 TechStore Analytics

Projeto de análise de dados de ponta a ponta sobre o e-commerce brasileiro **Olist**: do dado bruto até um dashboard de KPIs de vendas, logística, clientes e produtos.

```
CSVs brutos ──► Limpeza (Python/pandas) ──► CSVs tratados ──► Dashboard (Power BI)
     ✅                  ✅                       ✅                  ✅
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
| Design do dashboard (estilo e modelo das 2 páginas) | ✅ Concluído |
| Projeto Power BI (modelo, relacionamentos, tema e 29 medidas DAX) | ✅ Concluído |
| Dashboard de 2 páginas | ✅ Concluído |
| Validação (QA): números do painel x recálculo independente em SQL | ✅ 38 de 38 valores conferem (veja [`docs/qa_signoff.md`](docs/qa_signoff.md)) |

> O Power BI lê os CSVs de `data/processed/` diretamente: não há banco de dados.

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

## 📊 Dashboard

Dashboard de 2 páginas no Power BI: **Vendas** e **Entrega e Clientes**. O estilo, o modelo de cada página e o motivo de cada gráfico estão em [`docs/dashboard_design.md`](docs/dashboard_design.md).

O projeto do Power BI está em [`dashboard/`](dashboard/README.md): abra `dashboard/TechStore.pbip` no Power BI Desktop. Ele traz as tabelas lidas de `data/processed/`, os relacionamentos, o tema, as medidas DAX e as 2 páginas.

### Página 1 — Vendas

![Página 1 — Vendas](docs/images/pagina1_vendas.png)

### Página 2 — Entrega e Clientes

![Página 2 — Entrega e Clientes](docs/images/pagina2_entrega_clientes.png)

## 💡 Principais resultados

Considerando os pedidos válidos de **jan/2017 a ago/2018** (sem cancelados e indisponíveis):

- **Receita de R$ 15,68 milhões** em 97.905 pedidos, com ticket médio de R$ 160,19. O frete representa 14,2% da receita.
- **Crescimento forte:** a receita de jan–ago/2018 é 140% maior que a de jan–ago/2017. O pico foi em novembro/2017 (R$ 1,17 milhão), mês da Black Friday: 24/11/2017 foi o dia com mais pedidos.
- **Concentração geográfica:** São Paulo responde por 41,9% dos pedidos; os 3 maiores estados somam 66,5%.
- **Categorias:** Beleza e Saúde lidera em receita (R$ 1,43 milhão). As 5 maiores categorias somam 39,3% da receita.
- **Pagamento:** o cartão de crédito está em 77% dos pedidos.
- **Entrega:** 12,5 dias em média (o prazo prometido é de 23,6) e **6,79% dos pedidos chegam atrasados**, concentrados no Nordeste (Alagoas 21,5%, Maranhão 17,5%). O pior mês foi março/2018, com 19,0% de atraso.
- **Satisfação:** nota média de 4,12. Pedidos atrasados recebem **nota 2,27**, contra **4,29** dos entregues no prazo.
- **Fidelização baixa:** só 3,03% dos clientes compraram mais de uma vez.

## ⚠️ Limitações e cuidados

- **Associação não é causa.** A queda da nota nos pedidos atrasados é uma relação observada nos dados. Produto e qualidade também influenciam a avaliação, e este projeto não testa o efeito isolado do atraso.
- **Período fixo.** O dataset é um histórico de 2016 a 2018. Foram usados apenas jan/2017 a ago/2018, porque 2016 e set–out/2018 têm quase nenhum pedido.
- **Sem custo nem margem.** A receita é `price + freight_value`; o dataset não traz custos, então não há análise de lucro.
- **Sem nome de produto.** Os produtos aparecem por categoria; o dataset não tem o nome do produto.
- **Dados de apoio.** 279 clientes e 7 vendedores têm CEP sem correspondência na base de geolocalização (0,3% dos clientes). Eles não afetam os KPIs, só mapas por CEP.
- **Regras de negócio:** pedido válido, janela de tempo, receita e atraso por dia estão definidos em [`docs/kpis.md`](docs/kpis.md).

## 🗂️ Estrutura do projeto

```
TechStore Analytics/
├── data/
│   ├── raw/            # 9 CSVs originais (não alterados)
│   └── processed/      # CSVs tratados (*_clean.csv)
├── notebooks/          # 01 a 09: profiling e limpeza, um por dataset
├── dashboard/          # projeto do Power BI (TechStore.pbip): modelo, tema e páginas
├── docs/
│   ├── data_dictionary.md    # tabelas, colunas e relacionamentos
│   ├── data_cleaning.md      # o que foi feito na limpeza e por quê
│   ├── business_questions.md # perguntas de negócio
│   ├── kpis.md               # KPIs do dashboard
│   ├── dashboard_design.md   # estilo e modelo das páginas do dashboard
│   ├── qa_signoff.md         # validação final dos números e do projeto
│   └── images/               # capturas do dashboard
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
- **Power BI** (Power Query e DAX) para o modelo e o dashboard

## 🔭 Ideias de evolução

- Mapa de vendas e de atraso por CEP, usando a tabela `olist_geolocation_zip_clean.csv`, que já está pronta.
- Análise de coorte e de retenção, para entender melhor a baixa recompra (3,03%).
- Testar de forma isolada o efeito do atraso na nota, controlando por categoria e vendedor.
- Publicar o dashboard no Power BI Service.

## 📜 Licença

Distribuído sob a licença MIT. Veja o arquivo [`LICENSE`](LICENSE).

## 📄 Fonte dos dados

Olist, *Brazilian E-Commerce Public Dataset by Olist*, disponível no Kaggle. Os dados são anonimizados e públicos.
