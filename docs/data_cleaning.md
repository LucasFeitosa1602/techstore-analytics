# 🧹 Documentação do Tratamento de Dados — Olist

Este documento registra o que foi feito na etapa de **profiling e limpeza** dos 9 datasets brutos do e-commerce Olist, as decisões tomadas, como cada tratamento foi validado e quais pontos precisam de atenção nas próximas etapas (carga no Supabase e dashboard).

> Dicionário das colunas: [`data_dictionary.md`](data_dictionary.md) · KPIs: [`kpis.md`](kpis.md) · Perguntas de negócio: [`business_questions.md`](business_questions.md)

---

## 1. Visão geral

| Item | Descrição |
|---|---|
| Origem | Dataset público *Brazilian E-Commerce Public Dataset by Olist* (9 CSVs) em `data/raw/` |
| Resultado | 10 CSVs tratados em `data/processed/` |
| Ferramentas | Python 3.12, pandas e Jupyter Notebook |
| Período dos pedidos | 2016-09-04 a 2018-10-17 |

### Fluxo

```
data/raw/*.csv ──► notebooks/NN_<tabela>_profiling.ipynb ──► data/processed/*_clean.csv
  (bruto, nunca alterado)     (profiling → tratamento → validação)      (pronto para o banco)
```

### Convenções seguidas em todos os notebooks

1. **Um notebook por dataset**, na ordem `NN_<tabela>_profiling.ipynb`.
2. O dataframe original **nunca é alterado**: o tratamento é feito em uma cópia (`<tabela>_clean`).
3. Cada tratamento é seguido de uma **validação**: contagem de linhas, nulos, duplicidades, relacionamentos e comparação com os valores originais.
4. Os registros **não são removidos** quando têm relação com pedidos. A única exceção é `geolocation`, que tinha duplicatas e coordenadas inválidas.
5. O arquivo tratado é salvo como `<nome_do_arquivo_bruto>_clean.csv`.
6. Cada notebook termina com uma conclusão (o que foi encontrado, feito, como foi validado e o resultado).

### Checagens aplicadas

Em cada tabela foram avaliados: valores nulos, linhas duplicadas, duplicidade de chave, tipos de dados, faixas de valores (preço, frete, nota, parcelas, coordenadas), valores permitidos (UF, status, tipo de pagamento), consistência entre datas e integridade referencial com as tabelas relacionadas.

---

## 2. Resumo por dataset

| # | Notebook | Dataset bruto | Linhas (bruto → tratado) | Arquivo em `data/processed/` | O que mudou |
|---|---|---|---|---|---|
| 01 | `01_products_profiling` | `olist_products_dataset` | 32.951 → 32.951 | `olist_products_dataset_clean.csv` | Nulos preenchidos |
| 02 | `02_order_items_profiling` | `olist_order_items_dataset` | 112.650 → 112.650 | `olist_order_items_dataset_clean.csv` | `shipping_limit_date` virou `datetime` |
| 03 | `03_orders_profiling` | `olist_orders_dataset` | 99.441 → 99.441 | `olist_orders_dataset_clean.csv` | Datas convertidas e inconsistentes anuladas |
| 04 | `04_customers_profiling` | `olist_customers_dataset` | 99.441 → 99.441 | `olist_customers_dataset_clean.csv` | Nenhum valor (CEP preservado como texto) |
| 05 | `05_sellers_profiling` | `olist_sellers_dataset` | 3.095 → 3.095 | `olist_sellers_dataset_clean.csv` | 21 valores de cidade |
| 06 | `06_order_payments_profiling` | `olist_order_payments_dataset` | 103.886 → 103.886 | `olist_order_payments_dataset_clean.csv` | 2 valores de parcelas |
| 07 | `07_order_reviews_profiling` | `olist_order_reviews_dataset` | 99.224 → 99.224 | `olist_order_reviews_dataset_clean.csv` | Datas e textos de comentário |
| 08 | `08_geolocation_profiling` | `olist_geolocation_dataset` | 1.000.163 → 720.461 | `olist_geolocation_dataset_clean.csv` e `olist_geolocation_zip_clean.csv` (19.010 CEPs) | Duplicatas, coordenadas e cidades |
| 09 | `09_category_translation_profiling` | `product_category_name_translation` | 71 → 74 | `product_category_name_translation_clean.csv` | 3 categorias adicionadas |

