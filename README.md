# Projeto Elixir para automação coleta de dados Portal e-MEC

**Este projeto foi desenvolvido para automatizar a busca de dados refrentes as univeridades federais cadastradas no portal e-MEC. Este foi desenvolvido para automatizar das universidadas da região norte do Brasil, mas pode ser utilizado para as demais regiões do país, de forma que a para execução do script desenvolvido basta somente o usuário passar uma lista de paramentros como as siglas dos estados Brasileoiros. Feito isso, o script faz a consulta na base de dados do e-MEC e salva os mesmos em um arquivo .csv**

## Instalar dependências

Após o Dowload entre via linha de comando no diretório e execute o comando a seguir para instalar as dependências do projeto.

```elixir
mix deps.get

```
## Execução do Script

Após após a instalação das dependências rode o comando `iex -S mix` e na sequêcia execute o script de coleta através do comando a seguir.

```elixir
Request.buscar_ies(["AC", "AP", "AM", "PA", "RO", "RR", "TO"])

```

