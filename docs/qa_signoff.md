# ✅ QA Sign-off — TechStore Analytics

**Projeto:** TechStore Analytics — dashboard de vendas, entrega e clientes da Olist  
**Autor:** Lucas Feitosa  
**Data da revisão:** 2026-10-09  
**Público:** gestão comercial, operações e portfólio (GitHub e LinkedIn)  
**Formato de entrega:** dashboard no Power BI (2 páginas), notebooks e documentação  
**Metodologia:** checklist de QA de análises (`analysis-qa-checklist`)

---

## Resultados automáticos

| Verificação | Status | Observações |
|---|---|---|
| `qa_runner.py` nos 10 arquivos tratados (`data/processed/`) | **PASS** | 0 FAIL e 0 WARN em todos. Sem linhas duplicadas, colunas 100% nulas, infinitos ou datas futuras |
| Notebooks (01 a 09) | **PASS** | Sem erros e todas as células executadas. O notebook 05 foi reexecutado e o CSV de saída ficou idêntico (mesmo hash) |
| Esquema do Power BI | **PASS** | Propriedades dos 24 visuais de dados, medidas, colunas, sincronização e texto alternativo conferidos. As 8 caixas de texto (legendas dos cartões) são marcadas pelo validador (`general.paragraphs`), mas renderizam normalmente no Desktop |
| Links relativos da documentação | **PASS** | Nenhum link quebrado |
| Segredos no repositório | **PASS** | Nenhum; `.env` está no `.gitignore` e não é rastreado |

## Conferência independente dos números

Todos os valores numéricos dos gráficos e cartões (91) foram recalculados com uma lógica escrita à parte da usada no Power BI (SQL/SQLite e, na segunda rodada, pandas): **91 de 91 conferem**.

| Grupo | Itens conferidos |
|---|---|
| KPIs (12) | Receita, pedidos, ticket, frete, itens, clientes, recorrência, tempo de entrega, atraso, avaliação, nota no prazo e atrasado |
| Categorias | 10 maiores receitas |
| Estados | 10 maiores em pedidos e 10 maiores em % de atraso (mínimo de 100 entregas) |
| Pagamento e notas | 4 formas de pagamento e 5 notas |
| Séries mensais (40) | Receita e % de pedidos atrasados, de jan/2017 a ago/2018 (20 meses cada) |
| Amostra de 3 pedidos | Receita = `price + frete` e igual ao valor pago |

## Checklist manual

| Seção | Status | Observações |
|---|---|---|
| 1. Enquadramento da pergunta | **PASS** | Responde as perguntas de `business_questions.md`. Produto individual é respondido por categoria (veja o item 10 abaixo) |
| 2. Origem dos dados | **PASS** | Dataset público da Olist, conhecido e documentado em `docs/data_dictionary.md` e `docs/data_cleaning.md` |
| 3. Transformações e cálculos | **PASS** | Joins sem duplicar linhas (verificado), receita sem duplicação, divisões seguras com `DIVIDE`, denominadores corretos (veja o item 1) |
| 4. Validade estatística | **PASS** | Sem testes inferenciais. Ranking de estados exige 100 entregas. Associação entre atraso e nota não é tratada como causa |
| 5. Achados e conclusões | **PASS** | Limitações escritas no README |
| 6. Apresentação | **PASS** | Títulos, formatos e legendas consistentes. Capturas do README conferidas com os números (item 3) |

## Problemas encontrados

| # | Severidade | Descrição | Resolução | Status |
|---|---|---|---|---|
| 1 | **MUST FIX** | % de pedidos atrasados 6,67% e nota "No prazo" 4,25: pedidos ainda não entregues eram classificados como "No prazo" | Coluna `situacao_entrega` passou a depender de `dias_entrega`. Agora 6,79% e 4,29, iguais ao recálculo em SQL | Corrigido |
| 2 | **MUST FIX** | Segmentações não sincronizavam entre as páginas | `syncGroup` regravado no lugar correto do arquivo | Corrigido |
| 3 | SHOULD FIX | Gráficos Top 10 categorias e Top 10 estados por atraso mostravam 7 de 10 barras, com barra de rolagem | O Power BI não aceita menos de 20 px por categoria (o valor 12 foi ignorado), então 10 barras precisam de cerca de 250 px de altura. Os gráficos de 10 barras foram para a linha de baixo (262 px) e os de 2 e 4 barras para a de cima, sem mudar a grade. Confirmado nas novas capturas: 10 barras visíveis nos dois gráficos | Corrigido |
| 4 | SHOULD FIX | README e `dashboard/README.md` desatualizados (diziam "não aberto no Desktop", "em construção") | Reescritos com o estado real | Corrigido |
| 5 | SHOULD FIX | Regras de negócio dos KPIs só em `dashboard_design.md`; `kpis.md` só listava os nomes | Definições e valores de referência adicionados a `docs/kpis.md` | Corrigido |
| 6 | SHOULD FIX | `LICENSE`, `CHANGELOG.md`, `ROADMAP.md` e `main.py` vazios | MIT; changelog e roadmap preenchidos; `main.py` removido | Corrigido |
| 7 | MINOR | Fim do eixo Y = 7 herdado no gráfico de receita | Removido | Corrigido |
| 8 | MINOR | Célula não executada no notebook 05 | Notebook reexecutado, saída idêntica | Corrigido |
| 9 | MINOR | Fontes diferentes entre cartões, sem texto alternativo e ordem de leitura | Padronizado e preenchido | Corrigido |
| 10 | — | "Qual produto gera maior receita?": o dataset não tem nome de produto | Respondido por categoria; documentado | Aceito |
| 11 | — | Nota menor em pedidos atrasados é uma associação | Caveat no README | Aceito |
| 12 | — | Sem custos, então não há análise de lucro. 4 itens com `shipping_limit_date` em 2020 (depois do fim da base) não são usados em nenhum KPI | Documentado | Aceito |
| 13 | — | Ticket médio (R$ 160) é maior que a mediana (R$ 105) por causa de poucos pedidos caros | Mostrado só o ticket médio, como pede o KPI | Aceito |

## Decisão de entrega

- [ ] **Aprovado para entrega**
- [x] **Aprovado com ressalvas**
- [ ] **Bloqueado**

**Ressalvas:**
> - Os números são do período jan/2017 a ago/2018, com pedidos válidos (sem cancelados e indisponíveis). A recompra de apenas 3,03% e a nota menor nos pedidos atrasados descrevem os dados; não provam causa.
> - O projeto Power BI usa o formato `.pbip` (arquivos de texto). Foi aberto e validado no Power BI Desktop.

**Revisor:** Lucas Feitosa  **Data:** 2026-10-09