---

## 3. Detalhe por dataset

### 01 — Products

- **Encontrado:** 610 produtos (1,85%) com categoria, tamanho do nome, tamanho da descrição e quantidade de fotos nulos; 2 produtos com peso e dimensões nulos. Os produtos com nulos têm vendas em `order_items`, por isso não podem ser removidos.
- **Tratamento:** `product_category_name` → `Unknown`; `product_name_lenght` e `product_description_lenght` → `0`; `product_photos_qty` e as medidas físicas → mediana.
- **Validação:** sem nulos, sem `product_id` duplicado, valores originais inalterados e todos os `product_id` de `order_items` existem em `products`.
- **Observação:** as colunas `product_name_lenght` e `product_description_lenght` mantêm o erro de grafia do dataset original (`lenght`).

### 02 — Order Items

- **Encontrado:** sem nulos, sem duplicidade em `order_id + order_item_id`, sem valores negativos em `price` e `freight_value`, e relacionamentos com `products`, `orders` e `sellers` íntegros. 383 itens têm frete 0 (provável frete grátis).
- **Tratamento:** `shipping_limit_date` convertida de texto para `datetime`.
- **Observação:** 4 itens têm `shipping_limit_date` em 2020, depois do fim da base (2018). Os valores foram mantidos, e a coluna não deve ser usada para medir prazo de postagem sem filtrar esses casos.

### 03 — Orders

- **Encontrado:**
  - 166 pedidos com envio à transportadora **antes** da compra;
  - 23 pedidos com entrega ao cliente **antes** do envio (sem sobreposição com os 166);
  - 6 pedidos `canceled` com data de entrega;
  - 8 pedidos `delivered` sem data de entrega e 14 sem data de aprovação.
- **Tratamento:**
  - 5 colunas de data convertidas para `datetime`;
  - data de envio à transportadora → nula nos 189 casos incoerentes (a entrega continua posterior à compra, então o tempo de entrega não é afetado);
  - data de entrega ao cliente → nula nos 6 cancelados;
  - os 8 `delivered` sem data de entrega e os 14 sem aprovação foram mantidos, sem inventar datas.
- **Validação:** 99.441 linhas, sem `order_id` duplicado, nenhuma violação de cronologia, nenhum cancelado com data de entrega. Nulos finais: `order_approved_at` 160, `order_delivered_carrier_date` 1.972 e `order_delivered_customer_date` 2.971.

### 04 — Customers

- **Encontrado:** sem nulos e sem duplicidade; 96.096 clientes únicos (`customer_unique_id`) para 99.441 `customer_id`, com 2.997 (3,12%) que recompraram; 27 UFs válidas; **23.995 CEPs começam com zero**; 278 clientes (0,28%) com CEP ausente em `geolocation`.
- **Tratamento:** nenhum valor foi alterado, só padronizações preventivas. O ponto central é que o CEP é lido e salvo como **texto**.

### 05 — Sellers

- **Encontrado:** sem nulos e sem duplicidade; 23 UFs; **18 cidades sujas** (UF junto da cidade como `auriflama/sp`, abreviação `sbc/sp`, CEP `04482255` e um e-mail no lugar da cidade); 7 vendedores com CEP ausente em `geolocation`.
- **Tratamento:** cidade padronizada (minúscula, sem acento). As 18 sujas foram substituídas pela cidade mais frequente em `geolocation` para o mesmo CEP (ex.: `sbc/sp` → `sao bernardo do campo`). No total, 21 valores alterados.

### 06 — Order Payments

- **Encontrado:** sem nulos e sem duplicidade; `credit_card` 73,9%, `boleto` 19,0%, `voucher` 5,6%, `debit_card` 1,5%; 3 registros `not_defined` (pedidos cancelados, sem itens, valor 0); 9 pagamentos de valor 0; 2 pagamentos com 0 parcelas; 80 pedidos com buracos em `payment_sequential`; 2.961 pedidos com mais de um pagamento; 1 pedido sem pagamento.
- **Tratamento:** `payment_installments` 0 → 1 (2 valores). Os demais casos foram mantidos, pois não afetam a receita.
- **Validação cruzada:** em 98.665 pedidos com itens e pagamento, **99,61%** têm total pago igual a `price + frete` (diferença de até R$ 0,01).

