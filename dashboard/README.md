# 📊 Projeto Power BI — TechStore Analytics

Projeto do Power BI (formato `.pbip`) com o modelo de dados, os relacionamentos, o tema, as medidas DAX e as 2 páginas do dashboard. Lê os CSVs tratados de `data/processed/`: não há banco de dados.

| Página | Capturas |
|---|---|
| Vendas | [`docs/images/pagina1_vendas.png`](../docs/images/pagina1_vendas.png) |
| Entrega e Clientes | [`docs/images/pagina2_entrega_clientes.png`](../docs/images/pagina2_entrega_clientes.png) |

Estilo, escolha de cada gráfico e regras: [`docs/dashboard_design.md`](../docs/dashboard_design.md). Definição dos KPIs: [`docs/kpis.md`](../docs/kpis.md).

## Como abrir

1. Abra o **Power BI Desktop** e depois `dashboard/TechStore.pbip`.
   - Se aparecer erro de formato, ative em *Arquivo → Opções → Recursos de visualização* as opções de projeto do Power BI (`.pbip`) e de modelo semântico em formato **TMDL**.
2. Clique em **Atualizar**. O projeto não guarda os dados: eles são carregados dos CSVs.
3. Se a pasta do projeto estiver em outro lugar, ajuste o parâmetro `DataPath` em *Transformar dados → Gerenciar parâmetros*. **Termine o caminho com `\`**.

> Se você editar os arquivos do projeto fora do Power BI Desktop, feche o Desktop **sem salvar** antes e reabra o `.pbip`: ele não recarrega mudanças feitas por fora e, ao salvar, sobrescreve elas.

## O que o projeto contém

| Item | Detalhe |
|---|---|
| **Fonte de dados** | CSVs de `data/processed/`, lidos pelo Power Query |
| **Tabelas (11)** | `orders`, `order_items`, `order_payments`, `order_reviews`, `customers`, `sellers`, `products`, `product_category_translation`, `geolocation_zip`, `calendario` e `_Medidas` (só medidas) |
| **Relacionamentos (10)** | Todos de muitos para um, com filtro em uma direção |
| **Colunas calculadas (6)** | Na `orders`: `pedido_valido`, `cliente_pessoa`, `dias_entrega`, `atrasado`, `situacao_entrega` e `pedidos_validos_do_cliente` |
| **Medidas DAX (29)** | Na `_Medidas`, em duas pastas: `Vendas` e `Entrega e Clientes` |
| **Tema** | `TechStore`: paleta, fonte Segoe UI, fundo cinza e visuais brancos com cantos arredondados |
| **Páginas** | `Vendas` e `Entrega e Clientes`, em 16:9 (1280 × 720), com 3 segmentações sincronizadas (Período, Categoria e Estado) |

### Relacionamentos

| De (muitos) | Para (um) |
|---|---|
| `orders[customer_id]` | `customers[customer_id]` |
| `order_items[order_id]` | `orders[order_id]` |
| `order_items[product_id]` | `products[product_id]` |
| `order_items[seller_id]` | `sellers[seller_id]` |
| `order_payments[order_id]` | `orders[order_id]` |
| `order_reviews[order_id]` | `orders[order_id]` |
| `products[product_category_name]` | `product_category_translation[product_category_name]` |
| `orders[order_purchase_date]` | `calendario[Date]` |
| `customers[customer_zip_code_prefix]` | `geolocation_zip[geolocation_zip_code_prefix]` |
| `sellers[seller_zip_code_prefix]` | `geolocation_zip[geolocation_zip_code_prefix]` (**inativo**) |

O último está inativo de propósito: `geolocation_zip` chegaria em `order_items` por dois caminhos (via clientes e via vendedores), o que o Power BI não aceita como ativo.

## Regras de negócio

Toda medida usa a coluna `orders[pedido_valido]`: status diferente de `canceled` e `unavailable`, compra entre 2017-01-01 e 2018-08-31 e pelo menos 1 item. Para mudar a janela ou os status, edite só essa coluna (e o fim do `calendario`).

| Regra | Definição |
|---|---|
| Receita | `price + freight_value` |
| Entrega | Só pedidos `delivered` com data de entrega ao cliente |
| Atraso | Entrega depois do **dia** da data estimada (comparação por data, sem horário) |
| Cliente | `customer_unique_id` |

As medidas de pedidos, entrega e clientes reagem aos filtros de Estado e Período, mas **não ao de Categoria** (que filtra os itens, não os pedidos).

## Validação

Os números do dashboard foram recalculados de forma independente: **91 de 91 valores conferem**. Veja [`docs/qa_signoff.md`](../docs/qa_signoff.md). Valores de referência, sem filtros:

| Medida | Valor |
|---|---|
| Receita Total | R$ 15.683.706,74 |
| Número de Pedidos | 97.905 |
| Ticket Médio | R$ 160,19 |
| Frete Médio por Pedido | R$ 22,82 |
| Produtos Vendidos | 111.752 |
| Categoria com Maior Receita | health_beauty |
| Forma de Pagamento Mais Usada | credit_card |
| % Pedidos Atrasados | 6,79% |
| Tempo Médio de Entrega | 12,5 dias |
| Avaliação Média | 4,12 |
| Clientes Únicos | 94.703 |
| Clientes Recorrentes % | 3,03% |

## Pontos de atenção

- **CEP é texto** em todas as tabelas, para não perder o zero à esquerda.
- **Os pontos de geolocalização não foram incluídos** (`olist_geolocation_dataset_clean.csv`, 720 mil linhas). Use `geolocation_zip` (1 linha por CEP) para mapas.
- **279 clientes** e **7 vendedores** têm CEP sem correspondência em `geolocation_zip`: aparecem em branco em mapas por CEP.
- `products` não tem nome do produto: ele é identificado pela categoria.
- Em caso de erro nas medidas ao reabrir, clique em **Atualizar**: as colunas calculadas são recalculadas na atualização.

## Salvar como `.pbix`

O formato `.pbip` é bom para versionar no Git. Se preferir um arquivo único, use *Arquivo → Salvar como* no Desktop. O `.pbix` guarda os dados importados e fica bem maior. No Git, a pasta `.pbi/` (cache local) é ignorada pelo `.gitignore`.
