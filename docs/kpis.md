# 📌 KPIs — Dashboard Olist

Lista de KPIs principais para o dashboard, servindo de base para as medidas DAX no Power BI.

- Receita Total
- Número de Pedidos
- Ticket Médio
- Clientes Únicos
- Clientes Recorrentes (%)
- Produtos Vendidos
- Categoria com Maior Receita
- Tempo Médio de Entrega
- Frete Médio
- % de Pedidos Atrasados
- Forma de Pagamento Mais Utilizada
- Avaliação Média

---

## Definições e valores de referência

Regras de negócio usadas em todos os KPIs do dashboard:

| Regra | Definição |
|---|---|
| **Pedido válido** | Status diferente de `canceled` e `unavailable`, comprado entre **2017-01-01 e 2018-08-31** e com pelo menos 1 item. 2016 e set–out/2018 têm quase nenhum pedido |
| **Receita** | `price + freight_value` dos itens (definição do [dicionário de dados](data_dictionary.md)) |
| **Cliente** | `customer_unique_id`, porque o `customer_id` muda a cada pedido |
| **Entrega** | Só pedidos `delivered` com data de entrega ao cliente |
| **Atraso** | Entrega **depois do dia** da data estimada (a data estimada não tem horário; comparando com horário o atraso iria de 6,79% para 8,1%) |

| KPI | Definição | Valor |
|---|---|---:|
| Receita Total | Soma de `price + freight_value` dos pedidos válidos | R$ 15.683.706,74 |
| Número de Pedidos | Pedidos válidos | 97.905 |
| Ticket Médio | Receita Total ÷ Número de Pedidos | R$ 160,19 |
| Clientes Únicos | `customer_unique_id` distintos | 94.703 |
| Clientes Recorrentes (%) | Clientes com 2 ou mais pedidos válidos ÷ Clientes Únicos | 3,03% |
| Produtos Vendidos | Itens vendidos nos pedidos válidos | 111.752 |
| Categoria com Maior Receita | Categoria com maior Receita Total | health_beauty (R$ 1,43 mi) |
| Tempo Médio de Entrega | Média de dias da compra até a entrega ao cliente | 12,5 dias |
| Frete Médio | Frete Total ÷ Número de Pedidos (por pedido) | R$ 22,82 |
| % de Pedidos Atrasados | Entregues depois do dia previsto ÷ pedidos entregues | 6,79% |
| Forma de Pagamento Mais Utilizada | Tipo presente em mais pedidos (sem `not_defined`) | credit_card (77,0%) |
| Avaliação Média | Média de `review_score` dos pedidos válidos | 4,12 |

Estes valores foram recalculados em SQL, de forma independente do Power BI, e conferem com o dashboard. Os nomes das medidas DAX são os mesmos dos KPIs e estão em [`dashboard/`](../dashboard/README.md).