### 07 — Order Reviews

- **Encontrado:** `review_comment_title` com 88,34% de nulos e `review_comment_message` com 58,70% (esperado: muitos clientes só dão a nota); `review_id` **repetido em 814 linhas** (789 ids distintos, sempre em pedidos diferentes, mas `review_id + order_id` é único); 547 pedidos com mais de uma avaliação; 3.852 mensagens com quebra de linha; 768 pedidos sem avaliação.
- **Tratamento:** datas convertidas para `datetime`; quebras de linha e espaços repetidos viram um espaço; textos vazios viram nulo (+2 no título e +27 na mensagem). Os `review_id` repetidos foram mantidos.

### 08 — Geolocation

- **Encontrado:** 1.000.163 linhas, sem chave primária (19.015 CEPs, mediana de 29 pontos por CEP); **261.831 linhas duplicadas (26,18%)**; 42 pontos com coordenadas fora do Brasil; 8.011 grafias de cidade, com acentos (`são paulo` × `sao paulo` × `sãopaulo`) e codificação de URL (`d%26apos%3balho`).
- **Tratamento:**
  - cidade padronizada (8.011 → 5.961 grafias);
  - 42 pontos fora do Brasil removidos;
  - 279.660 linhas duplicadas removidas, incluindo as que surgiram após a padronização (→ 720.461 linhas);
  - criada a tabela **por CEP** (`olist_geolocation_zip_clean.csv`, 19.010 linhas: mediana de latitude e longitude, cidade e estado mais frequentes e `n_points`).
- **Atenção:** 5 CEPs só tinham pontos inválidos e saíram da tabela (clientes sem CEP em `geolocation`: 278 → 279). 8 CEPs aparecem em mais de um estado, e na tabela por CEP prevalece o mais frequente.

### 09 — Category Translation

- **Encontrado:** 71 categorias sem nulos ou duplicidade. Porém 623 produtos tinham categoria sem tradução: `Unknown` (610), `portateis_cozinha_e_preparadores_de_alimentos` (10) e `pc_gamer` (3).
- **Tratamento:** adicionadas 3 linhas (`pc_gamer` → `pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos` → `portable_kitchen_food_preparers`, `Unknown` → `unknown`). Linhas originais inalteradas. Resultado: todas as categorias de `products` têm tradução.

---

## 4. Integridade entre as tabelas

| Relacionamento | Resultado |
|---|---|
| `orders.customer_id` → `customers` | ✅ sem órfãos |
| `order_items.order_id` → `orders` | ✅ sem órfãos |
| `order_items.product_id` → `products` | ✅ sem órfãos |
| `order_items.seller_id` → `sellers` | ✅ sem órfãos |
| `order_payments.order_id` → `orders` | ✅ sem órfãos |
| `order_reviews.order_id` → `orders` | ✅ sem órfãos |
| `products.product_category_name` → `category_translation` | ✅ sem órfãos (depois do tratamento) |
| `customers.zip` → `geolocation` | ⚠️ 279 clientes com CEP sem correspondência |
| `sellers.zip` → `geolocation` | ⚠️ 7 vendedores com CEP sem correspondência |

---

## 5. Pontos de atenção para as análises

| Tema | Detalhe |
|---|---|
| **Janela de tempo** | Os pedidos de 2016 são raros (set: 4, out: 324, nov: 0, dez: 1) e a base termina em 2018-08 na prática (2018-09: 16 pedidos; 2018-10: 4). Para tendências, a janela sugerida é **2017-01 a 2018-08**. |
| **Status dos pedidos** | 775 pedidos não têm itens (603 `unavailable`, 164 `canceled`, 5 `created`, 2 `invoiced`, 1 `shipped`) e existem itens ligados a pedidos `canceled` (542). Definir o filtro de status da Receita e do Ticket Médio (sugestão: excluir `canceled` e `unavailable`). |
| **Join sem agregar** | Um pedido pode ter vários itens, pagamentos e avaliações. Agregar por `order_id` antes de juntar tabelas, senão a receita é duplicada. |
| **Geolocation** | Usar `olist_geolocation_zip_clean.csv` (1 linha por CEP) nos joins. O join direto com os pontos gera mais de 15 milhões de linhas. |
| **Avaliação por pedido** | 547 pedidos têm mais de uma avaliação, então agregar por `order_id` antes de calcular a média. |
| **Tempo de entrega** | Calcular só com pedidos `delivered` e com data de entrega. 8 pedidos `delivered` não têm essa data. |
| **Forma de pagamento** | Excluir `not_defined` ao calcular a forma mais usada. |

