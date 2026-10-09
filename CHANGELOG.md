# Changelog

Todas as mudanças relevantes do projeto estão neste arquivo.

## [1.0.0] - 2026-10-09

### Adicionado
- Documentação de negócio: dicionário de dados, perguntas de negócio e KPIs.
- Profiling e limpeza dos 9 datasets da Olist, um notebook por dataset (`notebooks/01` a `09`), com os arquivos tratados em `data/processed/`.
- Tabela de geolocalização por CEP (`olist_geolocation_zip_clean.csv`).
- Projeto do Power BI (`dashboard/TechStore.pbip`) com modelo de dados, 10 relacionamentos, tema, 6 colunas calculadas e 29 medidas DAX.
- Dashboard de 2 páginas: **Vendas** e **Entrega e Clientes**, com 3 segmentações sincronizadas.
- Documentação do tratamento de dados (`docs/data_cleaning.md`), do design do dashboard (`docs/dashboard_design.md`) e da validação final (`docs/qa_signoff.md`).

### Validação
- 38 valores do dashboard recalculados em SQL de forma independente: todos conferem.

### Corrigido durante a validação
- Pedidos ainda não entregues eram contados como "no prazo" (% de atraso 6,67% e nota 4,25). Agora 6,79% e 4,29.
- Segmentações não sincronizavam entre as páginas.
- Gráficos Top 10 com barra de rolagem (mostravam 7 de 10 barras).
