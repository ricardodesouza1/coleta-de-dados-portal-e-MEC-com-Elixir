# Projeto Elixir para automação coleta de dados Portal e-MEC

**Este projeto foi desenvolvido para automatizar a busca de dados refrentes as univeridades federais cadastradas no portal e-MEC. Este foi desenvolvido para automatizar das universidadas da região norte do Brasil, mas pode ser utilizado para as demais regiões do país, de forma que a para execução do script desenvolvido basta somente o usuário passar uma lista de paramentros como as siglas dos estados Brasileoiros. Feito isso, o script faz a consulta na base de dados do e-MEC e salva os mesmos em um arquivo .csv**

## Execução do Script

Após o Dowload execute entre no diretório e execute o comando `iex -S mix` e na sequêcia execute o jogo com a função a seguir.

```elixir
Request.buscar_ies(["AC", "AP", "AM", "PA", "RO", "RR", "TO"])

```

