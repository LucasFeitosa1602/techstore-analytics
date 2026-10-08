# 📊 Projeto Power BI — TechStore Analytics

Projeto do Power BI (formato `.pbip`) com o modelo de dados, os relacionamentos, o tema e as 2 páginas em branco. Falta só criar os gráficos e as medidas DAX.

O design das páginas está em [`../docs/dashboard_design.md`](../docs/dashboard_design.md).

> ⚠️ **Este projeto foi gerado por script e não foi aberto no Power BI Desktop** (ele não estava disponível no ambiente de geração). Os arquivos foram conferidos contra os CSVs (colunas, tipos e chaves), mas se o Desktop reclamar de algo na primeira abertura, anote a mensagem de erro para corrigir.

## O que já vem pronto

| Item | Detalhe |
|---|---|
| **Fonte de dados** | CSVs de `data/processed/`, lidos pelo Power Query |
| **Parâmetro** | `DataPath`: pasta dos CSVs (já aponta para `D:\Projetos DEV\TechStore Analytics\data\processed\`) |
| **Tabelas (10)** | `orders`, `order_items`, `order_payments`, `order_reviews`, `customers`, `sellers`, `products`, `product_category_translation`, `geolocation_zip` e `calendario` |
| **Relacionamentos (10)** | Todos de muitos para um, com filtro em uma direção (veja abaixo) |
| **Tema** | `TechStore`: paleta, fonte Segoe UI, fundo da página cinza claro e visuais brancos com cantos arredondados |
| **Páginas** | `Vendas` e `Entrega e Clientes`, em 16:9 (1280 × 720) |
| **Não vem** | Medidas DAX e visuais (você cria) |

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

O último está inativo de propósito: `geolocation_zip` chegaria em `order_items` por dois caminhos (via clientes e via vendedores), o que o Power BI não aceita como ativo. Use-o apenas com `USERELATIONSHIP` em uma medida DAX.

## Como abrir

1. Abra o **Power BI Desktop** e depois `dashboard/TechStore.pbip` (ou dê dois cliques no arquivo).
   - Se aparecer erro sobre o formato, ative em *Arquivo → Opções → Recursos de visualização* as opções de projeto do Power BI (`.pbip`) e de modelo semântico em formato **TMDL**, e abra de novo.
2. Clique em **Atualizar** (aba Página Inicial). O projeto não guarda dados: eles são carregados dos CSVs.
3. Se a pasta do projeto estiver em outro lugar, vá em *Transformar dados → Gerenciar parâmetros* e ajuste o `DataPath`. **Termine o caminho com `\`**.
4. Confira na aba **Modelo** se os relacionamentos aparecem como na tabela acima.

### Conferência depois de atualizar

| Tabela | Linhas esperadas |
|---|---:|
| `orders` | 99.441 |
| `order_items` | 112.650 |
| `order_payments` | 103.886 |
| `order_reviews` | 99.224 |
| `customers` | 99.441 |
| `products` | 32.951 |
| `sellers` | 3.095 |
| `geolocation_zip` | 19.010 |
| `product_category_translation` | 74 |
| `calendario` | 791 (2016-09-01 a 2018-10-31) |

## Tema

O tema vem aplicado. Se ele não aparecer, importe manualmente em *Exibição → Temas → Procurar temas* usando o arquivo [`TechStore.Report/StaticResources/RegisteredResources/TechStore.json`](TechStore.Report/StaticResources/RegisteredResources/TechStore.json).

Ele define as cores de dados, a fonte, o fundo cinza da página e o fundo branco com cantos de 8 px dos visuais. Os cartões (KPI) podem pedir ajuste do tamanho do valor ao criar.

## Observações sobre os dados

- **CEP é texto** em todas as tabelas, para não perder o zero à esquerda.
- **Pontos de geolocalização não foram incluídos** (`olist_geolocation_dataset_clean.csv`, 720 mil linhas). Use `geolocation_zip` (1 linha por CEP) para mapas.
- **279 clientes** e **7 vendedores** têm CEP sem correspondência em `geolocation_zip`: aparecem em branco em mapas por CEP.
- `products` não tem nome do produto: ele é identificado pelo `product_id`.
- O `calendario` vai de 2016-09-01 a 2018-10-31. Para marcá-lo como tabela de data, ele já vem com `dataCategory: Time` e a coluna `Date` como chave.
- **Regras de negócio** (janela 2017-01 a 2018-08, excluir `canceled` e `unavailable`, receita = `price + freight_value`, atraso por dia) **não estão aplicadas no modelo**: entram nas suas medidas DAX e filtros. Veja a seção "Cuidados com os dados" de [`dashboard_design.md`](../docs/dashboard_design.md).

## Salvar como `.pbix`

O formato `.pbip` é bom para versionar no Git. Se preferir um arquivo único, use *Arquivo → Salvar como* no Desktop. O `.pbix` guarda os dados importados e fica bem maior.

No Git, a pasta `.pbi/` (cache local) é ignorada pelo `.gitignore`.
