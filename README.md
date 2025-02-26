# Projeto Elixir para automação da coleta de dados no Portal e-MEC

**Este projeto foi desenvolvido para automatizar a busca de dados das universidades federais cadastradas no portal e-MEC. Inicialmente, foi projetado para a consulta das universidades da região Norte do Brasil, mas pode ser facilmente adaptado para outras regiões do país. Para executar o script, o usuário deve fornecer uma lista de parâmetros, como as siglas dos estados brasileiros. Após isso, o script realiza a consulta na base de dados do e-MEC e salva os resultados em um arquivo .csv.**

## Instalar dependências

Após realizar o download, abra o terminal e navegue até o diretório onde o projeto foi salvo. Em seguida, execute o comando abaixo para instalar as dependências do projeto.

```elixir
mix deps.get

```
## Execução do Script

Após após a instalação das dependências execute o comando. 

```elixir
iex -S mix 

```
Em seguida, para rodar o script de coleta, execute a função abaixo.

```elixir
Request.buscar_ies(["AC", "AP", "AM", "PA", "RO", "RR", "TO"])

```

