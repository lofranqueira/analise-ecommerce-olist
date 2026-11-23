# Análise de Dados do E-commerce Brasileiro (Olist)

Projeto de portfólio com **PostgreSQL**, utilizando o conjunto público de dados da Olist para investigar vendas, avaliações de clientes e desempenho logístico.

## Objetivo

Responder perguntas de negócio com SQL e transformar os resultados em indicadores que apoiem decisões sobre vendas, experiência do cliente e logística.

## Ferramentas utilizadas

- PostgreSQL 18
- pgAdmin
- SQL
- Python
- Pandas
- Jupyter Notebook
- Matplotlib

## Fonte dos dados

[Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

O conjunto contém informações de pedidos, clientes, itens, produtos, vendedores, pagamentos, avaliações, geolocalização e tradução de categorias.

## Estrutura do projeto

```text
analise-ecommerce-olist/
├── sql/
│   └── 01_analises_olist.sql
├── .gitignore
├── README.md
├── analise_ecommerce_olist.ipynb
└── projeto_olist.sql
```
## Análises realizadas

### Análises com SQL

1. **Visão geral dos pedidos:** volume por status, cancelamentos e evolução mensal.
2. **Análise financeira:** receita de produtos, frete, receita por categoria e ticket médio.
3. **Avaliações:** nota média, distribuição das notas e percentual de avaliações negativas.
4. **Logística:** atrasos, tempo médio de entrega e comparação por estado.

### Análises com Python

1. Análise exploratória dos dados do e-commerce.
2. Análise da evolução mensal dos pedidos.
3. Avaliação do impacto dos atrasos nas avaliações dos clientes.
4. Visualização gráfica dos principais indicadores e resultados.

**Arquivos do projeto:**

- Consultas SQL: `sql/01_analises_olist.sql`
- Notebook Python: `analise_ecommerce_olist.ipynb`

## Principais resultados encontrados

Resultados calculados durante a exploração do conjunto:

- 99.441 pedidos na tabela de pedidos.
- 96.478 pedidos com status `delivered`.
- 625 pedidos cancelados, aproximadamente **0,63%** do total.
- Receita de produtos: **R$ 13.591.643,70**.
- Frete total: **R$ 2.251.909,54**.
- Receita de produtos mais frete: **R$ 15.843.553,24**.
- Ticket médio de produtos por pedido, considerando pedidos com itens: **R$ 137,75**.
- Ticket médio de produtos por pedido entregue: **R$ 137,04**.
- Nota média das avaliações: **4,09 de 5**.
- Avaliações com notas 1 ou 2: **14,69%**.
- Entre pedidos entregues com datas de entrega e previsão disponíveis, **8,11%** chegaram após a data estimada.
- Entre os estados com pelo menos 500 pedidos entregues, Maranhão apresentou a maior taxa de atraso (**19,67%**) e Paraná a menor (**5,00%**).

## Interpretações iniciais

- A maioria das avaliações é positiva, mas avaliações negativas ainda representam uma parcela relevante.
- Pedidos atrasados tiveram uma proporção muito maior de avaliações negativas do que pedidos entregues no prazo ou antecipadamente, na análise exploratória realizada.
- O tempo médio de entrega e a taxa de atraso não são a mesma coisa: o prazo prometido também influencia a classificação de atraso.
- Comparações entre estados devem considerar o volume de pedidos. Por isso, algumas análises usam um corte mínimo de 500 pedidos.

## Cuidados metodológicos

- Receita e ticket médio apresentados usam `price`, ou seja, valor dos produtos. O frete foi calculado separadamente.
- Algumas métricas de avaliações contam avaliações, não necessariamente pedidos únicos.
- A análise de atraso considera pedidos com status `delivered` e datas de entrega e previsão preenchidas.
- Associação entre atraso e avaliação negativa não prova causalidade.
- Estados com poucas observações podem apresentar percentuais instáveis.
- Os CSVs originais não devem ser enviados ao repositório sem necessidade; consulte os termos e a licença da fonte.

## Como executar

1. Baixe os CSVs na fonte indicada.
2. Crie um banco PostgreSQL.
3. Importe as tabelas do conjunto Olist.
4. Abra `sql/01_analises_olist.sql` no pgAdmin.
5. Execute os blocos individualmente e confira os resultados.

## Próximas melhorias

- Investigar o desempenho por vendedor e por transportadora, quando disponível.
- Analisar atrasos por categoria de produto.
- Aprofundar a relação entre atrasos e avaliações negativas.
- Desenvolver um dashboard interativo no Power BI.
- Documentar novas descobertas e indicadores.

## Status

Em desenvolvimento — etapa SQL exploratória concluída parcialmente.