---

## 6. Pontos de atenção para a carga no Supabase

Conferidos os CSVs de `data/processed/` contra `database/schema.sql`:

| # | Ponto | Ação sugerida |
|---|---|---|
| 1 | `order_reviews.review_id` é `PRIMARY KEY` no schema, mas tem 814 repetidos. A carga falha. | Usar `(review_id, order_id)` como chave composta (é única) ou um id sequencial. |
| 2 | `products` é salvo com valores como `40.0`, `287.0` e `225.0` nas colunas inteiras (`product_name_lenght`, `product_description_lenght`, `product_photos_qty`, `product_weight_g`). O `COPY` do Postgres rejeita `40.0` em colunas `INTEGER` e `SMALLINT`. | Converter essas colunas para inteiro antes de salvar ou na carga. |
| 3 | O schema de `geolocation` espera os pontos brutos (com id sequencial). Para joins e mapas, a tabela útil é a de 1 linha por CEP. | Criar uma tabela por CEP (`geolocation_zip`, com `geolocation_zip_code_prefix` como chave) e decidir se os 720 mil pontos também entram. |
| 4 | Não existe FK de `products` para `product_category_translation`. Agora é possível, pois todas as categorias têm tradução. | Adicionar em `constraints.sql`. |
| 5 | FK de CEP (`customers`/`sellers` → `geolocation`) não pode ser imposta: 279 clientes e 7 vendedores têm CEP sem correspondência. | Manter como relação lógica (join `LEFT`). |
| 6 | O CEP precisa continuar como texto (`VARCHAR(5)`). | Ao ler os CSVs, usar `dtype=str` nas colunas de CEP. |
| 7 | O nome da tabela no schema (`product_category_translation`) difere do arquivo (`product_category_name_translation_clean.csv`). | Mapear o arquivo para a tabela na carga. |

Verificados e compatíveis com o schema: tamanhos de texto (maior título de avaliação com 26 caracteres, `VARCHAR(100)`), ausência de nulos nas colunas `NOT NULL`, formato de data `YYYY-MM-DD HH:MM:SS` e unicidade das chaves de `order_items` e `order_payments`.

Mapeamento arquivo → tabela:

| Arquivo em `data/processed/` | Tabela no schema |
|---|---|
| `olist_customers_dataset_clean.csv` | `customers` |
| `olist_sellers_dataset_clean.csv` | `sellers` |
| `olist_products_dataset_clean.csv` | `products` |
| `product_category_name_translation_clean.csv` | `product_category_translation` |
| `olist_orders_dataset_clean.csv` | `orders` |
| `olist_order_items_dataset_clean.csv` | `order_items` |
| `olist_order_payments_dataset_clean.csv` | `order_payments` |
| `olist_order_reviews_dataset_clean.csv` | `order_reviews` |
| `olist_geolocation_dataset_clean.csv` / `olist_geolocation_zip_clean.csv` | `geolocation` (pontos) / tabela por CEP a criar |

---

## 7. Como reproduzir

1. Ter os 9 CSVs brutos em `data/raw/`.
2. Executar os notebooks em `notebooks/` na ordem numérica. O `01` deve rodar antes do `02` e do `09`, que leem `olist_products_dataset_clean.csv`.
3. Os arquivos tratados são recriados em `data/processed/`.

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
jupyter lab
```

---

## 8. Próximos passos

1. Fechar as definições pendentes dos KPIs (filtro de status e janela de tempo) em [`kpis.md`](kpis.md).
2. Ajustar o `database/schema.sql` com os pontos da seção 6.
3. Criar o banco no Supabase e carregar os arquivos de `data/processed/`.
4. Escrever `indexes.sql` e `views.sql` com os KPIs.
5. Responder às perguntas de negócio ([`business_questions.md`](business_questions.md)) e montar o dashboard no Power BI.
