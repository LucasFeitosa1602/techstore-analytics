# Dicionário de Dados — Olist Brazilian E-Commerce Dataset

Este documento descreve as principais tabelas do dataset público da Olist, utilizado como base para o pipeline de análise (ingestão → limpeza → Power BI).

---

## Tabela: olist_customers_dataset

**Chave primária:** customer_id

| Coluna | Tipo | Descrição |
|---|---|---|
| customer_id | string | Identificador único do cliente **por pedido** (não é o cliente "real") |
| customer_unique_id | string | Identificador único do cliente de fato, usado para rastrear recompra |
| customer_zip_code_prefix | string | Prefixo do CEP do cliente (5 primeiros dígitos) |
| customer_city | string | Cidade do cliente |
| customer_state | string | UF do cliente |

**Observações:**
- `customer_id` muda a cada pedido do mesmo cliente. Para análises de recorrência/LTV, usar `customer_unique_id`.
- `customer_zip_code_prefix` é a chave de ligação com `olist_geolocation_dataset`.

---

## Tabela: olist_orders_dataset

**Chave primária:** order_id

| Coluna | Tipo | Descrição |
|---|---|---|
| order_id | string | Identificador único do pedido |
| customer_id | string | FK para `olist_customers_dataset` |
| order_status | string | Status do pedido (delivered, shipped, canceled, unavailable, invoiced, processing, created, approved) |
| order_purchase_timestamp | datetime | Data/hora em que o pedido foi realizado |
| order_approved_at | datetime | Data/hora de aprovação do pagamento |
| order_delivered_carrier_date | datetime | Data em que o pedido foi entregue à transportadora |
| order_delivered_customer_date | datetime | Data em que o pedido foi entregue ao cliente |
| order_estimated_delivery_date | datetime | Data estimada de entrega (prometida ao cliente) |

**Observações:**
- Tabela fato central — todas as outras tabelas de pedido se conectam via `order_id`.
- `order_delivered_customer_date` pode ser nula mesmo com status "delivered" em alguns casos raros — checar durante o EDA.
- Comparar `order_delivered_customer_date` vs `order_estimated_delivery_date` permite calcular atraso de entrega.

---

## Tabela: olist_order_items_dataset

**Chave primária:** composta (order_id + order_item_id)

| Coluna | Tipo | Descrição |
|---|---|---|
| order_id | string | FK para `olist_orders_dataset` |
| order_item_id | int | Número sequencial do item dentro do pedido (1, 2, 3...) |
| product_id | string | FK para `olist_products_dataset` |
| seller_id | string | FK para `olist_sellers_dataset` |
| shipping_limit_date | datetime | Prazo limite para o vendedor despachar o item |
| price | float | Preço do item (sem frete) |
| freight_value | float | Valor do frete daquele item |

**Observações:**
- Um pedido pode ter múltiplos itens (e múltiplos vendedores diferentes).
- `price` é por item individual, não pela linha inteira — se `order_item_id` se repetir com mesma quantidade, somar.
- Receita total do pedido = soma de `price + freight_value` de todos os itens daquele `order_id`.

---

## Tabela: olist_order_payments_dataset

**Chave primária:** composta (order_id + payment_sequential)

| Coluna | Tipo | Descrição |
|---|---|---|
| order_id | string | FK para `olist_orders_dataset` |
| payment_sequential | int | Sequência de pagamento (um pedido pode ter mais de um pagamento) |
| payment_type | string | Tipo de pagamento (credit_card, boleto, voucher, debit_card) |
| payment_installments | int | Número de parcelas |
| payment_value | float | Valor pago naquela transação |

**Observações:**
- Um pedido pode ter mais de uma forma de pagamento combinada (ex: voucher + cartão).
- `payment_value` somado por `order_id` deve aproximar o valor total do pedido (itens + frete) — bom ponto de validação cruzada no EDA.

---

## Tabela: olist_order_reviews_dataset

**Chave primária:** review_id

| Coluna | Tipo | Descrição |
|---|---|---|
| review_id | string | Identificador único da avaliação |
| order_id | string | FK para `olist_orders_dataset` |
| review_score | int | Nota da avaliação (1 a 5) |
| review_comment_title | string | Título do comentário (frequentemente nulo) |
| review_comment_message | string | Texto do comentário (frequentemente nulo) |
| review_creation_date | datetime | Data em que a avaliação foi solicitada |
| review_answer_timestamp | datetime | Data em que o cliente respondeu a avaliação |

**Observações:**
- Alto volume de nulos em `review_comment_title` e `review_comment_message` — maioria dos clientes só dá nota, sem comentário.
- Pode haver mais de uma review por `order_id` em casos raros.

---

## Tabela: olist_products_dataset

**Chave primária:** product_id

| Coluna | Tipo | Descrição |
|---|---|---|
| product_id | string | Identificador único do produto |
| product_category_name | string | Categoria do produto (em português) |
| product_weight_g | float | Peso do produto em gramas |
| product_length_cm | float | Comprimento em cm |
| product_height_cm | float | Altura em cm |
| product_width_cm | float | Largura em cm |

**Observações:**
- `product_category_name` está em português e precisa do de-para com `product_category_name_translation` para versões em inglês.
- Existem nulos em categoria e dimensões para uma pequena parcela dos produtos.

---

## Tabela: olist_sellers_dataset

**Chave primária:** seller_id

| Coluna | Tipo | Descrição |
|---|---|---|
| seller_id | string | Identificador único do vendedor |
| seller_zip_code_prefix | string | Prefixo do CEP do vendedor |
| seller_city | string | Cidade do vendedor |
| seller_state | string | UF do vendedor |

**Observações:**
- Assim como `customer_zip_code_prefix`, conecta-se com `olist_geolocation_dataset` via prefixo de CEP.

---

## Tabela: olist_geolocation_dataset

**Chave primária:** não há (tabela de apoio, sem PK única — múltiplas linhas por prefixo de CEP)

| Coluna | Tipo | Descrição |
|---|---|---|
| geolocation_zip_code_prefix | string | Prefixo do CEP |
| geolocation_lat | float | Latitude |
| geolocation_lng | float | Longitude |
| geolocation_city | string | Cidade |
| geolocation_state | string | UF |

**Observações:**
- Um mesmo `geolocation_zip_code_prefix` pode ter várias coordenadas (imprecisão geográfica). Para mapas, recomenda-se agregar por média de lat/lng ou pegar a primeira ocorrência por prefixo.

---

## Tabela: product_category_name_translation

**Chave primária:** product_category_name

| Coluna | Tipo | Descrição |
|---|---|---|
| product_category_name | string | Nome da categoria em português (chave de ligação com `olist_products_dataset`) |
| product_category_name_english | string | Nome da categoria traduzido para inglês |

**Observações:**
- Tabela de apoio pequena, usada apenas para padronizar nomes de categoria em dashboards/relatórios em inglês.

---

## Relacionamento entre as tabelas (visão geral)

```
customers ──< orders ──< order_items >── products
                │              │              │
                │              └──< sellers    └── product_category_name_translation
                │
                ├──< order_payments
                └──< order_reviews

customers.customer_zip_code_prefix ──> geolocation.geolocation_zip_code_prefix
sellers.seller_zip_code_prefix     ──> geolocation.geolocation_zip_code_prefix
```

**Legenda:** `──<` indica relação um-para-muitos (a tabela do lado do `<` tem múltiplas linhas por chave da outra).